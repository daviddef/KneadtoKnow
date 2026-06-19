import SwiftUI

/// A single cooking-direction step shown large and uncluttered — reached by
/// double-tapping a step in the timeline, for easy reading at the bench.
struct StepFocusView: View {
    let step: ScheduleStep
    var items: [Ingredient] = []
    var metric: Bool = true
    var now: Date = Date()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
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
                }
                .padding(24)
            }
            .background(Palette.background.ignoresSafeArea())
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
    }
}
