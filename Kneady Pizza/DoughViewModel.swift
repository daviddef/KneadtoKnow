import Foundation
import SwiftUI
import Combine

@MainActor
final class DoughViewModel: ObservableObject {
    @Published var input = DoughInput()
    @Published var hasFavourite = false
    /// The user's skill level — orders the style picker toward their level.
    @Published var experienceLevel: Complexity = ExperienceStore.level {
        didSet { ExperienceStore.level = experienceLevel }
    }
    /// recipe id → how many of that pizza to make.
    @Published var pizzaSelection: [String: Int] = [:]
    /// Custom extra ingredients selected for this shopping list.
    @Published var extras: Set<String> = []
    /// Custom extras the user has saved as reusable options.
    @Published var favouriteExtras: [String] = []
    /// When on, pineapple/Hawaiian recipes are hidden from the planner.
    @Published var hidePineapple: Bool = PineappleStore.hidden {
        didSet { PineappleStore.hidden = hidePineapple }
    }
    /// The bake currently in progress (some steps ticked, not all). Persisted.
    @Published var activeBake: ActiveBake?
    /// Kid Mode — a big, fun, simplified pizza flow for children.
    @Published var kidMode: Bool = KidModeStore.enabled {
        didSet { KidModeStore.enabled = kidMode }
    }

    /// Recipes for a style, with pineapple filtered out when the user opted out.
    func availableRecipes(for styleID: String) -> [PizzaRecipe] {
        let all = RecipeCatalog.recipes(for: styleID)
        guard hidePineapple else { return all }
        return all.filter { !RecipeCatalog.isPineapple($0) }
    }

    /// Hide pineapple for good — drop any pineapple picks and remember it.
    func neverShowPineapple() {
        hidePineapple = true
        for recipe in RecipeCatalog.recipes(for: input.style.id)
        where RecipeCatalog.isPineapple(recipe) {
            pizzaSelection[recipe.id] = nil
        }
        if hasFavourite || autosaveFavourite { saveFavourite(silent: true) }
        Haptics.tap()
    }

    var metric: Bool { Units.isMetric(input.lengthUnit) }

    enum WeatherState: Equatable {
        case idle, loading, loaded(Double), failed(String)
    }
    @Published var weatherState: WeatherState = .idle

    /// Whether the user wants local reminders for upcoming steps.
    @Published var notificationsEnabled: Bool = NotificationStore.enabled {
        didSet {
            guard oldValue != notificationsEnabled else { return }
            NotificationStore.enabled = notificationsEnabled
            if notificationsEnabled {
                Task { await enableNotifications() }
            } else {
                NotificationManager.cancelAll()
            }
        }
    }

    /// Keep the favourite continuously in sync with the user's choices.
    @Published var autosaveFavourite: Bool = AutosaveStore.enabled {
        didSet {
            guard oldValue != autosaveFavourite else { return }
            AutosaveStore.enabled = autosaveFavourite
            if autosaveFavourite { saveFavourite(silent: true) }
        }
    }

    private let location = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    /// "Now" reference for the timeline. Refreshed when the view appears so
    /// clock times stay current without churning on every keystroke.
    @Published var now = Date()

    init() {
        favouriteExtras = CustomExtrasStore.load()
        let savedSimple = SimpleModeStore.enabled   // the persisted Simple/Classic choice
        if let fav = FavouriteStore.load() {
            input = DoughInput.from(fav)
            pizzaSelection = fav.pizzaSelection ?? [:]
            extras = Set(fav.extras ?? [])
            hidePineapple = fav.hidePineapple ?? PineappleStore.hidden
            hasFavourite = true
            // Saved serve time is usually stale — fall back to the earliest.
            if input.serveDate <= Date() { resetServeToEarliest() }
        } else if savedSimple {
            applySimpleProofDefault()   // simple mode starts as a Quick, 12 h plan
        } else {
            resetServeToEarliest()
        }

        // An unfinished bake takes over so the timeline picks up where it left
        // off — keep its original, anchored serve time (don't reset to earliest).
        if let bake = BakeStore.load() {
            activeBake = bake
            input = DoughInput.from(bake.recipe)
            pizzaSelection = bake.recipe.pizzaSelection ?? [:]
            extras = Set(bake.recipe.extras ?? [])
            hidePineapple = bake.recipe.hidePineapple ?? hidePineapple
        }

        // The Simple/Classic mode is a global preference — restore it so the
        // choice sticks across launches (favourites no longer override it).
        input.keepItSimple = savedSimple

        // Autosave: when on, mirror every change into the favourite (debounced).
        let inputChanges = $input.dropFirst().map { _ in () }
        let selectionChanges = $pizzaSelection.dropFirst().map { _ in () }
        let extraChanges = $extras.dropFirst().map { _ in () }
        Publishers.Merge3(inputChanges, selectionChanges, extraChanges)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] in self?.autosaveIfEnabled() }
            .store(in: &cancellables)
    }

    private func autosaveIfEnabled() {
        guard autosaveFavourite else { return }
        saveFavourite(silent: true)
    }

    // MARK: Custom extras

    func toggleExtra(_ name: String) {
        if extras.contains(name) { extras.remove(name) } else { extras.insert(name) }
        Haptics.tap()
    }

    func addExtra(_ raw: String) {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        extras.insert(name)
        if !favouriteExtras.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
            favouriteExtras.append(name)
            CustomExtrasStore.save(favouriteExtras)
        }
        Haptics.tap()
    }

    func removeFavouriteExtra(_ name: String) {
        favouriteExtras.removeAll { $0 == name }
        extras.remove(name)
        CustomExtrasStore.save(favouriteExtras)
        Haptics.tap()
    }

    var selectedExtras: [String] { extras.sorted() }

    /// Switches the fermentation approach. Quick enriches the dough (honey)
    /// to force a fast rise; if the serve time is now too soon for the chosen
    /// method, snaps it to the earliest that works.
    func setFermentStyle(_ style: FermentStyle) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            input.ferment = style
            if style == .quick && input.honey < 0.01 { input.honey = 0.01 }
        }
        if style == .quick {
            now = Date()
            withAnimation(.easeInOut) { input.serveDate = now.addingTimeInterval(3 * 3600) }
        } else {
            let ideal = Scheduler.idealTotalHours(input: input)
            let available = input.serveDate.timeIntervalSince(now) / 3600
            if available < ideal { resetServeToEarliest() }
        }
        Haptics.select()
    }

    /// A plain-text summary to share — what we're making and what to buy.
    func shareText() -> String {
        let noun = input.style.shape.nounPlural
        var lines: [String] = ["🍕 Kneady Pizza — \(input.ballCount) × \(input.style.name) \(noun)"]

        let chosen = RecipeCatalog.recipes(for: input.style.id).compactMap { r -> String? in
            guard let c = pizzaSelection[r.id], c > 0 else { return nil }
            return "\(c)× \(r.name)"
        }
        if !chosen.isEmpty { lines.append("Making: " + chosen.joined(separator: ", ")) }

        lines.append("\nDOUGH")
        for l in doughLines() {
            let hint = l.hint.map { " (\($0))" } ?? ""
            lines.append("• \(l.name): \(Units.weight(l.grams, metric: metric))\(hint)")
        }
        let tops = toppingLines()
        if !tops.isEmpty {
            lines.append("\nTOPPINGS (in the order they go on)")
            for l in tops { lines.append("• \(l.name): \(Units.weight(l.grams, metric: metric))") }
        }
        if !extras.isEmpty {
            lines.append("\nEXTRAS")
            for e in selectedExtras { lines.append("• \(e)") }
        }
        lines.append("\nSent from Kneady Pizza 🍕")
        return lines.joined(separator: "\n")
    }

    /// Switches the pre-ferment on/off and seeds its industry-typical size.
    func setPreferment(_ choice: PrefermentChoice) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            switch choice {
            case .none:
                input.usePreferment = false
            case .poolish:
                input.usePreferment = true
                input.preferment = .poolish
                input.prefermentPct = Preferment.poolish.defaultPct
            case .biga:
                input.usePreferment = true
                input.preferment = .biga
                input.prefermentPct = Preferment.biga.defaultPct
            }
        }
        Haptics.select()
    }

    /// Advances the app's sense of "now" to the live clock. For a Quick dough,
    /// "ready in X" is relative to now, so we slide the serve time forward to
    /// keep that duration steady — which keeps the Start time current too.
    func refreshNow() {
        let newNow = Date()
        // A quick proof keeps "ready in N hours" rolling forward — but never once
        // a bake is underway, where the times are locked to the start.
        if input.ferment == .quick && activeBake == nil {
            let readyIn = min(max(input.serveDate.timeIntervalSince(now), 3600), 24 * 3600)
            input.serveDate = newNow.addingTimeInterval(readyIn)
        }
        now = newNow
    }

    /// Simple mode's default plan: a Cold proof.
    func applySimpleProofDefault() {
        now = Date()
        withAnimation(.easeInOut) {
            input.ferment = .cold   // Cold Proof by default
        }
        resetServeToEarliest()      // soonest sensible serve for a cold proof
    }

    /// The soonest (hours from now) a given proof method could be ready, using
    /// the current preferment/autolyse choices.
    func soonestReady(_ ferment: FermentStyle) -> Double {
        var i = input
        i.ferment = ferment
        return Scheduler.idealTotalHours(input: i)
    }

    // MARK: Notifications

    /// Requests permission and, if granted, schedules the current plan's steps.
    /// If the user declines, the toggle falls back off.
    func enableNotifications() async {
        let granted = await NotificationManager.requestAuthorization()
        if granted {
            rescheduleNotifications()
        } else {
            notificationsEnabled = false
        }
    }

    /// Re-schedules reminders to match the live plan. Reminders only fire for a
    /// bake that's actually underway — otherwise any pending ones are cleared,
    /// so you're never pinged for a plan you're just browsing.
    func rescheduleNotifications() {
        guard notificationsEnabled, activeBake != nil else {
            NotificationManager.cancelAll()
            return
        }
        NotificationManager.reschedule(steps: schedule.steps, now: now)
    }

    /// A short spec for the saved favourite — style, hydration and pre-ferment.
    var favouriteSpec: String? {
        guard let fav = FavouriteStore.load() else { return nil }
        let style = PizzaStyle.all.first { $0.id == fav.styleID }
        var parts: [String] = []
        if let style { parts.append(style.name) }
        parts.append("\(Int((fav.hydration * 100).rounded()))% hydration")
        parts.append(fav.usePreferment ? fav.preferment : "direct")   // "poolish"/"biga"
        return parts.joined(separator: " · ")
    }

    /// A full label/value breakdown of everything stored in the favourite.
    var favouriteDetails: [(label: String, value: String)]? {
        guard let fav = FavouriteStore.load() else { return nil }
        let i = DoughInput.from(fav)
        let m = Units.isMetric(i.lengthUnit)
        func pct(_ f: Double) -> String { String(format: "%.1f%%", f * 100) }
        func length(_ v: Double) -> String {
            i.lengthUnit == .cm ? String(format: "%.0f cm", v) : String(format: "%.1f in", v)
        }

        let size: String
        if i.sizeMode == .weight {
            size = "\(Units.weight(i.ballWeight, metric: m)) each"
        } else if i.style.shape == .round {
            size = "\(length(i.diameter)) across"
        } else {
            size = "\(length(i.panLength))×\(length(i.panWidth))"
        }
        let noun = i.ballCount == 1 ? i.style.shape.noun : i.style.shape.nounPlural

        var rows: [(String, String)] = [
            ("Style", i.style.name),
            ("Mode", i.keepItSimple ? "Simple" : "Classic"),
            ("Make", "\(i.ballCount) \(noun) · \(size)"),
            ("Yeast", i.yeast.fullName),
            ("Pre-ferment", i.usePreferment ? "\(i.preferment.name) · \(pct(i.prefermentPct)) of flour" : "None"),
            ("Autolyse", i.useAutolyse ? "Yes" : "No"),
            ("Hydration", pct(i.hydration)),
            ("Salt", pct(i.salt)),
        ]
        if i.oil > 0 { rows.append(("Olive oil", pct(i.oil))) }
        if i.honey > 0 { rows.append(("Honey", pct(i.honey))) }
        rows.append(("Fermentation", i.ferment.label))
        rows.append(("Oven", i.oven.label))
        rows.append(("Units", m ? "Metric (g, cm)" : "Imperial (oz, in)"))
        rows.append(("Coaching tips", i.tipsEnabled ? "On" : "Off"))
        rows.append(("Humour", i.humourEnabled ? i.humourLevel.label : "Off"))

        let selection = fav.pizzaSelection ?? [:]
        let selected = selection.values.reduce(0, +)
        if selected > 0 {
            let named = RecipeCatalog.recipes(for: fav.styleID).compactMap { r -> String? in
                guard let c = selection[r.id], c > 0 else { return nil }
                return "\(c)× \(r.name)"
            }
            let value = named.isEmpty
                ? "\(selected) pizza\(selected == 1 ? "" : "s") planned"
                : named.joined(separator: ", ")
            rows.append(("Pizzas", value))
        }
        let extras = fav.extras ?? []
        if !extras.isEmpty { rows.append(("Extras", extras.joined(separator: ", "))) }

        return rows
    }

    /// Sets the serve time to the soonest possible if you started right now,
    /// snapped UP to the next half hour so it stays a tidy time and never
    /// slips into the past.
    func resetServeToEarliest() {
        now = Date()
        let ideal = Scheduler.idealTotalHours(input: input)
        let target = now.addingTimeInterval(ideal * 3600)
        withAnimation(.easeInOut) {
            input.serveDate = Self.roundedUpToHalfHour(target, after: now)
        }
    }

    /// Rounds a date UP to the next 30-minute mark (:00 or :30), guaranteeing
    /// the result is strictly later than `floor` (i.e. always in the future).
    static func roundedUpToHalfHour(_ date: Date, after floor: Date) -> Date {
        let interval: TimeInterval = 30 * 60
        var t = (date.timeIntervalSinceReferenceDate / interval).rounded(.up) * interval
        while t <= floor.timeIntervalSinceReferenceDate { t += interval }
        return Date(timeIntervalSinceReferenceDate: t)
    }

    /// A full snapshot of the current setup (recipe + picks + extras + prefs).
    private func currentSavedRecipe() -> SavedRecipe {
        var rec = input.saved
        rec.pizzaSelection = pizzaSelection
        rec.extras = Array(extras)
        rec.hidePineapple = hidePineapple
        return rec
    }

    func saveFavourite(silent: Bool = false) {
        FavouriteStore.save(currentSavedRecipe())
        hasFavourite = true
        if !silent { Haptics.success() }
    }

    /// Start cooking now: freeze the plan's reference time so the directions'
    /// clock times lock in and stop shifting when the app is reopened.
    func startBake() {
        now = Date()
        resetServeToEarliest()   // serve = now + full plan, so the first step is now
        let bake = ActiveBake(recipe: currentSavedRecipe(),
                              completedSteps: [],
                              totalSteps: schedule.steps.count,
                              anchorDate: now)
        BakeStore.save(bake)
        activeBake = bake
        rescheduleNotifications()   // reminders start now that a bake is underway
        Haptics.success()
    }

    /// Remembers the current bake while it's underway. Called whenever the user
    /// ticks a step. Ticking the first step auto-starts a bake; ticking the last
    /// finishes it (and clears it).
    func recordBakeProgress(completed: Set<Int>, totalSteps: Int) {
        // Finished — every step ticked, so there's nothing left to cook.
        if !completed.isEmpty, completed.count >= totalSteps {
            BakeStore.clear(); activeBake = nil
            rescheduleNotifications()   // clears any pending reminders
            return
        }
        // Only record once a bake exists (via Go) or the first step is ticked.
        guard activeBake != nil || !completed.isEmpty else { return }
        let wasActive = activeBake != nil
        let bake = ActiveBake(recipe: currentSavedRecipe(),
                              completedSteps: Array(completed).sorted(),
                              totalSteps: totalSteps,
                              anchorDate: activeBake?.anchorDate ?? now)
        BakeStore.save(bake)
        activeBake = bake
        if !wasActive { rescheduleNotifications() }   // first tick auto-started a bake
    }

    /// Cancel the in-progress bake and fall back to the favourite (or defaults).
    func cancelBake() {
        BakeStore.clear()
        activeBake = nil
        rescheduleNotifications()   // stop reminders for the cancelled bake
        if FavouriteStore.load() != nil {
            applyFavourite()
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                input.applyDefaults(of: Self.defaultStyle(for: experienceLevel))
                pizzaSelection = [:]
                extras = []
            }
            resetServeToEarliest()
        }
        Haptics.tap()
    }

    /// The style whose difficulty best matches a level (ties keep list order).
    static func defaultStyle(for level: Complexity) -> PizzaStyle {
        PizzaStyle.all.enumerated().min { a, b in
            let da = abs(a.element.complexity.rawValue - level.rawValue)
            let db = abs(b.element.complexity.rawValue - level.rawValue)
            return da == db ? a.offset < b.offset : da < db
        }!.element
    }

    /// A small starter selection — the first couple of savoury recipes.
    func starterSelection(for style: PizzaStyle) -> [String: Int] {
        let savoury = RecipeCatalog.recipes(for: style.id).filter { $0.category == .savoury }
        var sel: [String: Int] = [:]
        for r in savoury.prefix(2) { sel[r.id] = 2 }
        return sel
    }

    /// Applies the first-run choices: experience level, oven, and the
    /// permission opt-ins. Sets units from the device region.
    func applyOnboarding(level: Experience, oven: OvenType, wantsReminders: Bool, wantsLocation: Bool) {
        if #available(iOS 16, *) {
            input.lengthUnit = (Locale.current.measurementSystem == .us) ? .inch : .cm
        }
        experienceLevel = level.color   // orders the style picker to suit them
        input.oven = oven

        // The starting style follows the level (closest-matching style).
        let style = Self.defaultStyle(for: level.color)
        input.humourEnabled = true
        input.tipsEnabled = true

        switch level {
        case .villager:
            input.keepItSimple = true
            input.humourLevel = .lots
            select(style: style)
            pizzaSelection = starterSelection(for: style)
            applySimpleProofDefault()
            autosaveFavourite = true
        case .pizzaiolo:
            input.keepItSimple = true
            input.humourLevel = .some
            select(style: style)
            pizzaSelection = starterSelection(for: style)
            applySimpleProofDefault()
            autosaveFavourite = true
        case .roman:
            input.keepItSimple = false
            input.humourLevel = .less
            select(style: style)
            pizzaSelection = starterSelection(for: style)
            input.ferment = .cold
            resetServeToEarliest()
            autosaveFavourite = false
        }

        if wantsReminders { notificationsEnabled = true }          // triggers the permission prompt
        if wantsLocation { Task { await fetchLocalTemperature() } } // triggers the location prompt + sets temp

        SimpleModeStore.enabled = input.keepItSimple   // remember the mode
        OnboardingStore.completed = true
        if autosaveFavourite { saveFavourite(silent: true) }
        Haptics.success()
    }

    /// One-tap "make it as easy as possible": Simple Home Classic, keep-it-simple
    /// on, a Quick proof ready in 12 hours, home oven — then saved as the favourite.
    func resetToEasy() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            input.keepItSimple = true            // so applyDefaults sizes by weight
            input.applyDefaults(of: .everyday)   // Simple Home Classic, no pre-ferment/autolyse
            input.oven = .home
            pizzaSelection = [:]
            extras = []
        }
        applySimpleProofDefault()                // Quick proof, ready in 12 h
        saveFavourite()
    }

    func clearFavourite() {
        FavouriteStore.clear()
        hasFavourite = false
        autosaveFavourite = false   // nothing to keep in sync
        // Turning the favourite off resets the setup to app defaults — it should
        // stop remembering the recipe, pizza choices and extras.
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            input.applyDefaults(of: Self.defaultStyle(for: experienceLevel))
            pizzaSelection = [:]
            extras = []
        }
        Haptics.tap()
    }

    func applyFavourite() {
        guard let fav = FavouriteStore.load() else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            input = DoughInput.from(fav)
            pizzaSelection = fav.pizzaSelection ?? [:]
            extras = Set(fav.extras ?? [])
            hidePineapple = fav.hidePineapple ?? PineappleStore.hidden
        }
        resetServeToEarliest()
        Haptics.select()
    }

    /// The instant the plan is built against. Once a bake is underway it's
    /// frozen at the start time, so the directions' clock times stay put even
    /// as real time marches on (and the app is reopened).
    var scheduleNow: Date { activeBake?.anchorDate ?? now }

    /// The live bake plan, worked backward from the serve time.
    var schedule: Schedule { Scheduler.build(input: input, now: scheduleNow) }

    /// The live recipe — recomputed automatically as inputs change.
    var result: DoughResult { DoughCalculator.calculate(input, schedule: schedule) }

    /// Grams contributed by a baker's-percentage ingredient, for live readouts
    /// next to the proportion sliders.
    func grams(of fraction: Double) -> Double {
        let divisor = 1 + input.hydration + input.salt + input.oil + input.honey
        guard divisor > 0 else { return 0 }
        return (result.totalWeight / divisor) * fraction
    }

    func select(style: PizzaStyle) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            input.applyDefaults(of: style)
            input.ballCount = style.defaultCount   // e.g. focaccia → one pan
            pizzaSelection = [:]   // recipes differ per style
        }
        Haptics.select()
    }

    /// Toggle gluten-free. Re-seeds the recipe from the current style so the GF
    /// hydration target, binder and dropped pre-ferment all apply at once.
    func setGlutenFree(_ on: Bool) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            input.glutenFree = on
            input.applyDefaults(of: input.style)
        }
        autosaveIfEnabled()
        Haptics.select()
    }

    // MARK: Topping planner

    var selectedPizzaTotal: Int { pizzaSelection.values.reduce(0, +) }

    /// Topping amounts scale with how big each pizza is (vs. a ~270 g 12″).
    var sizeFactor: Double { min(max(result.ballWeight / 270, 0.5), 2.5) }

    func setRecipeCount(_ id: String, _ count: Int) {
        let others = selectedPizzaTotal - (pizzaSelection[id] ?? 0)
        let capped = max(0, min(count, max(input.ballCount, 1) - others))
        if capped == 0 { pizzaSelection[id] = nil } else { pizzaSelection[id] = capped }
        Haptics.tap()
    }

    /// Flour description for the current style (for the shopping list).
    var flourType: String {
        switch input.style.id {
        case "neapolitan", "neapolitan-contemporary", "roman": return "Type 00"
        case "newyork", "detroit":  return "Bread flour"
        case "sfincione":           return "Type 00 + semola"
        default:                    return "Bread or plain flour"
        }
    }

    /// Core dough ingredients, aggregated across all stages.
    func doughLines() -> [ShoppingLine] {
        var totals: [String: Double] = [:]
        var order: [String] = []
        for stage in result.stages {
            for ing in stage.ingredients where !ing.name.hasPrefix("All of") {
                if totals[ing.name] == nil { order.append(ing.name) }
                totals[ing.name, default: 0] += ing.grams
            }
        }
        return order.map { name in
            let g = totals[name] ?? 0
            let displayName = name == "Flour" ? "Flour (\(flourType))" : name
            var hint: String? = nil
            if name == "Flour" && metric {
                let bags = max(1, Int((g / 1000).rounded(.up)))
                hint = "≈ \(bags) × 1 kg bag\(bags > 1 ? "s" : "")"
            }
            return ShoppingLine(name: displayName, grams: g, hint: hint)
        }
    }

    /// The ingredients to handle at a given timeline step.
    func stepItems(for step: ScheduleStep) -> [Ingredient] {
        let r = result
        switch step.title {
        case "The Poolish", "The Biga":
            return r.prefermentSplit != nil ? (r.stages.first?.ingredients ?? []) : []
        case "Autolyse":
            let stage = r.prefermentSplit != nil ? r.stages.last : r.stages.first
            return (stage?.ingredients ?? []).filter { $0.name == "Flour" || $0.name == "Water" }
        case "The Dough":
            let stage = r.prefermentSplit != nil ? r.stages.last : r.stages.first
            let all = stage?.ingredients ?? []
            guard input.autolyseActive else { return all }
            // The flour & water are already resting as the autolyse — fold them
            // back in as one line so it's clear what's being combined.
            let autoGrams = all.filter { $0.name == "Flour" || $0.name == "Water" }
                               .reduce(0) { $0 + $1.grams }
            var items: [Ingredient] = []
            if autoGrams > 0 {
                items.append(Ingredient("All of the autolyse", autoGrams, note: "the rested flour & water"))
            }
            items += all.filter { $0.name != "Flour" && $0.name != "Water" }
            return items
        case "Ball Roll", "Into Pans":
            return [Ingredient("Each \(input.style.shape.noun)", r.ballWeight)]
        default:
            return []
        }
    }

    /// Cheese & tomato guidance for the "Top It" step, tuned to the style.
    var toppingAdvice: String {
        switch input.style.id {
        case "neapolitan", "neapolitan-contemporary":
            return "Cheese: fresh fior di latte, or buffalo mozzarella for a richer pie — tear it and drain it well on kitchen paper so it doesn't flood the base. Tomato: crushed San Marzano (DOP if you can), used raw with just a pinch of salt — the fierce, short bake cooks them."
        case "newyork":
            return "Cheese: low-moisture mozzarella, grated — it melts evenly and browns without weeping in the longer, cooler bake. Tomato: a cooked sauce from tinned plum tomatoes with a little oregano, garlic and a pinch of sugar."
        case "roman":
            return "Cheese: a light layer of fior di latte (well drained). Tomato: a thin passata, used sparingly, so the cracker-thin base stays shatteringly crisp."
        case "detroit":
            return "Cheese: brick cheese (or low-moisture mozzarella) pushed right to the edges for the crisp, lacy frico rim. Tomato: a thick cooked sauce, ladled in stripes ON TOP of the cheese."
        case "sfincione":
            return "No fresh mozzarella here — use caciocavallo or a firm sheep's cheese that won't water out. Tomato: a cooked onion–tomato–anchovy sauce, finished with breadcrumbs."
        case "focaccia":
            return "Usually no cheese or tomato — finish with good extra-virgin olive oil, rosemary and flaky salt. Cherry tomatoes or olives pressed into the dimples are lovely."
        default:
            return "Cheese: low-moisture mozzarella melts most reliably in a home oven; fresh mozzarella works too if you drain it well first. Tomato: tinned San Marzano or a good passata, lightly salted — keep it a thin layer."
        }
    }

    /// Topping ingredients for the planner selection.
    func toppingLines() -> [ShoppingLine] {
        RecipeCatalog.toppingShoppingList(styleID: input.style.id, selection: pizzaSelection, sizeFactor: sizeFactor)
    }

    /// Names of the selected pizzas in order — the legend for the "pizza #"
    /// shown next to each topping (number = index + 1).
    func pizzaLegend() -> [String] {
        RecipeCatalog.selectedRecipes(styleID: input.style.id, selection: pizzaSelection).map { $0.name }
    }

    /// A rough offline cost estimate for the whole bake — the dough (flour,
    /// salt, oil, honey, binder; water is free, yeast negligible) plus the
    /// selected toppings. Prices are the user-editable per-kg figures.
    func estimatedCost() -> (total: Double, perPizza: Double) {
        let p = PriceStore.shared
        let i = input
        func kg(_ g: Double) -> Double { max(0, g) / 1000 }

        let binderPct = (i.glutenFree && !i.binderInBlend) ? i.binder.pct : 0
        let divisor = 1 + i.hydration + i.salt + i.oil + i.honey + binderPct
        let flour = divisor > 0 ? result.totalWeight / divisor : 0

        var total = kg(flour) * p.pricePerKg(.flour)
        total += kg(flour * i.salt) * p.pricePerKg(.salt)
        if i.oil > 0 { total += kg(flour * i.oil) * p.pricePerKg(.oil) }
        if i.honey > 0 { total += kg(flour * i.honey) * p.pricePerKg(.sweetener) }
        if binderPct > 0 { total += kg(flour * binderPct) * p.pricePerKg(.binder) }

        for line in toppingLines() {
            total += kg(line.grams) * p.pricePerKg(PriceCategory.classify(line.name))
        }

        let count = max(input.ballCount, 1)
        return (total, total / Double(count))
    }

    /// Each selected pizza with its toppings in application order (per pizza),
    /// for the "Top It" step of the directions.
    func toppingPlan() -> [PizzaToppingPlan] {
        let cheeseFirst = (input.style.id == "detroit")
        return RecipeCatalog.recipes(for: input.style.id).compactMap { recipe in
            guard let count = pizzaSelection[recipe.id], count > 0 else { return nil }
            let ordered = recipe.toppings.sorted { a, b in
                let ra = RecipeCatalog.layerRank(a.name, cheeseFirst: cheeseFirst)
                let rb = RecipeCatalog.layerRank(b.name, cheeseFirst: cheeseFirst)
                return ra == rb ? a.name < b.name : ra < rb
            }
            let layers = ordered.map { t in
                ShoppingLine(name: t.name,
                             grams: t.gramsPerPizza * (t.scalesWithSize ? sizeFactor : 1),
                             hint: nil)
            }
            return PizzaToppingPlan(id: recipe.id, title: "\(count)× \(recipe.name)", layers: layers)
        }
    }

    /// Pulls the current temperature from the user's location.
    func fetchLocalTemperature() async {
        weatherState = .loading
        do {
            let coordinate = try await location.requestCoordinate()
            let temp = try await WeatherService.currentTemperature(at: coordinate)
            withAnimation(.easeInOut) {
                input.temperatureC = (temp * 2).rounded() / 2   // nearest 0.5°
                weatherState = .loaded(temp)
            }
            Haptics.success()
        } catch LocationManager.LocationError.denied {
            weatherState = .failed("Location access is off — set it by hand below.")
        } catch {
            weatherState = .failed("Couldn't reach the weather — set it by hand.")
        }
    }
}
