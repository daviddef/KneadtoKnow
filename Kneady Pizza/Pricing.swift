import SwiftUI

/// Ingredient groups used to estimate cost. Prices are per kilogram and editable
/// by the user; defaults are rough ballparks until they tune them to their shop.
enum PriceCategory: String, CaseIterable, Codable {
    case flour, water, salt, yeast, oil, sweetener, binder
    case sauce, cheese, premiumCheese, meat, veg, herbs, bread, sweet, other

    var label: String {
        switch self {
        case .flour:         return "Flour"
        case .water:         return "Water"
        case .salt:          return "Salt"
        case .yeast:         return "Yeast"
        case .oil:           return "Olive oil"
        case .sweetener:     return "Honey / sugar"
        case .binder:        return "GF binder"
        case .sauce:         return "Tomato / sauce"
        case .cheese:        return "Mozzarella / cheese"
        case .premiumCheese: return "Premium cheese"
        case .meat:          return "Cured meat / anchovy"
        case .veg:           return "Vegetables"
        case .herbs:         return "Herbs & greens"
        case .bread:         return "Breadcrumbs"
        case .sweet:         return "Sweet toppings"
        case .other:         return "Other"
        }
    }

    /// Rough generic price per kg (currency-agnostic ballpark). The user edits
    /// these to match their shop.
    var defaultPricePerKg: Double {
        switch self {
        case .flour:         return 2.5
        case .water:         return 0.0
        case .salt:          return 3.0
        case .yeast:         return 35.0
        case .oil:           return 16.0
        case .sweetener:     return 16.0
        case .binder:        return 90.0
        case .sauce:         return 6.0
        case .cheese:        return 14.0
        case .premiumCheese: return 38.0
        case .meat:          return 34.0
        case .veg:           return 9.0
        case .herbs:         return 45.0
        case .bread:         return 7.0
        case .sweet:         return 16.0
        case .other:         return 12.0
        }
    }

    /// Classify an ingredient line by name. Order matters — most specific first.
    static func classify(_ name: String) -> PriceCategory {
        let n = name.lowercased()
        func has(_ words: [String]) -> Bool { words.contains { n.contains($0) } }
        if has(["water"]) { return .water }
        if has(["flour"]) { return .flour }
        if has(["salt"]) { return .salt }
        if has(["xanthan", "psyllium"]) { return .binder }
        if has(["yeast", "sourdough", "starter"]) { return .yeast }
        if has(["olive oil", "oil"]) { return .oil }
        if has(["nutella", "banana", "butter", "cinnamon"]) { return .sweet }
        if has(["honey", "sugar", "maple", "syrup"]) { return .sweetener }
        if has(["parmesan", "gorgonzola", "fontina", "caciocavallo", "bufala", "buffalo", "pecorino", "stracciatella"]) { return .premiumCheese }
        if has(["mozzarella", "cheese", "brick", "fior di latte"]) { return .cheese }
        if has(["pepperoni", "salami", "ham", "prosciutto", "anchovy", "nduja", "clam", "bacon"]) { return .meat }
        if has(["tomato", "passata", "sauce", "marzano"]) { return .sauce }
        if has(["basil", "rosemary", "oregano", "rocket", "arugula"]) { return .herbs }
        if has(["breadcrumb"]) { return .bread }
        if has(["mushroom", "onion", "pepper", "artichoke", "olive", "pineapple", "garlic", "caper"]) { return .veg }
        return .other
    }
}

/// Persisted, editable ingredient prices. A shared observable so the cost
/// estimate updates everywhere the moment a price is edited.
final class PriceStore: ObservableObject {
    static let shared = PriceStore()
    private let key = "ingredientPrices.v1"

    @Published var overrides: [String: Double] {
        didSet { UserDefaults.standard.set(overrides, forKey: key) }
    }

    private init() {
        overrides = (UserDefaults.standard.dictionary(forKey: key) as? [String: Double]) ?? [:]
    }

    func pricePerKg(_ cat: PriceCategory) -> Double {
        overrides[cat.rawValue] ?? cat.defaultPricePerKg
    }
    func setPrice(_ cat: PriceCategory, _ value: Double) {
        overrides[cat.rawValue] = max(0, value)
    }
    func resetAll() { overrides = [:] }
}

/// Formats a number as money in the device's locale/currency.
func moneyString(_ value: Double) -> String {
    let code = Locale.current.currency?.identifier ?? "USD"
    return value.formatted(.currency(code: code))
}

// MARK: - Editor

/// A simple editor for the per-kilo ingredient prices behind the cost estimate.
struct PriceListView: View {
    @ObservedObject private var prices = PriceStore.shared
    @Environment(\.dismiss) private var dismiss

    /// The groups worth editing (water/yeast are negligible or free).
    private let editable: [PriceCategory] = [
        .flour, .salt, .oil, .sweetener, .binder,
        .sauce, .cheese, .premiumCheese, .meat, .veg, .herbs, .bread,
    ]

    private var currencyCode: String { Locale.current.currency?.identifier ?? "USD" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set the price per kilo for each ingredient group, in your local currency. The shopping-list cost is only an estimate — tune these to your shop.")
                        .font(.rounded(12))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(editable, id: \.self) { cat in
                        HStack {
                            Text(cat.label)
                                .font(.rounded(15, weight: .medium))
                                .foregroundStyle(Palette.text)
                            Spacer()
                            Text(Locale.current.currencySymbol ?? "$")
                                .font(.rounded(14, weight: .medium))
                                .foregroundStyle(Palette.textSoft)
                            TextField("0", value: Binding(
                                get: { prices.pricePerKg(cat) },
                                set: { prices.setPrice(cat, $0) }
                            ), format: .number.precision(.fractionLength(0...2)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.rounded(15, weight: .semibold))
                                .foregroundStyle(Palette.accent)
                                .frame(width: 64)
                            Text("/kg")
                                .font(.rounded(12))
                                .foregroundStyle(Palette.textSoft)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .softCard(cornerRadius: 16)
                    }

                    Button { prices.resetAll() } label: {
                        Text("Reset to default prices")
                            .font(.rounded(14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(TactileButtonStyle())
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle("Ingredient prices (\(currencyCode))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rounded(16, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .tint(Palette.accent)
    }
}
