import Foundation
import SwiftUI

// MARK: - Inputs & outputs

enum SizeMode: String, CaseIterable, Identifiable {
    case diameter, weight
    var id: String { rawValue }
}

enum LengthUnit: String, CaseIterable, Identifiable {
    case cm, inch
    var id: String { rawValue }
    var label: String { self == .cm ? "cm" : "in" }
    var toCentimetres: Double { self == .cm ? 1.0 : 2.54 }
}

/// One line of the final recipe.
struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let grams: Double
    let note: String?

    init(_ name: String, _ grams: Double, note: String? = nil) {
        self.name = name
        self.grams = grams
        self.note = note
    }
}

/// A named group of ingredients — e.g. the poolish, then the final dough.
struct RecipeStage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let note: String?
    let ingredients: [Ingredient]
}

/// How flour and water divide across the two pre-ferment stages.
struct PrefermentSplit {
    let name: String
    let hydration: Double
    let prefermentFlour: Double
    let prefermentWater: Double
    let prefermentYeast: Double
    let prefermentYeastPct: Double
    let prefermentTotal: Double
    let finalFlour: Double
    let finalWater: Double
    let totalFlour: Double
    let restHours: Double
}

struct DoughResult {
    let totalWeight: Double
    let ballWeight: Double
    let ballCount: Int
    let stages: [RecipeStage]
    let shape: PizzaShape
    /// Present only when a pre-ferment (poolish or biga) is in use.
    let prefermentSplit: PrefermentSplit?
}

/// Everything the user can set.
struct DoughInput {
    var style: PizzaStyle = .neapolitan
    var ballCount: Int = 6

    var sizeMode: SizeMode = .weight
    var lengthUnit: LengthUnit = .cm
    var diameter: Double = 30          // round: diameter, in `lengthUnit`
    var panLength: Double = 35         // rectangular: long side, in `lengthUnit`
    var panWidth: Double = 25          // rectangular: short side, in `lengthUnit`
    var ballWeight: Double = 270       // grams, when sizing by weight

    /// "Keep it simple" mode: hide the advanced choices and let the chosen
    /// pizza style set them automatically. On by default.
    var keepItSimple: Bool = true

    /// Playful pizza jokes — whether they show, and how often.
    var humourEnabled: Bool = true
    var humourLevel: HumourLevel = .some
    /// Level-appropriate coaching tips in the floating popups.
    var tipsEnabled: Bool = true

    /// When the user wants to eat — the timeline is worked backward from here.
    var serveDate: Date = Date().addingTimeInterval(24 * 3600)
    var temperatureC: Double = 20

    /// Quick (warm) / same-day (room) / cold (fridge) fermentation.
    var ferment: FermentStyle = .sameDay

    /// Oven used for baking — sets the bake temperature/time advice.
    var oven: OvenType = .home

    var yeast: YeastType = .IDY

    // Pre-ferment (only meaningful with commercial yeast). Default per style.
    var usePreferment: Bool = true
    var preferment: Preferment = .poolish
    var prefermentPct: Double = 0.30   // fraction of the total flour

    /// Autolyse: rest flour + water alone before adding salt & yeast.
    var useAutolyse: Bool = true

    /// Gluten-free mode: swaps to a GF flour blend, adds a binder to stand in for
    /// gluten, raises hydration to the style's GF target and drops pre-ferments.
    var glutenFree: Bool = false
    /// Which binder replaces the gluten network when `glutenFree` is on.
    var binder: BinderType = .xanthan
    /// Set when the user's GF flour blend already contains a binder — suppresses
    /// the added binder so the dough doesn't turn gummy.
    var binderInBlend: Bool = false

    // Adjustable baker's percentages (seeded from the style).
    var hydration: Double = PizzaStyle.neapolitan.hydration
    var salt: Double = PizzaStyle.neapolitan.salt
    var oil: Double = PizzaStyle.neapolitan.oil
    var honey: Double = PizzaStyle.neapolitan.honey

    /// Re-seed the editable percentages from a style.
    mutating func applyDefaults(of style: PizzaStyle) {
        self.style = style
        hydration = style.hydration
        salt = style.salt
        oil = style.oil
        honey = style.honey
        ballWeight = style.defaultBallWeight
        // In simple mode the style sizes the dough by its default ball weight.
        if keepItSimple { sizeMode = .weight }
        // Keep the chosen yeast valid for this style.
        if !style.yeasts.contains(yeast) { yeast = style.recommendedYeast }
        // Adopt the style's recommended pre-ferment & autolyse.
        switch style.defaultPreferment {
        case .none:
            usePreferment = false
        case .poolish:
            usePreferment = true; preferment = .poolish; prefermentPct = Preferment.poolish.defaultPct
        case .biga:
            usePreferment = true; preferment = .biga; prefermentPct = Preferment.biga.defaultPct
        }
        useAutolyse = style.defaultAutolyse

        // Gluten-free overrides: much higher hydration, no wheat-style pre-ferment
        // or gluten-developing autolyse (the dough is pressed, not stretched).
        if glutenFree {
            hydration = style.glutenFreeHydration
            usePreferment = false
            useAutolyse = false
        }

        // Keep-it-simple favours a forgiving, biggest-within-tolerance ball for
        // round pizzas (easier for beginners to stretch without tearing).
        if keepItSimple && style.shape == .round { ballWeight = 280 }
    }

    /// Pre-ferments only apply to commercial yeasts — sourdough is itself one,
    /// a Quick dough is too fast for a long pre-ferment rest, and gluten-free
    /// dough has no gluten for a biga/poolish to strengthen.
    var prefermentAvailable: Bool { !glutenFree && !yeast.isSourdough && ferment != .quick }
    /// Keep-it-simple mode is always a direct dough — no poolish/biga.
    var prefermentActive: Bool { usePreferment && prefermentAvailable && !keepItSimple }

    /// Autolyse is skipped for a Quick dough (it's too fast, and the warm-water
    /// quick mix takes over). The toggle value is kept so switching back to a
    /// Warm/Cold proof restores the previous choice.
    var autolyseAvailable: Bool { ferment != .quick }
    /// Keep-it-simple mode skips the autolyse too.
    var autolyseActive: Bool { useAutolyse && autolyseAvailable && !keepItSimple }
}

// MARK: - Weight guidance

/// Advice on a single ball's weight, with a colour for the slider.
struct WeightGuidance {
    enum Level { case ideal, caution, warning }
    let level: Level
    let message: String

    var color: Color {
        switch level {
        case .ideal:   return Palette.sage
        case .caution: return Palette.amber
        case .warning: return Palette.danger
        }
    }
}

// MARK: - Calculator
//
// Pure functions — no UI, no side effects — so the dough maths can be reasoned
// about and unit-tested in isolation.

enum DoughCalculator {

    // Reference conditions for the yeast model.
    private static let refTemp = 20.0     // °C
    private static let refHours = 8.0
    private static let q10 = 2.0          // fermentation rate doubles per +10 °C

    /// Weight of a single piece of dough (ball or pan), in grams.
    static func ballWeight(for input: DoughInput) -> Double {
        switch input.sizeMode {
        case .weight:
            return max(0, input.ballWeight)
        case .diameter:
            let u = input.lengthUnit.toCentimetres
            let area: Double
            if input.style.shape == .rectangular {
                area = (input.panLength * u) * (input.panWidth * u)
            } else {
                let radius = input.diameter * u / 2
                area = .pi * radius * radius
            }
            return area * input.style.thicknessFactor
        }
    }

    /// Guidance for a single piece weight. The standard pizzaiolo ranges apply
    /// to round balls; pan dough scales with the pan, so it isn't flagged.
    static func guidance(forBall grams: Double, shape: PizzaShape = .round) -> WeightGuidance {
        guard shape == .round else {
            return .init(level: .ideal, message: "Pan dough — weight scales with pan size.")
        }
        switch grams {
        case ..<150:
            return .init(level: .warning, message: "Very light — prone to tearing; cracker-thin only.")
        case 150..<200:
            return .init(level: .caution, message: "Light — best for small or thin bases.")
        case 200..<220:
            return .init(level: .ideal, message: "Great for a 10–11″ pizza.")
        case 220..<250:
            return .init(level: .ideal, message: "Thin-crust range — for confident stretchers.")
        case 250..<276:
            return .init(level: .ideal, message: "Industry standard for a 12″ pizza.")
        case 276...280:
            return .init(level: .ideal, message: "Max regulation — 13–14″, beginner-friendly.")
        case 280..<321:
            return .init(level: .caution, message: "Heavier than regulation — thick or large bases.")
        default:
            return .init(level: .warning, message: "Very heavy — pan / Detroit territory.")
        }
    }

    /// Colour-coded advice for the share of flour held in a pre-ferment.
    static func prefermentGuidance(_ pf: Preferment, value: Double) -> WeightGuidance {
        let ideal: ClosedRange<Double> = pf == .poolish ? 0.20...0.45 : 0.40...0.65
        let wide = (ideal.lowerBound - 0.10)...(ideal.upperBound + 0.15)
        if ideal.contains(value) {
            return .init(level: .ideal, message: "Typical for a \(pf.name.lowercased()).")
        } else if wide.contains(value) {
            return .init(level: .caution, message: value < ideal.lowerBound
                ? "Lower than typical — a milder pre-ferment."
                : "Higher than typical — stronger and faster.")
        } else {
            return .init(level: .warning, message: value < ideal.lowerBound
                ? "Very low — barely a pre-ferment."
                : "Very high — most of the flour is pre-fermented.")
        }
    }

    /// Colour-coded advice for an adjustable proportion.
    enum Proportion { case water, salt, oil, honey }

    static func proportionGuidance(_ kind: Proportion, value: Double, style: PizzaStyle, glutenFree: Bool = false) -> WeightGuidance {
        switch kind {
        case .water:
            // Gluten-free runs much wetter, so it gets its own range centred on
            // the style's GF target rather than the wheat hydration range.
            let r: ClosedRange<Double> = glutenFree
                ? (style.glutenFreeHydration - 0.06)...(style.glutenFreeHydration + 0.08)
                : style.hydrationRange
            let wide = (r.lowerBound - 0.07)...(r.upperBound + 0.07)
            let upperCap = glutenFree ? 1.30 : 0.95
            if r.contains(value) {
                return .init(level: .ideal, message: glutenFree ? "In range for gluten-free \(style.name)." : "In range for \(style.name).")
            } else if wide.contains(value) && value > 0.45 && value < upperCap {
                return .init(level: .caution, message: value < r.lowerBound ? "Drier than typical — stiffer dough." : "Wetter than typical — slack and sticky.")
            } else {
                return .init(level: .warning, message: value < r.lowerBound ? "Very dry — it won't come together well." : "Very wet — hard to handle, may not hold shape.")
            }
        case .salt:
            switch value {
            case 0.018...0.032: return .init(level: .ideal, message: "Well seasoned.")
            case 0.010..<0.018: return .init(level: .caution, message: "Lightly salted.")
            case 0.032...0.040: return .init(level: .caution, message: "On the salty side.")
            case ..<0.010:      return .init(level: .warning, message: "Barely any salt — bland and slack.")
            default:            return .init(level: .warning, message: "Too salty — it'll choke the yeast.")
            }
        case .oil:
            switch value {
            case ...0.055:      return .init(level: .ideal, message: "Fine for this dough.")
            case 0.055...0.085: return .init(level: .caution, message: "Rich — softer, more tender crust.")
            default:            return .init(level: .warning, message: "Very oily — it'll fry rather than bake.")
            }
        case .honey:
            switch value {
            case ...0.020:      return .init(level: .ideal, message: "Helps browning.")
            case 0.020...0.040: return .init(level: .caution, message: "Quite sweet — browns fast.")
            default:            return .init(level: .warning, message: "Too sweet — it'll scorch before it cooks.")
            }
        }
    }

    /// A leavening dose scaled from reference conditions: more for short or
    /// cold ferments, less for long or warm ones.
    private static func leaveningScale(hours: Double, tempC: Double) -> Double {
        let timeFactor = refHours / max(hours, 0.5)
        let tempFactor = pow(q10, (refTemp - tempC) / 10.0)
        return timeFactor * tempFactor
    }

    /// The full recipe. Timing (which drives yeast quantity) comes from the
    /// schedule, so the recipe and the timeline always agree.
    static func calculate(_ input: DoughInput, schedule: Schedule) -> DoughResult {
        let count = max(input.ballCount, 1)
        let ball = ballWeight(for: input)
        let totalDough = ball * Double(count)

        // Yeast scales with the fermentation that actually drives the rise
        // (room, fridge or warm), from the schedule. Quick mode bumps it hard.
        var scale = leaveningScale(hours: schedule.yeastHours, tempC: schedule.yeastTemp)
        if input.ferment == .quick { scale *= 3 }

        let stages: [RecipeStage]
        var prefermentSplit: PrefermentSplit? = nil
        if input.yeast.isSourdough {
            stages = [sourdoughStage(input: input, totalDough: totalDough, scale: scale)]
        } else if input.prefermentActive {
            let split = makePrefermentSplit(input: input, totalDough: totalDough, schedule: schedule)
            prefermentSplit = split
            stages = prefermentStages(input: input, split: split)
        } else {
            stages = [commercialStage(input: input, totalDough: totalDough, scale: scale)]
        }

        return DoughResult(
            totalWeight: totalDough,
            ballWeight: ball,
            ballCount: count,
            stages: stages,
            shape: input.style.shape,
            prefermentSplit: prefermentSplit
        )
    }

    // MARK: Direct commercial yeast (CY / ADY / IDY)

    private static func commercialStage(input: DoughInput, totalDough: Double, scale: Double) -> RecipeStage {
        let idyPct = clamp(input.style.referenceIDY * scale, 0.0001, 0.02)
        let yeastPct = idyPct * input.yeast.idyMultiplier

        let divisor = 1 + input.hydration + input.salt + input.oil + input.honey + yeastPct
        let flour = totalDough / divisor

        var items: [Ingredient] = [
            Ingredient(flourName(input), flour),
            Ingredient("Water", flour * input.hydration, note: "\(pct(input.hydration)) hydration"),
            Ingredient("Salt", flour * input.salt, note: pct(input.salt)),
            Ingredient(input.yeast.fullName, flour * yeastPct, note: pct(yeastPct)),
        ]
        items += optionalExtras(flour: flour, input: input)
        return RecipeStage(title: "Dough", note: nil, ingredients: items)
    }

    // MARK: Pre-ferment method (poolish or biga: flour + water + yeast)

    /// Works out how flour and water divide between the pre-ferment and the
    /// final dough. The pre-ferment is dosed as a fraction of the *total flour*
    /// at its own hydration (poolish 100%, biga ~50%), plus a small yeast
    /// charge; salt, oil and honey live entirely in the final dough.
    private static func makePrefermentSplit(input: DoughInput, totalDough: Double, schedule: Schedule) -> PrefermentSplit {
        let pf = input.preferment
        let pct = clamp(input.prefermentPct, 0.05, 1.0)

        let restHours = max(schedule.prefermentRestHours, 1)
        let scale = leaveningScale(hours: restHours, tempC: input.temperatureC)
        let yeastPct = clamp(pf.referenceYeast * scale, 0.0002, 0.01) * input.yeast.idyMultiplier

        // Solve total flour so everything sums to the target dough weight.
        let divisor = 1 + input.hydration + input.salt + input.oil + input.honey
        let prefYeast = (pct * (totalDough / divisor)) * yeastPct   // tiny; estimated
        let totalFlour = (totalDough - prefYeast) / divisor
        let totalWater = totalFlour * input.hydration

        let prefFlour = pct * totalFlour
        let prefWater = prefFlour * pf.hydration

        return PrefermentSplit(
            name: pf.name,
            hydration: pf.hydration,
            prefermentFlour: prefFlour,
            prefermentWater: prefWater,
            prefermentYeast: prefYeast,
            prefermentYeastPct: yeastPct,
            prefermentTotal: prefFlour + prefWater + prefYeast,
            finalFlour: max(0, totalFlour - prefFlour),
            finalWater: max(0, totalWater - prefWater),
            totalFlour: totalFlour,
            restHours: restHours
        )
    }

    private static func prefermentStages(input: DoughInput, split: PrefermentSplit) -> [RecipeStage] {
        let hydNote = "\(Int((split.hydration * 100).rounded()))% hydration"
        let prefStage = RecipeStage(
            title: split.name,
            note: "rest ≈ \(Scheduler.duration(split.restHours)), then mix",
            ingredients: [
                Ingredient("Flour", split.prefermentFlour),
                Ingredient("Water", split.prefermentWater, note: hydNote),
                Ingredient(input.yeast.fullName, split.prefermentYeast, note: pct(split.prefermentYeastPct)),
            ]
        )

        var finalItems: [Ingredient] = [
            Ingredient("All of the \(split.name.lowercased())", split.prefermentTotal,
                       note: pct(input.prefermentPct) + " of flour"),
            Ingredient("Flour", split.finalFlour),
            Ingredient("Water", split.finalWater, note: "\(pct(input.hydration)) total hydration"),
            Ingredient("Salt", split.totalFlour * input.salt, note: pct(input.salt)),
        ]
        finalItems += optionalExtras(flour: split.totalFlour, input: input)

        let finalStage = RecipeStage(title: "Final dough", note: nil, ingredients: finalItems)
        return [prefStage, finalStage]
    }

    // MARK: Sourdough (SSD / LSD)

    private static func sourdoughStage(input: DoughInput, totalDough: Double, scale: Double) -> RecipeStage {
        let starterPct = clamp(input.yeast.referenceStarter * scale, 0.03, 0.40)

        let divisor = 1 + input.hydration + input.salt + input.oil + input.honey
        let totalFlour = totalDough / divisor
        let totalWater = totalFlour * input.hydration

        let starter = starterPct * totalFlour
        let h = input.yeast.starterHydration
        let starterFlour = starter / (1 + h)
        let starterWater = starter - starterFlour

        let addedFlour = max(0, totalFlour - starterFlour)
        let addedWater = max(0, totalWater - starterWater)

        var items: [Ingredient] = [
            Ingredient(flourName(input), addedFlour),
            Ingredient("Water", addedWater, note: "\(pct(input.hydration)) hydration"),
            Ingredient(input.yeast.fullName, starter, note: "\(pct(starterPct)) of flour"),
            Ingredient("Salt", totalFlour * input.salt, note: pct(input.salt)),
        ]
        items += optionalExtras(flour: totalFlour, input: input)
        return RecipeStage(title: "Dough", note: nil, ingredients: items)
    }

    // MARK: Shared extras

    private static func optionalExtras(flour: Double, input: DoughInput) -> [Ingredient] {
        var extras: [Ingredient] = []
        // Gluten-free binder stands in for the gluten network. Skipped if the
        // user's blend already contains one (adding more turns the dough gummy).
        if input.glutenFree && !input.binderInBlend {
            extras.append(Ingredient(input.binder.label, flour * input.binder.pct,
                                     note: pct(input.binder.pct)))
        }
        if input.oil > 0 {
            extras.append(Ingredient("Olive oil", flour * input.oil, note: pct(input.oil)))
        }
        if input.honey > 0 {
            extras.append(Ingredient("Honey", flour * input.honey, note: pct(input.honey)))
        }
        return extras
    }

    // MARK: Helpers

    private static func clamp(_ x: Double, _ lo: Double, _ hi: Double) -> Double {
        min(max(x, lo), hi)
    }

    private static func pct(_ fraction: Double) -> String {
        String(format: "%.1f%%", fraction * 100)
    }

    private static func flourName(_ input: DoughInput) -> String {
        input.glutenFree ? "Gluten-free flour blend" : "Flour"
    }
}
