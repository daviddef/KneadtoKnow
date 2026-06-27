import SwiftUI

/// A cooking-direction step shown large and uncluttered — reached by tapping a
/// step in the timeline. Swipe left/right to move between steps.
struct StepFocusView: View {
    let steps: [ScheduleStep]
    var startIndex: Int = 0
    var itemsFor: (ScheduleStep) -> [Ingredient] = { _ in [] }
    var metric: Bool = true
    var now: Date = Date()
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    ScrollView {
                        stepContent(step)
                            .padding(24)
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle(steps.isEmpty ? "" : "Step \(page + 1) of \(steps.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rounded(17, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .tint(Palette.accent)
        .onAppear { page = min(max(startIndex, 0), max(steps.count - 1, 0)) }
    }

    private func stepContent(_ step: ScheduleStep) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            // Big icon + time
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Palette.accent)
                        .frame(width: 64, height: 64)
                    Image(systemName: step.icon)
                        .font(.rounded(28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(Scheduler.timeOnly(step.time))
                    }
                    .font(.rounded(20, weight: .bold))
                    .foregroundStyle(Palette.accent)
                    Text(Scheduler.dayLabel(step.time, now: now))
                        .font(.rounded(14, weight: .medium))
                        .foregroundStyle(Palette.textSoft)
                }
                Spacer()
            }

            Text(step.title)
                .font(.rounded(32, weight: .bold))
                .foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)

            Text(step.detail)
                .font(.rounded(22, weight: .medium))
                .foregroundStyle(Palette.text)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            let items = itemsFor(step)
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(items) { item in
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.name)
                                .foregroundStyle(Palette.text)
                            Spacer()
                            Text(Units.weight(item.grams, metric: metric))
                                .foregroundStyle(Palette.accent)
                        }
                        .font(.rounded(20, weight: .semibold))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.well))
            }

            if !step.gotcha.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(step.gotcha)
                }
                .font(.rounded(16, weight: .medium))
                .foregroundStyle(Palette.amber)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
