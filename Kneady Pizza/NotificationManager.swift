import Foundation
import UserNotifications

/// Remembers whether the user wants step reminders.
enum NotificationStore {
    private static let key = "stepNotifications.v1"
    static var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

/// Schedules local notifications that nudge the baker when the next hands-on
/// step of the plan is due.
enum NotificationManager {
    /// Asks the system for permission to post notifications.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        return granted
    }

    /// Replaces any pending reminders with ones for the upcoming active steps.
    static func reschedule(steps: [ScheduleStep], now: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // Only hands-on steps that are still in the future are worth a nudge.
        let upcoming = steps.filter { $0.isActive && $0.time.timeIntervalSince(now) > 60 }
        for step in upcoming {
            let content = UNMutableNotificationContent()
            content.title = "🍕 Time to: \(step.title)"
            content.body = step.detail
            content.sound = .default

            let interval = max(step.time.timeIntervalSince(now), 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: step.id.uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
