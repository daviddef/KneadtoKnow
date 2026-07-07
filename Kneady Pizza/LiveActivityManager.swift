import Foundation
import ActivityKit

/// Starts, updates and ends the Lock Screen / Dynamic Island Live Activity
/// that mirrors the in-app bake schedule, so "ready in 4h 20m" is glanceable
/// without reopening Kneady Pizza. Mirrors NotificationManager's shape —
/// same trigger points, same "only while a bake is underway" rule.
enum LiveActivityManager {
    private static var current: Activity<BakeActivityAttributes>? {
        Activity<BakeActivityAttributes>.activities.first
    }

    /// The next not-yet-ticked step — the same "first incomplete" the
    /// in-app timeline already highlights.
    private static func nextStep(steps: [ScheduleStep], completed: [Int]) -> (index: Int, step: ScheduleStep)? {
        let done = Set(completed)
        for (i, step) in steps.enumerated() where !done.contains(i) {
            return (i, step)
        }
        return nil
    }

    private static func state(for step: ScheduleStep, index: Int, total: Int) -> BakeActivityAttributes.ContentState {
        BakeActivityAttributes.ContentState(
            stepTitle: step.title,
            stepIcon: step.icon,
            readyDate: step.time,
            stepNumber: index + 1,
            totalSteps: total,
            locationPhrase: step.restLocation.phrase,
            locationIcon: step.restLocation.icon
        )
    }

    /// Starts a Live Activity for a bake that just began, or updates the
    /// existing one to the current step. Ends it once every step is ticked
    /// (or there's no active bake at all).
    static func refresh(styleName: String, steps: [ScheduleStep], completed: [Int]) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard let (index, step) = nextStep(steps: steps, completed: completed) else {
            end()
            return
        }
        let content = ActivityContent(state: state(for: step, index: index, total: steps.count), staleDate: step.time)
        if let activity = current {
            Task { await activity.update(content) }
        } else {
            let attributes = BakeActivityAttributes(styleName: styleName)
            do {
                _ = try Activity.request(attributes: attributes, content: content)
            } catch {
                // A nice-to-have, not a requirement — skip quietly if the
                // system declines (e.g. the user turned Live Activities off).
            }
        }
    }

    static func end() {
        guard let activity = current else { return }
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
