import Foundation

/// A persistable snapshot of the dough-defining inputs (not the time/temperature,
/// which are situational).
struct SavedRecipe: Codable {
    var styleID: String
    var ballCount: Int
    var sizeMode: String
    var lengthUnit: String
    var diameter: Double
    var panLength: Double
    var panWidth: Double
    var ballWeight: Double
    var yeast: String
    var usePreferment: Bool
    var preferment: String
    var prefermentPct: Double
    var hydration: Double
    var salt: Double
    var oil: Double
    var honey: Double
    var temperatureC: Double
    var serveDate: Date
    var ferment: String
    var oven: String
    // Optional for back-compatibility with older saved favourites.
    var pizzaSelection: [String: Int]? = nil
    var extras: [String]? = nil
    var useAutolyse: Bool? = nil
    var keepItSimple: Bool? = nil
    var humourEnabled: Bool? = nil
    var humourLevel: String? = nil
    var tipsEnabled: Bool? = nil
    var glutenFree: Bool? = nil
    var binder: String? = nil
    var binderInBlend: Bool? = nil
}

/// Remembers whether the favourite should update itself automatically.
enum AutosaveStore {
    private static let key = "autosaveFavourite.v1"
    static var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

/// Persists the user's custom "extra" ingredients so they're offered again.
enum CustomExtrasStore {
    private static let key = "customExtras.v1"
    static func load() -> [String] { UserDefaults.standard.stringArray(forKey: key) ?? [] }
    static func save(_ list: [String]) { UserDefaults.standard.set(list, forKey: key) }
}

/// Stores the user's "My Favourite" recipe in UserDefaults.
enum FavouriteStore {
    private static let key = "myFavouriteRecipe.v1"

    static func save(_ recipe: SavedRecipe) {
        if let data = try? JSONEncoder().encode(recipe) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> SavedRecipe? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SavedRecipe.self, from: data)
    }

    static func clear() { UserDefaults.standard.removeObject(forKey: key) }
}

extension DoughInput {
    /// A snapshot of every setting, suitable for saving.
    var saved: SavedRecipe {
        SavedRecipe(
            styleID: style.id,
            ballCount: ballCount,
            sizeMode: sizeMode.rawValue,
            lengthUnit: lengthUnit.rawValue,
            diameter: diameter,
            panLength: panLength,
            panWidth: panWidth,
            ballWeight: ballWeight,
            yeast: yeast.rawValue,
            usePreferment: usePreferment,
            preferment: preferment.rawValue,
            prefermentPct: prefermentPct,
            hydration: hydration,
            salt: salt,
            oil: oil,
            honey: honey,
            temperatureC: temperatureC,
            serveDate: serveDate,
            ferment: ferment.rawValue,
            oven: oven.rawValue,
            useAutolyse: useAutolyse,
            keepItSimple: keepItSimple,
            humourEnabled: humourEnabled,
            humourLevel: humourLevel.rawValue,
            tipsEnabled: tipsEnabled,
            glutenFree: glutenFree,
            binder: binder.rawValue,
            binderInBlend: binderInBlend
        )
    }

    /// Rebuilds an input from a saved snapshot — every setting restored.
    static func from(_ r: SavedRecipe) -> DoughInput {
        var i = DoughInput()
        i.style = PizzaStyle.all.first { $0.id == r.styleID } ?? .neapolitan
        i.ballCount = r.ballCount
        i.sizeMode = SizeMode(rawValue: r.sizeMode) ?? .weight
        i.lengthUnit = LengthUnit(rawValue: r.lengthUnit) ?? .cm
        i.diameter = r.diameter
        i.panLength = r.panLength
        i.panWidth = r.panWidth
        i.ballWeight = r.ballWeight
        i.yeast = YeastType(rawValue: r.yeast) ?? .IDY
        i.usePreferment = r.usePreferment
        i.preferment = Preferment(rawValue: r.preferment) ?? .poolish
        i.prefermentPct = r.prefermentPct
        i.hydration = r.hydration
        i.salt = r.salt
        i.oil = r.oil
        i.honey = r.honey
        i.temperatureC = r.temperatureC
        i.serveDate = r.serveDate
        i.ferment = FermentStyle(rawValue: r.ferment) ?? .sameDay
        i.oven = OvenType(rawValue: r.oven) ?? .home
        i.useAutolyse = r.useAutolyse ?? i.useAutolyse
        i.keepItSimple = r.keepItSimple ?? true
        i.humourEnabled = r.humourEnabled ?? true
        i.humourLevel = r.humourLevel.flatMap(HumourLevel.init) ?? .some
        i.tipsEnabled = r.tipsEnabled ?? true
        i.glutenFree = r.glutenFree ?? false
        i.binder = r.binder.flatMap(BinderType.init) ?? .xanthan
        i.binderInBlend = r.binderInBlend ?? false
        return i
    }
}
