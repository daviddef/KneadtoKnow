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
enum Experience: Int, CaseIterable {
    case villager = 0, pizzaiolo, roman

    var title: String {
        switch self {
        case .villager:  return "I am a Villager"
        case .pizzaiolo: return "I am a Sunday Pizzaiolo"
        case .roman:     return "I am a Roman Soldier"
        }
    }
    var subtitle: String {
        switch self {
        case .villager:  return "Beginner"
        case .pizzaiolo: return "Some experience"
        case .roman:     return "Advanced"
        }
    }
    var emoji: String {
        switch self {
        case .villager:  return "🧑‍🌾"
        case .pizzaiolo: return "👨‍🍳"
        case .roman:     return "⚔️"
        }
    }
    var color: Complexity {
        switch self {
        case .villager:  return .beginner
        case .pizzaiolo: return .intermediate
        case .roman:     return .advanced
        }
    }
    var summary: [String] {
        switch self {
        case .villager:
            return [
                "Keep-it-simple mode on",
                "Auto-saves your setup",
                "Lots of tips & jokes",
                "Easy starter pizzas ready",
            ]
        case .pizzaiolo:
            return [
                "Keep-it-simple, recipe a tap away",
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

/// First-run "Get yourself ready" screen.
struct OnboardingView: View {
    @ObservedObject var vm: DoughViewModel
    var onDone: () -> Void

    @State private var levelIndex: Double = 0
    @State private var oven: OvenType = .home
    @State private var wantsReminders = true
    @State private var wantsLocation = true

    private var level: Experience { Experience(rawValue: Int(levelIndex.rounded())) ?? .villager }

    private func levelColor(_ c: Complexity) -> Color {
        switch c {
        case .beginner: return Palette.sage
        case .intermediate: return Palette.amber
        case .advanced: return Palette.danger
        }
    }

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Welcome
                    VStack(alignment: .leading, spacing: 2) {
                        Text("🍕 Welcome to Kneady Pizza")
                            .font(.rounded(20, weight: .bold))
                            .foregroundStyle(Palette.text)
                        Text("Let's set you up — how much pizza have you made?")
                            .font(.rounded(13))
                            .foregroundStyle(Palette.textSoft)
                    }
                    .padding(.top, 4)

                    // Experience slider + live preview
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Text(level.emoji).font(.system(size: 26))
                            VStack(alignment: .leading, spacing: 0) {
                                Text(level.title)
                                    .font(.rounded(18, weight: .bold))
                                    .foregroundStyle(Palette.text)
                                    .lineLimit(1).minimumScaleFactor(0.7)
                                Text(level.subtitle)
                                    .font(.rounded(11, weight: .semibold))
                                    .foregroundStyle(levelColor(level.color))
                            }
                            Spacer()
                        }

                        Slider(value: $levelIndex, in: 0...2, step: 1) { editing in
                            if editing { Haptics.tap() }
                        }
                        .tint(levelColor(level.color))

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(level.summary, id: \.self) { line in
                                HStack(spacing: 7) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.rounded(12))
                                        .foregroundStyle(levelColor(level.color))
                                    Text(line)
                                        .font(.rounded(12))
                                        .foregroundStyle(Palette.text)
                                        .lineLimit(1).minimumScaleFactor(0.8)
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: levelIndex)
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
                        vm.applyOnboarding(level: level, oven: oven,
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

                    Button {
                        OnboardingStore.completed = true
                        onDone()
                    } label: {
                        Text("Skip — I'll set it up myself")
                            .font(.rounded(12, weight: .medium))
                            .foregroundStyle(Palette.textSoft)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .tint(Palette.accent)
        .onAppear {
            // Seed from current settings so re-running feels continuous.
            levelIndex = Double(vm.experienceLevel.rawValue)
            oven = vm.input.oven
            wantsReminders = vm.notificationsEnabled
        }
    }
}
