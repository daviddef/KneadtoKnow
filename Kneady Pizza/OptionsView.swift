import SwiftUI

// MARK: - Slide-in menu drawer

/// The slide-in menu. A compact hub that routes to three distinct areas —
/// Settings, My Favourite and the Guide — each its own view.
struct MenuDrawer: View {
    @ObservedObject var vm: DoughViewModel
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Mode switch, kept prominent at the top of the menu.
                    VStack(alignment: .leading, spacing: 8) {
                        TactileToggle(
                            title: "Keep it simple",
                            subtitle: "Let the pizza style set the ball size, yeast and proportions, and hide the detailed recipe. Turn off for full control.",
                            isOn: $vm.input.keepItSimple
                        )
                    }
                    .padding(18)
                    .softCard()

                    menuLink(icon: "slider.horizontal.3",
                             title: "Settings",
                             subtitle: "Units, oven, room temperature & reminders") {
                        SettingsView(vm: vm)
                    }

                    menuLink(icon: "star.fill",
                             title: "My Favourite",
                             subtitle: "Save your whole setup and reuse it any time.") {
                        FavouriteView(vm: vm)
                    }

                    Text("GUIDE & INFO")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                        .padding(.top, 8)
                        .padding(.leading, 4)

                    menuLink(icon: "book.closed.fill",
                             title: "How it works & the maths",
                             subtitle: "The thinking behind every number, plus more about ingredients.") {
                        HowItWorksView()
                    }
                    menuLink(icon: "wrench.and.screwdriver.fill",
                             title: "Tools & equipment",
                             subtitle: "The kit that makes pizza easier — from a scale to a steel.") {
                        ToolsView()
                    }
                    menuLink(icon: "exclamationmark.triangle.fill",
                             title: "Things that may get-ya",
                             subtitle: "The usual pizza disasters — and how to dodge them.") {
                        GotchasView()
                    }
                    menuLink(icon: "character.book.closed.fill",
                             title: "Definitions",
                             subtitle: "Plain-English meanings for every baking term.") {
                        DefinitionsView()
                    }
                }
                .padding(20)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onClose() }
                        .font(.rounded(16, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .tint(Palette.accent)
    }

    @ViewBuilder
    private func menuLink<Destination: View>(icon: String, title: String, subtitle: String,
                                             @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(Palette.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.rounded(16, weight: .semibold)).foregroundStyle(Palette.text)
                    Text(subtitle).font(.rounded(12)).foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.rounded(13, weight: .semibold)).foregroundStyle(Palette.textSoft)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings

/// Units, oven, room temperature and notification reminders.
struct SettingsView: View {
    @ObservedObject var vm: DoughViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Units
                VStack(alignment: .leading, spacing: 10) {
                    Text("UNITS")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileSegmented(
                        options: LengthUnit.allCases,
                        selection: $vm.input.lengthUnit
                    ) { $0 == .cm ? "Metric" : "Imperial" }
                    Text("Metric uses grams and centimetres; Imperial uses ounces/pounds and inches. This switches every measurement in the app.")
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                }
                .padding(18)
                .softCard()

                // Oven
                VStack(alignment: .leading, spacing: 10) {
                    Text("OVEN")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileSegmented(
                        options: OvenType.allCases,
                        selection: $vm.input.oven
                    ) { $0.label }
                    Text(vm.input.oven.blurb)
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .softCard()

                // Room temperature
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Text("ROOM TEMPERATURE")
                            .font(.rounded(12, weight: .bold))
                            .foregroundStyle(Palette.textSoft)
                        Spacer()
                        Text(String(format: "%.1f °C", vm.input.temperatureC))
                            .font(.rounded(17, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                            .contentTransition(.numericText())
                        Button {
                            Task { await vm.fetchLocalTemperature() }
                        } label: {
                            Group {
                                if case .loading = vm.weatherState {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "location.fill").font(.rounded(14, weight: .semibold))
                                }
                            }
                            .frame(width: 36, height: 36)
                        }
                        .buttonStyle(TactileButtonStyle(isProminent: true, cornerRadius: 18))
                    }
                    Slider(value: $vm.input.temperatureC, in: 4...35, step: 0.5) { editing in
                        if editing { Haptics.tap() }
                    }
                    .tint(Palette.accent)
                    if case .failed(let msg) = vm.weatherState {
                        Text(msg).font(.rounded(11)).foregroundStyle(Palette.accent)
                    } else {
                        Text("Warmer rooms ferment faster — this sets the timings and yeast.")
                            .font(.rounded(11)).foregroundStyle(Palette.textSoft)
                    }
                }
                .padding(18)
                .softCard()

                // Notifications
                VStack(alignment: .leading, spacing: 10) {
                    Text("REMINDERS")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileToggle(
                        title: "Step reminders",
                        subtitle: "Get a notification when the next hands-on step in your plan is due — making the pre-ferment, mixing, shaping and so on.",
                        isOn: $vm.notificationsEnabled
                    )
                    Text("Reminders follow your current serve time, and update if you change the plan.")
                        .font(.rounded(11)).foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .softCard()

                // Pop-ups: coaching tips + humour
                VStack(alignment: .leading, spacing: 12) {
                    Text("POP-UPS")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileToggle(
                        title: "Coaching tips",
                        subtitle: "Bite-size best-practice nudges that float up now and then — pitched to your level (practical kit tips in simple mode, gotchas and maths for the advanced).",
                        isOn: $vm.input.tipsEnabled
                    )
                    TactileToggle(
                        title: "Pizza humour",
                        subtitle: "The occasional floating pizza joke, and a quip in each info card.",
                        isOn: $vm.input.humourEnabled
                    )
                    if vm.input.humourEnabled || vm.input.tipsEnabled {
                        Text("HOW OFTEN")
                            .font(.rounded(11, weight: .bold))
                            .foregroundStyle(Palette.textSoft)
                        TactileSegmented(
                            options: HumourLevel.allCases,
                            selection: $vm.input.humourLevel
                        ) { $0.label }
                        Text("How often a tip or joke floats up — about every 3 minutes, 90 seconds or 30 seconds.")
                            .font(.rounded(11)).foregroundStyle(Palette.textSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(18)
                .softCard()
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - My Favourite

/// Save, update and forget the user's "My Favourite" setup.
struct FavouriteView: View {
    @ObservedObject var vm: DoughViewModel
    @State private var justSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    TactileToggle(
                        title: "Save as My Favourite",
                        subtitle: "Remembers your whole setup — style, size, yeast, proportions and toppings. It loads automatically next time and appears at the top of the style picker.",
                        isOn: Binding(
                            get: { vm.hasFavourite },
                            set: { $0 ? vm.saveFavourite() : vm.clearFavourite() }
                        )
                    )

                    if vm.hasFavourite {
                        Divider().overlay(Palette.textSoft.opacity(0.15))

                        TactileToggle(
                            title: "Autosave",
                            subtitle: "Keep my favourite updated automatically as I change things — no need to tap Update.",
                            isOn: $vm.autosaveFavourite
                        )

                        if vm.autosaveFavourite {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Saving automatically")
                            }
                            .font(.rounded(13, weight: .semibold))
                            .foregroundStyle(Palette.sage)
                        } else {
                            Button {
                                vm.saveFavourite()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { justSaved = true }
                                Task {
                                    try? await Task.sleep(nanoseconds: 1_700_000_000)
                                    withAnimation(.easeInOut) { justSaved = false }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: justSaved ? "checkmark.circle.fill" : "arrow.clockwise")
                                    Text(justSaved ? "Saved!" : "Update with current settings")
                                }
                                .font(.rounded(14, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(justSaved ? Palette.sage : Palette.accent)
                                )
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.25), value: justSaved)
                        }
                    }
                }
                .padding(18)
                .softCard()

                // One-tap easiest setup.
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        vm.resetToEasy()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "wand.and.stars")
                            Text("Reset my favourite to Easy!!")
                        }
                        .font(.rounded(15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                    }
                    .buttonStyle(TactileButtonStyle(isProminent: true))
                    Text("Sets the simplest setup — Simple Home Classic, keep-it-simple on, a Quick proof ready in 12 hours, in a home oven — and saves it as your favourite.")
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Everything the favourite is remembering.
                if let details = vm.favouriteDetails {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WHAT'S SAVED")
                            .font(.rounded(12, weight: .bold))
                            .foregroundStyle(Palette.textSoft)
                        ForEach(Array(details.enumerated()), id: \.offset) { _, row in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Text(row.label)
                                    .font(.rounded(13, weight: .medium))
                                    .foregroundStyle(Palette.textSoft)
                                Spacer(minLength: 10)
                                Text(row.value)
                                    .font(.rounded(13, weight: .semibold))
                                    .foregroundStyle(Palette.text)
                                    .multilineTextAlignment(.trailing)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .softCard()
                }

                Text("Tip: tweak anything you like, then tap “Update with current settings” — or turn on Autosave to keep it in sync.")
                    .font(.rounded(12))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("My Favourite")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Definitions

/// A plain-English glossary of the baking terms used throughout the app.
struct DefinitionsView: View {
    private struct Term: Identifiable { let id = UUID(); let term: String; let definition: String }

    private let glossary: [Term] = [
        .init(term: "Baker's percentage",
              definition: "Every ingredient is given as a percentage of the flour weight, and flour is always 100%. It lets a recipe scale to any number of pizzas."),
        .init(term: "Hydration",
              definition: "Water as a percentage of flour. Higher hydration gives a wetter, more open, airier crumb — but it's stickier to handle."),
        .init(term: "Pre-ferment",
              definition: "A portion of the flour, water and a little yeast mixed ahead and left to ferment, then added to the final dough for deeper flavour and strength."),
        .init(term: "Poolish",
              definition: "A loose, 100%-hydration pre-ferment (equal flour and water) with a pinch of yeast, rested ~12 h. Mild and nutty; adds extensibility. Usually about 30% of the flour."),
        .init(term: "Biga",
              definition: "A stiff, ~50%-hydration Italian pre-ferment with a little yeast, rested ~16 h (often cooler). Adds strength, aroma and a deeper, slightly tangy flavour. Often about 50% of the flour."),
        .init(term: "Autolyse",
              definition: "Mixing just the flour and water first and resting 20–60 min before the salt and yeast. The flour hydrates fully so the dough stretches more easily."),
        .init(term: "Bulk ferment",
              definition: "The dough's first rise, as one mass, after mixing."),
        .init(term: "Proof",
              definition: "The final rest after the dough is divided into balls or pans, just before baking."),
        .init(term: "ADY — Active dry yeast",
              definition: "Traditionally bloomed in water first. About 1.25× the weight of instant dry yeast."),
        .init(term: "IDY — Instant dry yeast",
              definition: "Stirred straight into the flour. The baseline this calculator works from. Best for consistency and convenience."),
        .init(term: "CY — Fresh / cake yeast",
              definition: "The traditional choice for authentic Neapolitan. About 3× the weight of instant, with a little more flavour."),
        .init(term: "SD — Sourdough",
              definition: "A natural 100%-hydration starter that replaces commercial yeast, for complex, artisanal flavour."),
        .init(term: "Appropriate yeasts",
              definition: "Each pizza style only offers the yeasts that suit it — e.g. fresh yeast and sourdough for Neapolitan, instant and active dry for New York."),
        .init(term: "Ball weight",
              definition: "How heavy each dough ball is, which sets how thick the base bakes. ~250–280 g suits a 12″ Neapolitan."),
        .init(term: "Salt, oil & honey",
              definition: "Salt tightens the dough and seasons it; oil softens and crisps; honey feeds browning. All are shown as a % of flour."),
        .init(term: "Room temperature",
              definition: "Warmer rooms ferment faster, so the app shortens timings and uses less yeast; cooler rooms do the opposite."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(glossary) { t in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(t.term)
                            .font(.rounded(15, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                        Text(t.definition)
                            .font(.rounded(13))
                            .foregroundStyle(Palette.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Definitions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
