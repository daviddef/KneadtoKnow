import Foundation
import StoreKit

/// Owns the one-time "Remove Ads" purchase and, from it, whether ads should
/// show at all. Source of truth is StoreKit's current entitlements; a cached
/// bool in UserDefaults keeps the first frame correct before StoreKit answers.
@MainActor
final class Monetization: ObservableObject {
    static let shared = Monetization()
    static let removeAdsProductID = "com.daviddefranceski.kneadypizza.removeads"
    private static let cacheKey = "adsRemoved.v1"

    @Published private(set) var adsRemoved: Bool
    @Published private(set) var removeAdsProduct: Product?
    @Published private(set) var purchaseInFlight = false

    private var updatesTask: Task<Void, Never>?

    private init() {
        adsRemoved = UserDefaults.standard.bool(forKey: Self.cacheKey)
        updatesTask = observeTransactionUpdates()
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    /// The single gate every ad surface checks.
    var shouldShowAds: Bool { !adsRemoved }

    /// Whether a purchase can be offered (product loaded and not already owned).
    var canBuyRemoveAds: Bool { removeAdsProduct != nil && !adsRemoved }

    func loadProduct() async {
        removeAdsProduct = try? await Product.products(for: [Self.removeAdsProductID]).first
    }

    func purchaseRemoveAds() async {
        guard let product = removeAdsProduct, !purchaseInFlight else { return }
        purchaseInFlight = true
        defer { purchaseInFlight = false }
        guard let result = try? await product.purchase() else { return }
        if case .success(let verification) = result,
           case .verified(let transaction) = verification {
            setRemoved(true)
            await transaction.finish()
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result,
               t.productID == Self.removeAdsProductID, t.revocationDate == nil {
                owned = true
            }
        }
        setRemoved(owned)
    }

    private func setRemoved(_ value: Bool) {
        guard value != adsRemoved else { return }
        adsRemoved = value
        UserDefaults.standard.set(value, forKey: Self.cacheKey)
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await update in Transaction.updates {
                guard case .verified(let t) = update else { continue }
                if t.productID == Self.removeAdsProductID {
                    await MainActor.run { self.setRemoved(t.revocationDate == nil) }
                }
                await t.finish()
            }
        }
    }
}
