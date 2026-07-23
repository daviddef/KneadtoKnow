import SwiftUI
import GoogleMobileAds

@main
struct KneadToKnowApp: App {
    init() {
        // Start the ad SDK once at launch. Ads themselves are shown only on the
        // main setup/reference screens — never in Kid Mode or active cooking —
        // and are hidden entirely once "Remove Ads" is purchased (see Monetization).
        MobileAds.shared.start(completionHandler: nil)
        // Touch the store singleton so it loads the product and checks the
        // "Remove Ads" entitlement at launch, not on first ad render.
        _ = Monetization.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
