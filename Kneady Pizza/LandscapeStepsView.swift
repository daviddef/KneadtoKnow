import SwiftUI

/// Landscape "cooking mode": one step per screen, swipe left/right to move
/// between them, double-tap anywhere to tick the step off.
struct LandscapeStepsView: View {
    @ObservedObject var vm: DoughViewModel
    @Binding var completed: Set<Int>
    var onToggle: (Int) -> Void

    @State private var page = 0
    @State private var didJump = false

    private var steps: [ScheduleStep] { vm.schedule.steps }

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            if Palette.isVibrant { GinghamBackground() }

            if steps.isEmpty {
                Text("No steps yet — set up your bake in portrait first.")
                    .font(.rounded(16, weight: .medium))
                    .foregroundStyle(Palette.textSoft)
                    .multilineTextAlignment(.center)
                    .padding(40)
            } else {
                TabView(selection: $page) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        page(idx: idx, step: step, total: steps.count).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)
                .ignoresSafeArea(edges: .bottom)

                // Progress + dots overlay (non-interactive).
                VStack {
                    HStack {
                        Text("Step \(page + 1) of \(steps.count)")
                            .font(.rounded(20, weight: .bold))
                            .foregroundStyle(Palette.accent)
                        Spacer()
                        Text("Swipe ‹ › · double-tap to tick off")
                            .font(.rounded(12, weight: .medium))
                            .foregroundStyle(Palette.textSoft)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 10)
                    Spacer()
                    dots
                        .padding(.bottom, 12)
                }
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true   // no auto-lock while cooking
            if !didJump {
                page = firstIncomplete()
                didJump = true
            }
        }
    }

    private var dots: some View {
        HStack(spacing: 6) {
            ForEach(steps.indices, id: \.self) { i in
                Circle()
                    .fill(dotColor(i))
                    .frame(width: i == page ? 8 : 6, height: i == page ? 8 : 6)
            }
        }
    }

    private func dotColor(_ i: Int) -> Color {
        if completed.contains(i) { return Palette.sage }
        return i == page ? Palette.accent : Palette.textSoft.opacity(0.3)
    }

    private func locationColor(_ loc: StepLocation) -> Color {
        switch loc {
        case .room:   return Palette.sage
        case .fridge: return Palette.cool
        case .warm:   return Palette.warm
        }
    }

    private func firstIncomplete() -> Int {
        for i in steps.indices where !completed.contains(i) { return i }
        return max(steps.count - 1, 0)
    }

    private func page(idx: Int, step: ScheduleStep, total: Int) -> some View {
        let done = completed.contains(idx)
        let tools = StepGuide.tools(step.title)
        return HStack(alignment: .top, spacing: 28) {
            // Left: the headline — icon, time, title, status, and the kit.
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(done ? Palette.sage : Palette.accent)
                            .frame(width: 72, height: 72)
                        Image(systemName: done ? "checkmark" : step.icon)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(Scheduler.timeOnly(step.time))
                    }
                    .font(.rounded(20, weight: .bold))
                    .foregroundStyle(Palette.accent)
                    Text(Scheduler.dayLabel(step.time, now: vm.now))
                        .font(.rounded(13, weight: .medium))
                        .foregroundStyle(Palette.textSoft)
                    if step.leadHours > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: step.restLocation.icon)
                            Text("\(Scheduler.duration(step.leadHours)) \(step.restLocation.phrase)")
                        }
                        .font(.rounded(14, weight: .semibold))
                        .foregroundStyle(locationColor(step.restLocation))
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(step.title)
                        .font(.rounded(30, weight: .bold))
                        .foregroundStyle(Palette.text)
                        .strikethrough(done)
                        .fixedSize(horizontal: false, vertical: true)
                    Label(done ? "Done — double-tap to undo" : "Double-tap to complete",
                          systemImage: done ? "checkmark.circle.fill" : "hand.tap.fill")
                        .font(.rounded(13, weight: .semibold))
                        .foregroundStyle(done ? Palette.sage : Palette.textSoft)

                    if !step.gotcha.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Watch out", systemImage: "exclamationmark.triangle.fill")
                                .font(.rounded(13, weight: .bold))
                                .foregroundStyle(Palette.amber)
                            Text(step.gotcha)
                                .font(.rounded(15, weight: .medium))
                                .foregroundStyle(Palette.amber)
                                .strikethrough(done)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Palette.amber.opacity(0.45), lineWidth: 1))
                    }

                    if !tools.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Kit you'll need", systemImage: "wrench.and.screwdriver.fill")
                                .font(.rounded(13, weight: .bold))
                                .foregroundStyle(Palette.textSoft)
                            ForEach(tools, id: \.self) { tool in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.rounded(13))
                                        .foregroundStyle(Palette.sage)
                                    Text(tool)
                                        .font(.rounded(15, weight: .medium))
                                        .foregroundStyle(Palette.text)
                                        .strikethrough(done)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                    }
                }
                .padding(.bottom, 24)
            }
            .frame(width: 260)

            // Right: the detail, ingredients and the yellow tip — scrolls if long.
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.detail)
                        .font(.rounded(23, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .strikethrough(done)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    let items = vm.stepItems(for: step)
                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(items) { item in
                                HStack(alignment: .firstTextBaseline) {
                                    Text(item.name).foregroundStyle(Palette.text).strikethrough(done)
                                    Spacer()
                                    Text(Units.weight(item.grams, metric: vm.metric))
                                        .foregroundStyle(Palette.accent).strikethrough(done)
                                }
                                .font(.rounded(17, weight: .semibold))
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.well))
                    }

                    if let concept = StepGuide.concept(step.title) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Good to know", systemImage: "lightbulb.fill")
                                .font(.rounded(13, weight: .bold))
                                .foregroundStyle(Palette.textSoft)
                            Text(concept)
                                .font(.rounded(16))
                                .foregroundStyle(Palette.text)
                                .strikethrough(done)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 36)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .opacity(done ? 0.55 : 1)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            onToggle(idx)
        }
    }
}
