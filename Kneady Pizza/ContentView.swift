import SwiftUI
import Combine

/// Reports each tracked section's top offset within the scroll view, so we can
/// tell which one the baker is looking at and fire a relevant feature nudge.
struct SectionOffsetKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// Identifies which step the full-screen reader opens on (by index).
struct FocusedStep: Identifiable { let id: Int }

enum ActiveSheet: Identifiable {
    case planner, stylePicker, info(InfoTopic), selectionTips, prices
    var id: String {
        switch self {
        case .planner: return "planner"
        case .stylePicker: return "stylePicker"
        case .info(let t): return "info-\(t.id)"
        case .selectionTips: return "selectionTips"
        case .prices: return "prices"
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = DoughViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var prices = PriceStore.shared
    @State private var activeSheet: ActiveSheet?
    /// Whether the slide-in menu drawer is showing.
    @State private var menuOpen = false
    /// Card keys that are collapsed. Recipe proportions starts collapsed.
    @State private var collapsed: Set<String> = ["proportions"]
    /// First-run setup, shown until completed.
    @State private var showOnboarding = !OnboardingStore.completed
    /// The one-time feature walkthrough (also re-openable from Guides).
    @State private var showWalkthrough = false
    /// The occasional floating popup — a coaching tip or a pizza joke.
    @State private var showJoke = false
    @State private var jokeText = ""
    @State private var popupIsTip = false
    /// A feature nudge (vs a tip/joke) — drawn in its own colour.
    @State private var popupIsFeature = false
    @State private var popupEmoji = "💡"
    /// The section nearest the top of the scroll, for contextual feature nudges.
    @State private var currentSection = ""
    /// Feature nudges already shown this session (each fires once).
    @State private var shownFeatureTips: Set<String> = []
    /// Hold off contextual nudges until the screen has settled after launch.
    @State private var nudgesReady = false
    @State private var jokeTicks = 0
    /// Indices of cooking-direction steps marked done (faded + struck through).
    @State private var completedSteps: Set<Int> = []
    /// A step shown full-screen after a tap (swipe between steps from there).
    @State private var focusedStep: FocusedStep?
    /// Confirmation before scrapping the in-progress bake.
    @State private var confirmCancelBake = false
    /// Brief "Saved as Favourite" confirmation toast.
    @State private var showSavedToast = false
    private let jokeTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    /// Keeps "now" live so Start/Ready times track the real clock.
    @Environment(\.scenePhase) private var scenePhase
    /// Compact height = landscape on iPhone → the full-screen step-by-step mode.
    @Environment(\.verticalSizeClass) private var vSize
    private let clockTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        if vm.kidMode {
            KidModeView(vm: vm)
        } else if vSize == .compact {
            LandscapeStepsView(vm: vm,
                               completed: $completedSteps,
                               onToggle: { toggleStepDone($0) })
        } else {
            portraitContent
        }
    }

    private var portraitContent: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            if Palette.isVibrant { GinghamBackground() }

            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    header
                    cookingBanner(proxy)
                    totalBanner(proxy)
                    recapChips(proxy)
                    ScrollView {
                        VStack(spacing: 18) {
                            if vm.input.keepItSimple {
                                simpleSetupCard
                                    .id("sec-setup")
                                    .background(sectionTracker("setup"))
                                StyleHeroImage(style: vm.input.style)
                                    .id("heroImage")
                                ResultView(result: vm.result, metric: vm.metric,
                                           toppingLines: vm.toppingLines(),
                                           showPizzaCounts: vm.selectedPizzaTotal > 1,
                                           extras: vm.selectedExtras,
                                           hasSelection: vm.selectedPizzaTotal > 0,
                                           shareText: vm.shareText(),
                                           onPlan: { activeSheet = .planner },
                                           costTotal: costStrings.total,
                                           costPerPizza: costStrings.perPizza,
                                           currencyCode: Locale.current.currency?.identifier ?? "USD",
                                           onEditPrices: { activeSheet = .prices })
                                    .id("summary")
                                    .background(sectionTracker("summary"))
                                simpleDirectionsCard
                                    .id("directions")
                                    .background(sectionTracker("directions"))
                            } else {
                                styleSection
                                    .id("sec-style")
                                    .background(sectionTracker("setup"))
                                sizeSection
                                    .id("sec-size")
                                scheduleSection
                                    .id("sec-schedule")
                                yeastSection
                                    .id("sec-yeast")
                                recipeDefaultsSection
                                    .id("sec-recipe")
                                StyleHeroImage(style: vm.input.style)
                                    .id("heroImage")
                                ResultView(result: vm.result, metric: vm.metric,
                                           toppingLines: vm.toppingLines(),
                                           showPizzaCounts: vm.selectedPizzaTotal > 1,
                                           extras: vm.selectedExtras,
                                           hasSelection: vm.selectedPizzaTotal > 0,
                                           shareText: vm.shareText(),
                                           onPlan: { activeSheet = .planner },
                                           costTotal: costStrings.total,
                                           costPerPizza: costStrings.perPizza,
                                           currencyCode: Locale.current.currency?.identifier ?? "USD",
                                           onEditPrices: { activeSheet = .prices })
                                    .id("summary")
                                    .background(sectionTracker("summary"))
                                directionsSection
                                    .id("directions")
                                    .background(sectionTracker("directions"))
                            }

                            footnote
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                        .padding(.bottom, 40)
                    }
                    .coordinateSpace(name: "kpScroll")
                    .onPreferenceChange(SectionOffsetKey.self) { offsets in
                        updateCurrentSection(offsets)
                    }
                }
            }

            menuOverlay
            jokeOverlay
            savedToast
        }
        .id(themeManager.theme)   // rebuild the whole tree so a theme switch re-skins fully
        .tint(Palette.accent)
        .preferredColorScheme(nil)
        .onChange(of: vm.input.humourEnabled) { _, _ in
            if !vm.input.humourEnabled && !vm.input.tipsEnabled { withAnimation(.easeInOut) { showJoke = false } }
        }
        .onChange(of: vm.input.tipsEnabled) { _, _ in
            if !vm.input.humourEnabled && !vm.input.tipsEnabled { withAnimation(.easeInOut) { showJoke = false } }
        }
        .onReceive(clockTimer) { _ in vm.refreshNow() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { vm.refreshNow() }
        }
        .onReceive(jokeTimer) { _ in
            let tips = vm.input.tipsEnabled
            let humour = vm.input.humourEnabled
            guard tips || humour, !menuOpen, activeSheet == nil, !showJoke else { return }
            jokeTicks += 1
            guard jokeTicks >= vm.input.humourLevel.ticksBetween else { return }
            jokeTicks = 0
            // Tip or joke: both if available, else whichever is on.
            let useTip = (tips && humour) ? Bool.random() : tips
            if useTip {
                // Roughly two in five "tips" are instead a Did-You-Know fact,
                // biased to the style the baker is making.
                if Int.random(in: 0..<5) < 2 {
                    jokeText = Facts.random(styleID: vm.input.style.id)
                    popupEmoji = "📖"
                } else {
                    jokeText = Tips.random(simpleMode: vm.input.keepItSimple, glutenFree: vm.input.glutenFree)
                    popupEmoji = "💡"
                }
                popupIsTip = true
                popupIsFeature = false
            } else {
                jokeText = Jokes.randomGeneral()
                popupIsTip = false
                popupIsFeature = false
                popupEmoji = "🍕"
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { showJoke = true }
            Task {
                try? await Task.sleep(nanoseconds: 7_000_000_000)
                withAnimation(.easeInOut) { showJoke = false }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true   // no auto-lock
            // Pick up an unfinished bake's ticked steps where we left off.
            if let bake = vm.activeBake { completedSteps = Set(bake.completedSteps) }
            maybeShowWalkthrough()   // returning users meet the new tips once
            // Arm contextual nudges only after things settle, so they don't fire
            // on the initial layout or clash with the walkthrough.
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                nudgesReady = true
            }
            vm.refreshNow()
            vm.rescheduleNotifications()
            // Recipe proportions: open by default in advanced, closed in simple.
            if vm.input.keepItSimple { collapsed.insert("proportions") }
            else { collapsed.remove("proportions") }
            // Simple mode auto-sizes to a forgiving, biggest-within-tolerance ball.
            if vm.input.keepItSimple && vm.input.style.shape == .round {
                vm.input.ballWeight = 280
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: currentSection) { _, section in
            showFeatureNudge(section)
        }
        .onChange(of: vm.schedule.start) { _, _ in
            vm.rescheduleNotifications()
            // A new plan resets the done-ticks — but never mid-bake, where a
            // shifting start time would otherwise wipe the cook's progress.
            if vm.activeBake == nil { completedSteps.removeAll() }
        }
        .onChange(of: vm.input.keepItSimple) { _, simple in
            if simple {
                // The style takes over sizing, and the default plan becomes
                // a Quick proof ready in 12 hours. Simple mode also adopts the
                // friendly Vibrant look.
                vm.input.sizeMode = .weight
                vm.input.ballWeight = vm.input.style.shape == .round ? 280 : vm.input.style.defaultBallWeight
                vm.applySimpleProofDefault()
                themeManager.theme = .fun
                // Simple mode hides the section anyway — keep it closed.
                collapsed.insert("proportions")
            } else {
                // Advanced mode reveals the recipe proportions, open by default.
                collapsed.remove("proportions")
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .planner:
                RecipePlannerView(vm: vm)
            case .stylePicker:
                StylePickerView(vm: vm)
            case .info(let topic):
                InfoSheet(topic: topic, humourEnabled: vm.input.humourEnabled)
            case .selectionTips:
                SelectionTipsSheet(input: vm.input)
            case .prices:
                PriceListView()
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(vm: vm, onDone: { showOnboarding = false; maybeShowWalkthrough() })
        }
        .sheet(isPresented: $showWalkthrough) {
            WalkthroughView()
        }
        .sheet(item: $focusedStep) { focus in
            StepFocusView(steps: vm.schedule.steps,
                          startIndex: focus.id,
                          itemsFor: { vm.stepItems(for: $0) },
                          metric: vm.metric,
                          now: vm.now)
        }
        .confirmationDialog("Finished cooking?", isPresented: $confirmCancelBake, titleVisibility: .visible) {
            Button("Yes, all done") {
                completedSteps.removeAll()
                vm.cancelBake()
            }
            Button("Not yet — keep cooking", role: .cancel) { }
        } message: {
            Text("This clears the current bake and goes back to your favourite.")
        }
    }

    // MARK: Currently-cooking banner

    /// A sticky yellow banner for an in-progress bake — tap to jump to the step
    /// you're on, or cancel to scrap it and return to the favourite.
    @ViewBuilder private func cookingBanner(_ proxy: ScrollViewProxy) -> some View {
        if let bake = vm.activeBake {
            let done = min(completedSteps.count, bake.totalSteps)
            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    // Jump to the first step not yet ticked off — the one you're on.
                    let current = min(completedSteps.count, max(bake.totalSteps - 1, 0))
                    collapsed.remove("directions")   // make sure it's open in advanced mode
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        proxy.scrollTo("step-\(current)", anchor: .top)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .font(.rounded(18, weight: .bold))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("CURRENTLY COOKING")
                                .font(.rounded(11, weight: .bold))
                                .foregroundStyle(.black.opacity(0.55))
                            Text("\(vm.input.style.name) · \(done) of \(bake.totalSteps) steps done")
                                .font(.rounded(14, weight: .bold))
                                .foregroundStyle(.black.opacity(0.85))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Spacer()
                    }
                    .foregroundStyle(.black.opacity(0.85))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.tap()
                    confirmCancelBake = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.rounded(22, weight: .medium))
                        .foregroundStyle(.black.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Palette.amber)
            )
            .shadow(color: Palette.shadowDark, radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func showInfo(_ topic: InfoTopic) { activeSheet = .info(topic) }

    /// A clear-rectangle that reports a section's top offset within the scroll.
    private func sectionTracker(_ id: String) -> some View {
        GeometryReader { geo in
            Color.clear.preference(key: SectionOffsetKey.self,
                                   value: [id: geo.frame(in: .named("kpScroll")).minY])
        }
    }

    /// The section nearest the top of the viewport becomes the "current" one.
    private func updateCurrentSection(_ offsets: [String: CGFloat]) {
        let line: CGFloat = 140   // a little below the very top
        let reached = offsets.filter { $0.value <= line }
        let pick = reached.max(by: { $0.value < $1.value })?.key
                ?? offsets.min(by: { $0.value < $1.value })?.key
        if let pick, pick != currentSection { currentSection = pick }
    }

    /// Pop a contextual "did you know?" nudge for the section just reached —
    /// each fires at most once per session, and only when nothing else is up.
    private func showFeatureNudge(_ section: String) {
        guard nudgesReady, vm.input.tipsEnabled,
              !showJoke, !menuOpen, activeSheet == nil,
              !showWalkthrough, !showOnboarding, !section.isEmpty,
              let tip = FeatureTips.contextual(for: section, excluding: shownFeatureTips)
        else { return }
        shownFeatureTips.insert(tip.id)
        jokeText = "Did you know? " + (tip.nudge ?? tip.blurb)
        popupEmoji = "👉"
        popupIsTip = true
        popupIsFeature = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { showJoke = true }
        Task {
            try? await Task.sleep(nanoseconds: 14_000_000_000)   // longer — more to read, and you can tap to dismiss
            withAnimation(.easeInOut) { showJoke = false }
        }
    }

    /// Show the feature walkthrough once, after onboarding — a gentle intro to
    /// the gestures and shortcuts. Re-openable any time from Guides & Info.
    private func maybeShowWalkthrough() {
        guard OnboardingStore.completed, !showOnboarding,
              !WalkthroughStore.seen, !showWalkthrough, activeSheet == nil else { return }
        WalkthroughStore.seen = true
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)   // let the screen settle first
            showWalkthrough = true
        }
    }

    /// A brief confirmation that flashes when the favourite is saved/updated.
    @ViewBuilder private var savedToast: some View {
        if showSavedToast {
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                    Text("Saved as Favourite")
                }
                .font(.rounded(15, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Palette.accentFill))
                .shadow(color: Palette.shadowDark, radius: 12, x: 0, y: 6)
                .padding(.top, 64)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .allowsHitTesting(false)
        }
    }

    private func flashSavedToast() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showSavedToast = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut) { showSavedToast = false }
        }
    }

    /// Pre-formatted estimated-cost strings for the summary (local currency).
    private var costStrings: (total: String, perPizza: String) {
        let c = vm.estimatedCost()
        return (moneyString(c.total), moneyString(c.perPizza))
    }

    private func openMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { menuOpen = true }
        Haptics.tap()
    }
    private func closeMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { menuOpen = false }
    }

    // MARK: Slide-in menu

    @ViewBuilder
    private var menuOverlay: some View {
        if menuOpen {
            Color.black.opacity(0.32)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { closeMenu() }

            HStack(spacing: 0) {
                Spacer(minLength: 0)
                MenuDrawer(vm: vm, onClose: { closeMenu() },
                           onReintro: {
                               closeMenu()
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showOnboarding = true }
                           })
                    .frame(maxWidth: 380)
                    .frame(maxHeight: .infinity)
                    .background(Palette.background.ignoresSafeArea())
                    .transition(.move(edge: .trailing))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 60 { closeMenu() }
                            }
                    )
            }
        }
    }

    // MARK: Floating pizza joke

    @ViewBuilder
    private var jokeOverlay: some View {
        if showJoke {
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showJoke = false }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Text(popupEmoji).font(.system(size: 30))
                        Text(jokeText)
                            .font(.rounded(13, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Image(systemName: "xmark.circle.fill")
                            .font(.rounded(16))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(popupIsFeature ? AnyShapeStyle(Palette.cool) : AnyShapeStyle(Palette.accentFill))
                    )
                    .shadow(color: Palette.shadowDark, radius: 14, x: 0, y: 7)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(2)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("🍕 Kneady Pizza")
                .font(.rounded(22, weight: .bold))
                .foregroundStyle(Palette.text)
            Spacer()
            HStack(spacing: 4) {
                Button {
                    vm.saveFavourite()      // one-tap update of My Favourite
                    Haptics.success()
                    flashSavedToast()
                } label: {
                    Image(systemName: vm.hasFavourite ? "star.fill" : "star")
                        .font(.rounded(16, weight: .medium))
                        .foregroundStyle(Palette.amber)
                        .frame(width: 36, height: 40)
                }
                .buttonStyle(.plain)
                Button {
                    activeSheet = .planner
                    Haptics.tap()
                } label: {
                    Image(systemName: "basket.fill")
                        .font(.rounded(18, weight: .medium))
                        .foregroundStyle(Palette.accent)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                ShareMenuButton(shareText: vm.shareText(), iconSize: 19)
                    .frame(width: 40, height: 40)
                Button {
                    openMenu()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.rounded(20, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    // Always-visible total — tap to jump to the pizza image & summary; the
    // lightbulb gives tailored tips.
    private func totalBanner(_ proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 10) {
            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    // Jump straight to the Cooking Directions.
                    proxy.scrollTo("directions", anchor: .top)
                }
            } label: {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Total dough")
                            .font(.rounded(12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                            Text("\(Scheduler.durationShort(vm.schedule.totalHours)) prep · \(Scheduler.durationShort(vm.schedule.leadHours)) serve")
                        }
                        .font(.rounded(11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    }
                    Spacer()
                    Text(Units.weight(vm.result.totalWeight, metric: vm.metric))
                        .font(.rounded(18, weight: .bold))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(value: vm.result.totalWeight))
                        .animation(Palette.isVibrant ? .snappy(duration: 0.5) : nil,
                                   value: vm.result.totalWeight)
                    Text("· \(vm.input.ballCount) × \(Units.weight(vm.result.ballWeight, metric: vm.metric))")
                        .font(.rounded(12))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                Haptics.tap()
                activeSheet = .selectionTips
            } label: {
                Image(systemName: "lightbulb.fill")
                    .font(.rounded(20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.accent)
        )
        .shadow(color: Palette.shadowDark, radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: Recap chip-strip

    private struct RecapItem: Identifiable { let id: String; let label: String; let anchor: String }

    /// Live recap of the current choices — tap a chip to jump to its section.
    private var recapItems: [RecapItem] {
        let i = vm.input
        let simple = i.keepItSimple
        let styleAnchor = simple ? "sec-setup" : "sec-style"
        let noun = i.ballCount == 1 ? i.style.shape.noun : i.style.shape.nounPlural
        var items: [RecapItem] = [
            .init(id: "style", label: "\(i.style.originFlag) \(i.style.name)", anchor: styleAnchor),
            .init(id: "size", label: "\(i.ballCount) \(noun)", anchor: simple ? "sec-setup" : "sec-size"),
        ]
        if i.glutenFree { items.append(.init(id: "gf", label: "Gluten free", anchor: styleAnchor)) }
        items.append(.init(id: "proof", label: i.ferment.label, anchor: simple ? "sec-setup" : "sec-schedule"))
        if !simple {
            items.append(.init(id: "yeast", label: i.yeast.fullName, anchor: "sec-yeast"))
            if i.prefermentAvailable {
                items.append(.init(id: "pref", label: i.usePreferment ? i.preferment.name : "Direct", anchor: "sec-yeast"))
            }
            if i.autolyseActive {
                items.append(.init(id: "auto", label: "Autolyse", anchor: "sec-yeast"))
            }
            items.append(.init(id: "hyd", label: "\(Int((i.hydration * 100).rounded()))% hyd", anchor: "sec-recipe"))
        }
        return items
    }

    @ViewBuilder private func recapChips(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(recapItems) { item in
                    Button {
                        Haptics.tap()
                        // Expand the target so it isn't collapsed when you land.
                        if let key = collapseKey(forAnchor: item.anchor) { collapsed.remove(key) }
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            proxy.scrollTo(item.anchor, anchor: .top)
                        }
                    } label: {
                        Text(item.label)
                            .font(.rounded(11, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                            .lineLimit(1)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Palette.accent.opacity(0.12)))
                            .overlay(Capsule().stroke(Palette.accent.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func toggle(_ key: String) {
        if collapsed.contains(key) { collapsed.remove(key) } else { collapsed.insert(key) }
    }

    /// The collapse key behind a chip's anchor (so tapping a chip expands it).
    private func collapseKey(forAnchor anchor: String) -> String? {
        switch anchor {
        case "sec-style": return "style"
        case "sec-size": return "size"
        case "sec-schedule": return "schedule"
        case "sec-yeast": return "yeast"
        case "sec-recipe": return "proportions"
        default: return nil
        }
    }

    // MARK: 1 — Style

    private var styleSection: some View {
        InputCard(index: 1, title: SectionCopy.title("Pizza style"), info: styleInfo, onInfo: showInfo,
                  summary: vm.input.style.name,
                  collapsed: collapsed.contains("style"),
                  onToggleCollapse: { toggle("style") }) {
            styleControls
        }
    }

    /// The style picker button alone (no blurb).
    @ViewBuilder private var styleDropdownButton: some View {
        // While a bake is underway the picker is locked, so you can't wander off
        // and change pizza mid-cook — it just shows what you're making.
        if vm.activeBake == nil {
            Button {
                activeSheet = .stylePicker
                Haptics.tap()
            } label: {
                styleDropdownLabel(locked: false)
            }
            .buttonStyle(.plain)
        } else {
            styleDropdownLabel(locked: true)
        }
    }

    private func styleDropdownLabel(locked: Bool) -> some View {
        HStack(spacing: 10) {
            Text(vm.input.style.originFlag)
                .font(.system(size: 18))
            Text(vm.input.style.name)
                .font(.rounded(18, weight: .bold))
                .foregroundStyle(.black.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            shapeBadge(vm.input.style.shape, isOn: false)
            Spacer(minLength: 8)
            Image(systemName: locked ? "lock.fill" : "chevron.up.chevron.down")
                .font(.rounded(13, weight: .bold))
                .foregroundStyle(.black.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.amber)
        )
        .shadow(color: Palette.shadowDark, radius: 6, x: 0, y: 3)
    }

    /// The style picker button and its one-line blurb (used in full mode).
    @ViewBuilder private var styleControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            styleDropdownButton
            Text(vm.input.style.blurb)
                .font(.rounded(12))
                .foregroundStyle(Palette.textSoft)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            glutenFreeControls
        }
    }

    /// The gluten-free toggle, its info button, and (when on) the binder choice
    /// and a per-style viability note.
    @ViewBuilder private var glutenFreeControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Gluten free")
                    .font(.rounded(15, weight: .medium))
                    .foregroundStyle(Palette.text)
                Button { showInfo(.glutenFree); Haptics.tap() } label: {
                    Image(systemName: "info.circle")
                        .font(.rounded(15, weight: .medium))
                        .foregroundStyle(Palette.accent)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { vm.input.glutenFree },
                    set: { vm.setGlutenFree($0) }
                ))
                .labelsHidden()
                .tint(Palette.accent)
            }

            if vm.input.glutenFree {
                Text(vm.input.style.glutenFreeViability.note)
                    .font(.rounded(11))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    Text("BINDER")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    Button { showInfo(.binder); Haptics.tap() } label: {
                        Image(systemName: "info.circle")
                            .font(.rounded(13, weight: .medium))
                            .foregroundStyle(Palette.accent)
                    }
                    .buttonStyle(.plain)
                }
                TactileSegmented(
                    options: BinderType.allCases,
                    selection: Binding(get: { vm.input.binder },
                                       set: { vm.input.binder = $0 })
                ) { $0.label }

                TactileToggle(
                    title: "Binder already in my blend",
                    subtitle: "Many shop-bought gluten-free flours already contain xanthan or psyllium. Turn this on to stop the app adding more (which makes the crust gummy).",
                    isOn: Binding(get: { vm.input.binderInBlend },
                                  set: { vm.input.binderInBlend = $0 })
                )
            }
        }
        .padding(.top, 4)
    }

    /// The style info sheet — the full, lengthier description plus its gotcha.
    private var styleInfo: InfoTopic {
        let style = vm.input.style
        return InfoTopic(
            id: "style-\(style.id)",
            title: style.name,
            body: "\(style.details)\n\nMaths: this style seeds the baker's percentages — \(Int((style.hydration * 100).rounded()))% hydration\(style.defaultPreferment == .none ? "" : ", a \(style.defaultPreferment.label.lowercased())") — that every other number is built from.",
            gotcha: InfoTopic.style.gotcha
        )
    }

    private func shapeBadge(_ shape: PizzaShape, isOn: Bool) -> some View {
        Text(shape.label)
            .font(.rounded(10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(isOn ? Color.white.opacity(0.25) : Palette.accent.opacity(0.14)))
            .foregroundStyle(isOn ? Color.white : Palette.accent)
    }

    // MARK: 2 — Pizzas & size

    private func sizeModeLabel(_ mode: SizeMode) -> String {
        if mode == .diameter { return shape == .round ? "Pizza Size" : "Pan Size" }
        return shape == .round ? "Ball Weight" : "Pan Weight"
    }

    private var sizeSection: some View {
        InputCard(index: 2, title: SectionCopy.title("Pizzas & size"), info: .size, onInfo: showInfo,
                  summary: sizeSummary,
                  collapsed: collapsed.contains("size"),
                  onToggleCollapse: { toggle("size") }) {
            VStack(spacing: 18) {
                TactileStepper(
                    title: vm.input.keepItSimple ? (shape == .round ? "How many pizzas?" : "How many pans?") : (shape == .round ? "Dough balls" : "Pans"),
                    value: $vm.input.ballCount,
                    range: 1...30
                )

                if vm.input.keepItSimple {
                    Text("Each \(shape.noun) is sized automatically for \(vm.input.style.name) — about \(Units.weight(vm.input.style.defaultBallWeight, metric: vm.metric)). Turn off “Keep it simple” in the menu to set it yourself.")
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                Divider().overlay(Palette.textSoft.opacity(0.15))

                TactileSegmented(
                    options: [.weight, .diameter],
                    selection: $vm.input.sizeMode,
                    label: sizeModeLabel
                )

                let guidance = DoughCalculator.guidance(forBall: DoughCalculator.ballWeight(for: vm.input), shape: shape)
                let weightStr = Units.weight(DoughCalculator.ballWeight(for: vm.input), metric: vm.metric)

                if vm.input.sizeMode == .diameter {
                    if shape == .round {
                        let range: ClosedRange<Double> = vm.input.lengthUnit == .cm ? 15...45 : 6...18
                        TactileSlider(
                            title: "Diameter",
                            value: $vm.input.diameter,
                            range: range,
                            step: vm.input.lengthUnit == .cm ? 1 : 0.5,
                            valueText: lengthText(vm.input.diameter),
                            tint: guidance.color,
                            caption: "≈ \(weightStr) per \(shape.noun) · \(guidance.message)"
                        )
                    } else {
                        let lr: ClosedRange<Double> = vm.input.lengthUnit == .cm ? 20...45 : 8...18
                        let wr: ClosedRange<Double> = vm.input.lengthUnit == .cm ? 15...40 : 6...16
                        TactileSlider(
                            title: "Length",
                            value: $vm.input.panLength,
                            range: lr,
                            step: vm.input.lengthUnit == .cm ? 1 : 0.5,
                            valueText: lengthText(vm.input.panLength)
                        )
                        TactileSlider(
                            title: "Width",
                            value: $vm.input.panWidth,
                            range: wr,
                            step: vm.input.lengthUnit == .cm ? 1 : 0.5,
                            valueText: lengthText(vm.input.panWidth),
                            caption: "≈ \(weightStr) of dough per pan"
                        )
                    }
                } else {
                    let wRange: ClosedRange<Double> = shape == .round ? 150...400 : 300...1500
                    TactileSlider(
                        title: shape == .round ? "Weight per ball" : "Weight per pan",
                        value: $vm.input.ballWeight,
                        range: wRange,
                        step: 5,
                        valueText: Units.weight(vm.input.ballWeight, metric: vm.metric),
                        tint: guidance.color,
                        caption: "How heavy each \(shape.noun) should be · \(guidance.message)"
                    )
                }
                }
            }
        }
    }

    // MARK: 3 — Yeast

    private var yeastSection: some View {
        InputCard(index: 4, title: SectionCopy.title("Yeast or starter"), info: .yeast, onInfo: showInfo,
                  summary: yeastSummary,
                  collapsed: collapsed.contains("yeast"),
                  onToggleCollapse: { toggle("yeast") }) {
            VStack(spacing: 14) {
                TactileSegmented(
                    options: vm.input.style.yeasts,
                    selection: $vm.input.yeast
                ) { $0.rawValue }

                Text("\(vm.input.yeast.fullName) · \(Units.weight(yeastGrams, metric: vm.metric)) · suited to \(vm.input.style.name)")
                    .font(.rounded(13))
                    .foregroundStyle(Palette.textSoft)

                if vm.input.prefermentAvailable {
                    Divider().overlay(Palette.textSoft.opacity(0.15))

                    HStack(spacing: 6) {
                        Text("Pre-ferment")
                            .font(.rounded(16))
                            .foregroundStyle(Palette.text)
                        Button { showInfo(.preferment) } label: {
                            Image(systemName: "info.circle")
                                .font(.rounded(14, weight: .medium))
                                .foregroundStyle(Palette.accent)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    TactileSegmented(
                        options: PrefermentChoice.allCases,
                        selection: prefermentChoice
                    ) { $0.label }

                    if vm.input.usePreferment {
                        Text(vm.input.preferment.blurb)
                            .font(.rounded(12))
                            .foregroundStyle(Palette.textSoft)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        let pg = DoughCalculator.prefermentGuidance(vm.input.preferment, value: vm.input.prefermentPct)
                        TactileSlider(
                            title: "\(vm.input.preferment.name) proportion",
                            value: $vm.input.prefermentPct,
                            range: 0.10...1.00,
                            step: 0.05,
                            valueText: pct(vm.input.prefermentPct),
                            tint: pg.color,
                            caption: "Share of the total flour pre-fermented."
                        )
                        if pg.level != .ideal {
                            HStack(spacing: 5) {
                                Image(systemName: pg.level == .warning ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                Text(pg.message)
                            }
                            .font(.rounded(11, weight: .medium))
                            .foregroundStyle(pg.color)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if vm.input.yeast.isSourdough {
                    Text("Sourdough is itself a pre-ferment, so a poolish or biga isn't used here.")
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("A \(vm.input.ferment.label) dough is too fast for a pre-ferment — it's skipped. Switch to Warm or Cold to use a poolish or biga.")
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider().overlay(Palette.textSoft.opacity(0.15))

                if vm.input.autolyseAvailable {
                    HStack(spacing: 6) {
                        TactileToggle(
                            title: "Autolyse first",
                            subtitle: "Rest flour & water alone for ~30 min before adding salt & yeast — easier to stretch.",
                            isOn: $vm.input.useAutolyse
                        )
                        Button { showInfo(.autolyse) } label: {
                            Image(systemName: "info.circle")
                                .font(.rounded(14, weight: .medium))
                                .foregroundStyle(Palette.accent)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text("A Quick dough skips the autolyse — the warm-water mix gets things going fast instead. Switch to Warm or Cold to use one.")
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: 4 — Recipe proportions

    private var recipeDefaultsSection: some View {
        let r = vm.result
        let s = r.prefermentSplit
        let divisor = 1 + vm.input.hydration + vm.input.salt + vm.input.oil + vm.input.honey
        let flour = divisor > 0 ? r.totalWeight / divisor : 0

        // Collapsed summary: every proportion at a glance, not just hydration.
        func pc(_ v: Double) -> String {
            let r = (v * 1000).rounded() / 10        // one decimal place
            return r == r.rounded() ? "\(Int(r))%" : String(format: "%.1f%%", r)
        }
        var proportionsSummary = "\(Int((vm.input.hydration * 100).rounded()))% hydration · \(pc(vm.input.salt)) salt"
        if vm.input.oil   > 0 { proportionsSummary += " · \(pc(vm.input.oil)) oil" }
        if vm.input.honey > 0 { proportionsSummary += " · \(pc(vm.input.honey)) honey" }

        return InputCard(index: 5, title: SectionCopy.title("Dough Proportions"), info: .recipe, onInfo: showInfo,
                  summary: proportionsSummary,
                  collapsed: collapsed.contains("proportions"),
                  onToggleCollapse: { toggle("proportions") }) {
            VStack(alignment: .leading, spacing: 12) {
                if let s { stageLegend(name: s.name) }

                // Flour (derived, not adjustable)
                VStack(spacing: 5) {
                    HStack {
                        Text("Flour")
                            .font(.rounded(16))
                            .foregroundStyle(Palette.text)
                        Spacer()
                        Text("≈ \(grams(flour))")
                            .font(.rounded(17, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                            .contentTransition(.numericText())
                    }
                    if let s { splitLine(name: s.name, preferment: s.prefermentFlour, dough: s.finalFlour) }
                }

                proportionBlock(title: "Water", value: $vm.input.hydration,
                                range: 0.50...0.95, step: 0.01,
                                grams: flour * vm.input.hydration,
                                guidance: DoughCalculator.proportionGuidance(.water, value: vm.input.hydration, style: vm.input.style, glutenFree: vm.input.glutenFree),
                                name: s?.name, preferment: s?.prefermentWater, dough: s?.finalWater)
                proportionBlock(title: "Salt", value: $vm.input.salt,
                                range: 0...0.05, step: 0.001,
                                grams: flour * vm.input.salt,
                                guidance: DoughCalculator.proportionGuidance(.salt, value: vm.input.salt, style: vm.input.style),
                                finalDoughOnly: true)
                proportionBlock(title: "Olive oil", value: $vm.input.oil,
                                range: 0...0.10, step: 0.001,
                                grams: flour * vm.input.oil,
                                guidance: DoughCalculator.proportionGuidance(.oil, value: vm.input.oil, style: vm.input.style),
                                finalDoughOnly: true)
                proportionBlock(title: "Honey", value: $vm.input.honey,
                                range: 0...0.05, step: 0.001,
                                grams: flour * vm.input.honey,
                                guidance: DoughCalculator.proportionGuidance(.honey, value: vm.input.honey, style: vm.input.style),
                                finalDoughOnly: true)

                Text("Percentages are of flour weight (baker's %).")
                    .font(.rounded(11))
                    .foregroundStyle(Palette.textSoft)
            }
        }
    }

    private func stageLegend(name: String) -> some View {
        Text("Two stages: the \(name.lowercased()) takes only flour & water; salt, oil and honey join the final dough.")
            .font(.rounded(11))
            .foregroundStyle(Palette.textSoft)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func proportionBlock(title: String, value: Binding<Double>,
                                 range: ClosedRange<Double>, step: Double,
                                 grams gramValue: Double,
                                 guidance: WeightGuidance,
                                 name: String? = nil,
                                 preferment: Double? = nil, dough: Double? = nil,
                                 finalDoughOnly: Bool = false) -> some View {
        VStack(spacing: 4) {
            TactileSlider(title: title, value: value, range: range, step: step,
                          valueText: "\(pct(value.wrappedValue)) · \(grams(gramValue))",
                          tint: guidance.color)
            if let preferment, let dough {
                splitLine(name: name ?? "Pre-ferment", preferment: preferment, dough: dough)
            }
            if guidance.level != .ideal {
                HStack(spacing: 5) {
                    Image(systemName: guidance.level == .warning ? "exclamationmark.triangle.fill" : "info.circle.fill")
                    Text(guidance.message)
                }
                .font(.rounded(11, weight: .medium))
                .foregroundStyle(guidance.color)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// "Poolish 121 g + Dough 261 g = 382 g" — same rounded font, two-column feel.
    private func splitLine(name: String, preferment: Double, dough: Double) -> some View {
        HStack(spacing: 5) {
            Text("\(name) \(grams(preferment))").foregroundStyle(Palette.sage)
            Text("+").foregroundStyle(Palette.textSoft)
            Text("Dough \(grams(dough))").foregroundStyle(Palette.text)
            Text("=").foregroundStyle(Palette.textSoft)
            Text(grams(preferment + dough)).foregroundStyle(Palette.accent)
            Spacer()
        }
        .font(.rounded(12, weight: .medium))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }

    private func captionLine(_ s: String) -> some View {
        Text(s)
            .font(.rounded(12))
            .foregroundStyle(Palette.textSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: 5 — Schedule

    /// Schedule/Directions renumber when the simple-mode cards are hidden.
    private var idxSchedule: Int { 3 }
    private var idxDirections: Int { vm.input.keepItSimple ? 4 : 6 }

    private var scheduleSection: some View {
        InputCard(index: idxSchedule, title: SectionCopy.title("When will you serve?"), info: .schedule, onInfo: showInfo,
                  summary: scheduleSummary,
                  collapsed: collapsed.contains("schedule"),
                  onToggleCollapse: { toggle("schedule") }) {
            VStack(alignment: .leading, spacing: 14) {
                fermentationControl
                Divider().overlay(Palette.textSoft.opacity(0.15))
                serveTimeControl
                startSummaryLine()
            }
        }
    }

    /// Fermentation segmented picker + its blurb.
    @ViewBuilder private var fermentationControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fermentation")
                .font(.rounded(13, weight: .semibold))
                .foregroundStyle(Palette.textSoft)
            TactileSegmented(
                options: FermentStyle.allCases,
                selection: fermentChoice
            ) { $0.label }
            Text(vm.input.ferment.blurb)
                .font(.rounded(12))
                .foregroundStyle(Palette.textSoft)
                .fixedSize(horizontal: false, vertical: true)
            soonestLine
        }
    }

    /// "Soonest from now — Quick … · Warm … · Cold …" — shared by both layouts.
    @ViewBuilder private var soonestLine: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.badge.checkmark")
            Text("Soonest from now — Quick \(Scheduler.durationShort(vm.soonestReady(.quick))) · Warm \(Scheduler.durationShort(vm.soonestReady(.sameDay))) · Cold \(Scheduler.durationShort(vm.soonestReady(.cold)))")
        }
        .font(.rounded(11, weight: .medium))
        .foregroundStyle(Palette.sage)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }

    /// The "Ready in" slider (quick) or "Serve at" date picker (warm/cold).
    @ViewBuilder private var serveTimeControl: some View {
        if vm.input.ferment == .quick {
            TactileSlider(
                title: "Ready in",
                value: readyInHours,
                range: 1...24,
                step: 0.5,
                valueText: Scheduler.duration(readyInHours.wrappedValue)
            )
        } else {
            HStack {
                Text("Ready")
                    .font(.rounded(16))
                    .foregroundStyle(Palette.text)
                Spacer()
                DatePicker(
                    "",
                    selection: $vm.input.serveDate,
                    in: vm.now...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "en_GB"))   // 24-hour
            }
        }
    }

    /// "Start … · total" plus the "too tight" warning. Pass `info` to tuck an
    /// info button onto the end of the line (used by the chrome-free simple card).
    @ViewBuilder private func startSummaryLine(info: InfoTopic? = nil) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "play.circle.fill")
                .foregroundStyle(Palette.sage)
            Text("Start")
                .foregroundStyle(Palette.textSoft)
            Text(Scheduler.clock(vm.schedule.start, now: vm.now))
                .font(.rounded(15, weight: .semibold))
                .foregroundStyle(Palette.text)
            Image(systemName: "arrow.right")
                .font(.rounded(12, weight: .semibold))
                .foregroundStyle(Palette.textSoft)
            Text("Ready")
                .foregroundStyle(Palette.textSoft)
            Text(Scheduler.clock(vm.schedule.serve, now: vm.now))
                .font(.rounded(15, weight: .semibold))
                .foregroundStyle(Palette.accent)
            Spacer(minLength: 4)
            if let info {
                Button { showInfo(info); Haptics.tap() } label: {
                    Image(systemName: "info.circle")
                        .font(.rounded(15, weight: .medium))
                        .foregroundStyle(Palette.accent)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .font(.rounded(14))
        .lineLimit(1)
        .minimumScaleFactor(0.65)

        if vm.schedule.autoAdjusted {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "wand.and.stars")
                Text("Auto-adjusted to fit your time: warmed the proof from \(Int(vm.input.temperatureC.rounded())) °C to about \(Int(vm.schedule.yeastTemp.rounded())) °C, and raised the yeast to match. Keep it somewhere cosy and it'll be ready when you are.")
            }
            .font(.rounded(12, weight: .medium))
            .foregroundStyle(Palette.accent)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        if vm.schedule.isTight {
            VStack(alignment: .leading, spacing: 8) {
                Text("Not enough time for a \(vm.input.ferment.label.lowercased()) rise — the plan is compressed and will be rushed.")
                    .font(.rounded(12))
                    .foregroundStyle(Palette.amber)
                    .fixedSize(horizontal: false, vertical: true)
                if vm.input.ferment != .quick {
                    Button {
                        vm.setFermentStyle(.quick)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text("Switch to a Quick dough")
                        }
                        .font(.rounded(14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(TactileButtonStyle(isProminent: true))
                }
            }
        }

        if vm.schedule.nightStepsRemain && vm.input.ferment != .cold {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "moon.zzz.fill")
                    Text("A hands-on step still lands overnight (10pm–6am). A Cold Proof parks the dough in the fridge so you can sleep through it.")
                }
                .font(.rounded(12, weight: .medium))
                .foregroundStyle(Palette.cool)
                .fixedSize(horizontal: false, vertical: true)
                Button {
                    vm.setFermentStyle(.cold)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "snowflake")
                        Text("Switch to a Cold Proof")
                    }
                    .font(.rounded(14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(TactileButtonStyle(isProminent: true))
            }
        }
    }

    // MARK: 6 — Directions (the timeline)

    private var directionsSection: some View {
        InputCard(index: idxDirections, title: SectionCopy.title("Cooking Directions"), info: .schedule, onInfo: showInfo,
                  summary: directionsSummary,
                  collapsed: collapsed.contains("directions"),
                  onToggleCollapse: { toggle("directions") }) {
            timelineView
        }
    }

    @ViewBuilder private var timelineView: some View {
        VStack(alignment: .leading, spacing: 14) {
            startBakeBar
            TimelineView(schedule: vm.schedule, now: vm.now,
                         onInfo: { step in activeSheet = .info(stepInfo(for: step)) },
                         itemsFor: { vm.stepItems(for: $0) },
                         toppingPlan: vm.toppingPlan(),
                         toppingAdvice: vm.toppingAdvice,
                         metric: vm.metric,
                         completed: completedSteps,
                         onToggleDone: { toggleStepDone($0) },
                         onExpand: { focusedStep = FocusedStep(id: $0) })
        }
    }

    /// Before a bake: a "Start baking now" button that locks the times. During a
    /// bake: a note that the times are pinned to the start.
    @ViewBuilder private var startBakeBar: some View {
        if vm.activeBake == nil {
            VStack(alignment: .leading, spacing: 6) {
                Button {
                    completedSteps.removeAll()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        vm.startBake()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Start baking now")
                    }
                    .font(.rounded(15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(TactileButtonStyle(isProminent: true))
                Text("Locks these times to your start, so they won't reset when you reopen the app.")
                    .font(.rounded(11))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                Text("Times locked to your start. Cancel from the banner up top to reset.")
            }
            .font(.rounded(11, weight: .medium))
            .foregroundStyle(Palette.sage)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Tap a step to mark it (and the steps before it) done; tap again to
    /// un-check it and the steps after it, leaving the earlier ones done.
    private func toggleStepDone(_ i: Int) {
        Haptics.tap()
        withAnimation(.easeInOut(duration: 0.2)) {
            if completedSteps.contains(i) {
                completedSteps = completedSteps.filter { $0 < i }   // clear i and everything below
            } else {
                for j in 0...i { completedSteps.insert(j) }          // mark i and everything above
            }
        }
        vm.recordBakeProgress(completed: completedSteps, totalSteps: vm.schedule.steps.count)
    }

    /// A step's info sheet — leads with *what the thing is* (poolish, autolyse,
    /// cold proof…) before the step's own instructions.
    private func stepInfo(for step: ScheduleStep) -> InfoTopic {
        let body: String
        if let concept = StepGuide.concept(step.title) {
            body = "\(concept)\n\nWhat to do now: \(step.detail)"
        } else {
            body = step.detail
        }
        return InfoTopic(id: "step-\(step.id)", title: step.title, body: body,
                         gotcha: step.gotcha.isEmpty ? [] : [step.gotcha],
                         tools: StepGuide.tools(step.title))
    }

    // MARK: Simple mode — two merged, chrome-free cards

    @ViewBuilder
    private func simpleCard<C: View>(title: String, info: InfoTopic,
                                     accessoryIcon: String? = nil, onAccessory: (() -> Void)? = nil,
                                     @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.rounded(15, weight: .semibold))
                    .foregroundStyle(Palette.textSoft)
                Spacer(minLength: 6)
                if let accessoryIcon {
                    Button { onAccessory?(); Haptics.tap() } label: {
                        Image(systemName: accessoryIcon)
                            .font(.rounded(16, weight: .medium))
                            .foregroundStyle(Palette.accent)
                            .frame(width: 34, height: 34)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Button { showInfo(info); Haptics.tap() } label: {
                    Image(systemName: "info.circle")
                        .font(.rounded(16, weight: .medium))
                        .foregroundStyle(Palette.accent)
                        .frame(width: 34, height: 34)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }

    /// Everything needed to decide, on one screen — no title, no chrome.
    /// The info button rides on the bottom "total" line to save space.
    private var simpleSetupCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            styleDropdownButton
            glutenFreeControls
            TactileStepper(title: vm.input.style.shape == .round ? "How many pizzas?" : "How many pans?", value: $vm.input.ballCount, range: 1...30)

            Divider().overlay(Palette.textSoft.opacity(0.15))

            TactileSegmented(
                options: FermentStyle.allCases,
                selection: fermentChoice
            ) { $0.label }
            soonestLine
            serveTimeControl
            startSummaryLine(info: simpleGuideInfo)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
    }

    /// One collective explainer for the simple-mode card — covers the style,
    /// the proof choices, and the behind-the-scenes terms a newcomer won't know.
    private var simpleGuideInfo: InfoTopic {
        let style = vm.input.style
        let body = """
        You've picked \(style.name) — \(style.blurb.lowercased())

        Proofing is the rise — letting the yeast slowly fill the dough with air. Pick one:
        • Quick — a fast, warm rise of about 3 hours, helped along by extra yeast and warm water. For pizza today, with a touch less depth of flavour.
        • Warm Proof — a rise at room temperature, usually somewhere between 8 and 24 hours depending on how warm your kitchen is. Simple, reliable and a good all-rounder.
        • Cold Proof — a long, slow rise in the fridge over 1–3 days. The most flavour and the lightest, most digestible crust, but it needs planning ahead.

        Set when you want to eat (or, for Quick, how soon) and the app counts backwards to tell you when to start. If the time you've left is too short for the proof you chose, it flags the plan as rushed and offers a "Switch to a Quick dough" button — tap it to swap to the fast method so it still fits, or give yourself more time / choose Cold or Warm for a calmer bake.

        Your style may also use, automatically:
        • A poolish or biga — a small batch of flour, water and a little yeast mixed ahead and left to ferment (around 12–16 hours), then added to the dough for more flavour and strength. A poolish is loose and wet; a biga is stiff.
        • An autolyse — a short ~30-minute rest of just flour and water before the salt and yeast go in, so the dough hydrates and stretches more easily.

        Tap the ⓘ beside any step in the Directions to learn what that step is.
        """
        return InfoTopic(
            id: "simple-guide-\(style.id)",
            title: "The basics",
            body: body,
            gotcha: ["Whichever proof you choose, watch the dough, not just the clock — a warm kitchen ferments faster than a cool one, so go by how puffy and risen it looks."]
        )
    }

    /// The steps, just below the fold — the banner taps down to here.
    private var simpleDirectionsCard: some View {
        simpleCard(title: "Cooking Directions", info: .schedule) {
            timelineView
        }
    }

    private var footnote: some View {
        Text("Times and yeast amounts are estimates that scale with temperature. Trust your dough — adjust to taste.")
            .font(.rounded(11))
            .foregroundStyle(Palette.textSoft)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.top, 4)
    }

    // MARK: Helpers

    private var shape: PizzaShape { vm.input.style.shape }

    // Collapsed-card summaries — plain-English, at-a-glance.
    private var sizeSummary: String {
        let noun = vm.input.ballCount == 1 ? shape.noun : shape.nounPlural
        let size: String
        if vm.input.sizeMode == .weight {
            size = "\(Units.weight(vm.input.ballWeight, metric: vm.metric)) each"
        } else if shape == .round {
            size = "\(lengthText(vm.input.diameter)) across"
        } else {
            size = "\(lengthText(vm.input.panLength))×\(lengthText(vm.input.panWidth))"
        }
        return "\(vm.input.ballCount) \(noun), \(size)"
    }
    /// Total yeast/starter weight pulled from the computed recipe.
    private var yeastGrams: Double {
        vm.result.stages.flatMap { $0.ingredients }
            .filter { $0.name == vm.input.yeast.fullName }
            .reduce(0) { $0 + $1.grams }
    }

    private var yeastSummary: String {
        vm.input.yeast.fullName + " · " + Units.weight(yeastGrams, metric: vm.metric)
            + (vm.input.prefermentActive ? ", \(vm.input.preferment.name.lowercased())" : "")
    }
    private var scheduleSummary: String {
        if vm.input.ferment == .quick {
            return "Quick — ready in \(Scheduler.duration(vm.schedule.leadHours))"
        }
        return "\(vm.input.ferment.label) — ready in \(Scheduler.duration(vm.schedule.leadHours))"
    }
    private var directionsSummary: String {
        "Start \(Scheduler.clock(vm.schedule.start, now: vm.now))"
    }

    /// Maps the fermentation segmented control onto the input.
    private var fermentChoice: Binding<FermentStyle> {
        Binding(get: { vm.input.ferment }, set: { vm.setFermentStyle($0) })
    }

    /// "Ready in" hours for a Quick dough (drives serve = now + hours).
    private var readyInHours: Binding<Double> {
        Binding(
            get: { min(max(vm.input.serveDate.timeIntervalSince(vm.now) / 3600, 1), 24) },
            set: { vm.input.serveDate = vm.now.addingTimeInterval($0 * 3600) }
        )
    }

    /// Maps the None/Poolish/Biga segmented control onto the input.
    private var prefermentChoice: Binding<PrefermentChoice> {
        Binding(
            get: {
                guard vm.input.usePreferment else { return .none }
                return vm.input.preferment == .biga ? .biga : .poolish
            },
            set: { vm.setPreferment($0) }
        )
    }

    private func pct(_ f: Double) -> String { String(format: "%.1f%%", f * 100) }

    private func grams(_ g: Double) -> String { Units.weight(g, metric: vm.metric) }

    private func lengthText(_ v: Double) -> String {
        vm.input.lengthUnit == .cm ? String(format: "%.0f cm", v) : String(format: "%.1f in", v)
    }
}

#Preview {
    ContentView()
}
