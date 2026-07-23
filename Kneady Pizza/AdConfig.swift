import Foundation

/// Ad unit identifiers. These are Google's official *test* unit IDs — safe to
/// ship, they return test ads and earn nothing. Before going live, replace
/// `bannerUnitID` with the real banner unit from the AdMob console (format
/// `ca-app-pub-4156851882993001/XXXXXXXXXX` — a slash, not a tilde; the tilde
/// form is the app ID, which already lives in Info.plist).
///
/// ⚠️ Do NOT tap a real (non-test) ad during your own testing — Google flags
/// that as invalid traffic and can suspend the account. Keep the test ID until
/// the real one is ready, and only swap it in a build you won't tap ads in.
enum AdConfig {
    static let bannerUnitID = "ca-app-pub-3940256099942544/2435281174" // TODO: real banner unit ID
}
