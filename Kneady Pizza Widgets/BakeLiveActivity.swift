import ActivityKit
import WidgetKit
import SwiftUI

/// A closed range from now to `end`, clamped so it's never inverted — the
/// countdown text briefly reads 0:00 right at the boundary instead of
/// crashing on an invalid range.
private func countdownRange(to end: Date) -> ClosedRange<Date> {
    let now = Date()
    return now...max(end, now)
}

struct BakeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BakeActivityAttributes.self) { context in
            LockScreenBakeView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.stepIcon)
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.readyDate > Date() {
                        Text(timerInterval: countdownRange(to: context.state.readyDate), countsDown: true)
                            .font(.title3.monospacedDigit())
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                    } else {
                        Text("Ready")
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.stepTitle)
                            .font(.headline)
                        Text("Step \(context.state.stepNumber) of \(context.state.totalSteps) · \(context.attributes.styleName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.stepIcon)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.state.readyDate > Date() {
                    Text(timerInterval: countdownRange(to: context.state.readyDate), countsDown: true)
                        .font(.caption2.monospacedDigit())
                        .minimumScaleFactor(0.8)
                        .frame(width: 44)
                } else {
                    Text("Now")
                        .font(.caption2.bold())
                }
            } minimal: {
                Image(systemName: context.state.stepIcon)
                    .foregroundStyle(.orange)
            }
        }
    }
}

private struct LockScreenBakeView: View {
    let context: ActivityViewContext<BakeActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.orange).frame(width: 46, height: 46)
                Image(systemName: context.state.stepIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.styleName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.stepTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Step \(context.state.stepNumber) of \(context.state.totalSteps)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                if context.state.readyDate > Date() {
                    Text(timerInterval: countdownRange(to: context.state.readyDate), countsDown: true)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.orange)
                    Label(context.state.locationPhrase, systemImage: context.state.locationIcon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Ready")
                        .font(.headline)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
    }
}
