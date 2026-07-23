import SwiftUI
import GoogleMobileAds

/// A single, discreet banner ad. Renders nothing when "Remove Ads" is owned.
/// By construction this is only ever placed on the main setup / reference
/// screens — never in Kid Mode, never during active cooking.
struct AdBanner: View {
    @ObservedObject private var monetization = Monetization.shared

    var body: some View {
        if monetization.shouldShowAds {
            BannerContainer()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        }
    }
}

/// UIKit bridge around the Google Mobile Ads `BannerView`. Requests
/// non-personalized ads only (no IDFA, no tracking prompt).
private struct BannerContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerUnitID
        banner.rootViewController = Self.rootViewController()

        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["npa": "1"]   // non-personalized ads
        request.register(extras)
        banner.load(request)
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows.first { $0.isKeyWindow }?
            .rootViewController
    }
}
