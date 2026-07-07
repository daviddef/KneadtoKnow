import ActivityKit
import Foundation

/// The Live Activity shown on the Lock Screen / Dynamic Island while a bake
/// is underway — lets you check "ready in 4h 20m" without reopening the app.
/// Shared between the app (which starts/updates/ends it) and the widget
/// extension (which renders it).
struct BakeActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// The step that's next up (or in progress right now).
        var stepTitle: String
        var stepIcon: String
        /// When that step becomes ready — already past if it's ready now.
        var readyDate: Date
        var stepNumber: Int
        var totalSteps: Int
        var locationPhrase: String
        var locationIcon: String
    }

    /// Set once when the bake starts — doesn't change over its lifetime.
    var styleName: String
}
