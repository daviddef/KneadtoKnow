import SwiftUI

/// Remembers whether the first-run setup has been completed.
enum OnboardingStore {
    private static let key = "onboardingCompleted.v1"
    static var completed: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

/// Remembers the user's skill level, used to order the style picker.
enum ExperienceStore {
    private static let key = "experienceLevel.v1"
    static var level: Complexity {
        get { Complexity(rawValue: UserDefaults.standard.object(forKey: key) as? Int ?? 1) ?? .intermediate }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: key) }
    }
}

/// The three experience levels offered on first run.
enum Experience: Int, CaseIterable, Identifiable {
    case kid = 0, villager, pizzaiolo, roman
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .kid:       return "I am a Kid"
        case .villager:  return "I am a Villager"
        case .pizzaiolo: return "I am a Sunday Pizzaiolo"
        case .roman:     return "I am a Roman Soldier"
        }
    }
    /// Short label for the mode picker in the menu.
    var shortLabel: String {
        switch self {
        case .kid:       return "Kid"
        case .villager:  return "Villager"
        case .pizzaiolo: return "Pizzaiolo"
        case .roman:     return "Roman"
        }
    }
    var subtitle: String {
        switch self {
        case .kid:       return "Just for fun"
        case .villager:  return "Beginner"
        case .pizzaiolo: return "Some experience"
        case .roman:     return "Advanced"
        }
    }
    var emoji: String {
        switch self {
        case .kid:       return "🧒"
        case .villager:  return "🧑‍🌾"
        case .pizzaiolo: return "👨‍🍳"
        case .roman:     return "⚔️"
        }
    }
    var color: Complexity {
        switch self {
        case .kid:       return .beginner
        case .villager:  return .beginner
        case .pizzaiolo: return .intermediate
        case .roman:     return .advanced
        }
    }
    var summary: [String] {
        switch self {
        case .kid:
            return [
                "Big, fun Kid Mode",
                "Pick or build your pizza",
                "Simple steps & confetti",
                "A grown-up helps with the oven",
            ]
        case .villager:
            return [
                "Simple mode on",
                "Auto-saves your setup",
                "Lots of tips & jokes",
                "Easy starter pizzas ready",
            ]
        case .pizzaiolo:
            return [
                "Simple, recipe a tap away",
                "Auto-saves your setup",
                "A balance of tips & jokes",
                "Starter pizzas with character",
            ]
        case .roman:
            return [
                "Full control of every number",
                "No auto-save",
                "Few tips — gotchas & maths",
                "An adventurous starter line-up",
            ]
        }
    }
}

/// First-run flow: an animated splash asks the one big question — which mode?
/// — then hands off to the existing setup screen (oven, look, reminders,
/// location), now tailored to that choice, before dropping into the app.
struct OnboardingView: View {
    @ObservedObject var vm: DoughViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    var onDone: () -> Void

    private enum Phase { case splash, setup }
    @State private var phase: Phase = .splash

    @State private var persona: Experience = .villager
    @State private var oven: OvenType = .home
    @State private var wantsReminders = true
    @State private var wantsLocation = true

    @State private var showHero = false
    @State private var showTiles = false
    @State private var bounce = false

    private func personaColor(_ persona: Experience) -> Color {
        switch persona.color {
        case .beginner: return Palette.sage
        case .intermediate: return Palette.amber
        case .advanced: return Palette.danger
        }
    }

    private func choose(_ persona: Experience) {
        Haptics.select()
        self.persona = persona
        withAnimation(.easeInOut(duration: 0.35)) { phase = .setup }
    }

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            if phase == .splash { floatingDots }

            switch phase {
            case .splash: splash
            case .setup: setup
            }
        }
        .tint(Palette.accent)
        .onAppear {
            // Seed from current settings so re-running feels continuous.
            // Experience adds Kid at 0, so it sits one ahead of Complexity.
            persona = vm.kidMode ? .kid : (Experience(rawValue: vm.experienceLevel.rawValue + 1) ?? .villager)
            oven = vm.input.oven
            wantsReminders = vm.notificationsEnabled

            withAnimation(.easeOut(duration: 0.55)) { showHero = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) { showTiles = true }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { bounce = true }
        }
    }

    // MARK: - Splash: the one big question

    private var splash: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)
            hero
            Spacer(minLength: 26)
            question
            Spacer(minLength: 12)

            Button {
                OnboardingStore.completed = true
                onDone()
            } label: {
                Text("Skip — I'll set it up myself")
                    .font(.rounded(12, weight: .medium))
                    .foregroundStyle(Palette.textSoft)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 18)
            .opacity(showTiles ? 1 : 0)
        }
        .transition(.asymmetric(
            insertion: .opacity,
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    /// Faint drifting dots of "flour" for atmosphere — purely decorative.
    private var floatingDots: some View {
        GeometryReader { geo in
            let specs: [(CGFloat, CGFloat, CGFloat, Double)] = [
                (0.14, 0.10, 70, 4.6), (0.86, 0.16, 54, 5.4), (0.20, 0.90, 90, 6.2),
                (0.82, 0.86, 60, 5.0), (0.5, 0.06, 40, 4.2), (0.92, 0.5, 50, 5.8),
            ]
            ForEach(Array(specs.enumerated()), id: \.offset) { i, spec in
                Circle()
                    .fill(Palette.accent.opacity(0.06))
                    .frame(width: spec.2)
                    .position(x: geo.size.width * spec.0, y: geo.size.height * spec.1)
                    .scaleEffect(bounce ? 1.18 : 0.85)
                    .animation(
                        .easeInOut(duration: spec.3).repeatForever(autoreverses: true).delay(Double(i) * 0.25),
                        value: bounce
                    )
            }
        }
        .allowsHitTesting(false)
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Text("🍕")
                .font(.system(size: 88))
                .rotationEffect(.degrees(bounce ? 8 : -8))
                .scaleEffect(bounce ? 1.05 : 0.95)
                .shadow(color: Palette.accent.opacity(0.3), radius: 22, y: 12)

            Text("Kneady Pizza")
                .font(.rounded(32, weight: .heavy))
                .foregroundStyle(Palette.text)

            Text("Great dough, perfectly timed.")
                .font(.rounded(15, weight: .medium))
                .foregroundStyle(Palette.textSoft)
        }
        .opacity(showHero ? 1 : 0)
        .offset(y: showHero ? 0 : 14)
    }

    private var question: some View {
        VStack(spacing: 14) {
            Text("How do you like to cook?")
                .font(.rounded(21, weight: .bold))
                .foregroundStyle(Palette.text)
            Text("Pick a mode — next you'll set your oven, look and reminders.")
                .font(.rounded(12))
                .foregroundStyle(Palette.textSoft)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(Array(Experience.allCases.enumerated()), id: \.element.id) { i, persona in
                    modeCard(persona)
                        .opacity(showTiles ? 1 : 0)
                        .offset(y: showTiles ? 0 : 18)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75).delay(Double(i) * 0.08),
                            value: showTiles
                        )
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .opacity(showHero ? 1 : 0)
    }

    private func modeCard(_ persona: Experience) -> some View {
        Button {
            choose(persona)
        } label: {
            HStack(spacing: 14) {
                Text(persona.emoji)
                    .font(.system(size: 32))
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(personaColor(persona).opacity(0.18)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(persona.title)
                        .font(.rounded(16, weight: .bold))
                        .foregroundStyle(Palette.text)
                        .lineLimit(1).minimumScaleFactor(0.8)
                    Text(persona.subtitle)
                        .font(.rounded(12, weight: .semibold))
                        .foregroundStyle(personaColor(persona))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.rounded(13, weight: .bold))
                    .foregroundStyle(Palette.textSoft.opacity(0.6))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Palette.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(personaColor(persona).opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: Palette.shadowDark, radius: 8, x: 5, y: 5)
            .shadow(color: Palette.shadowLight, radius: 8, x: -5, y: -5)
        }
        .buttonStyle(TactileButtonStyle())
    }

    // MARK: - Setup: oven, look, reminders — tailored to the chosen mode

    private var setup: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Recap of the mode just chosen, with a way back.
                HStack(spacing: 10) {
                    Text(persona.emoji).font(.system(size: 26))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(persona.title)
                            .font(.rounded(18, weight: .bold))
                            .foregroundStyle(Palette.text)
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Text(persona.subtitle)
                            .font(.rounded(11, weight: .semibold))
                            .foregroundStyle(personaColor(persona))
                    }
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { phase = .splash }
                    } label: {
                        Text("Change")
                            .font(.rounded(12, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)

                // What this mode means, made explicit.
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(persona.summary, id: \.self) { line in
                        HStack(spacing: 7) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.rounded(12))
                                .foregroundStyle(personaColor(persona))
                            Text(line)
                                .font(.rounded(12))
                                .foregroundStyle(Palette.text)
                                .lineLimit(1).minimumScaleFactor(0.8)
                        }
                    }
                }
                .padding(14)
                .softCard()

                // Oven
                VStack(alignment: .leading, spacing: 8) {
                    Text("WHAT DO YOU BAKE IN?")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileSegmented(options: OvenType.allCases, selection: $oven) { $0.label }
                }
                .padding(14)
                .softCard()

                // Look / theme
                VStack(alignment: .leading, spacing: 8) {
                    Text("PICK YOUR LOOK")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileSegmented(options: AppTheme.allCases,
                                     selection: $themeManager.theme,
                                     animateSelection: false) { $0.label }
                    Text("Calm Classic flour & terracotta, or a bold Vibrant pizzeria. Change it any time in the menu.")
                        .font(.rounded(11)).foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .softCard()

                // Permissions
                VStack(alignment: .leading, spacing: 12) {
                    Text("A COUPLE OF HANDY EXTRAS")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    TactileToggle(
                        title: "Step reminders",
                        subtitle: "A nudge when the next step is due. We'll ask permission.",
                        isOn: $wantsReminders
                    )
                    TactileToggle(
                        title: "Use my location",
                        subtitle: "Sets kitchen temperature & units. We'll ask permission.",
                        isOn: $wantsLocation
                    )
                }
                .padding(14)
                .softCard()

                // Start
                Button {
                    vm.applyOnboarding(level: persona, oven: oven,
                                       wantsReminders: wantsReminders, wantsLocation: wantsLocation)
                    onDone()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "fork.knife")
                        Text("Start baking")
                    }
                    .font(.rounded(16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(TactileButtonStyle(isProminent: true))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .id(themeManager.theme)   // re-skin live when the look changes
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
    }
}
