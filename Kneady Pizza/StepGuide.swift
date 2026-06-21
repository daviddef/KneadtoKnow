import Foundation

/// Per-step reference material — the kit that helps and the concept behind a
/// step — shared by the ⓘ info sheet and the landscape cooking view.
enum StepGuide {
    /// The kit that helps with a given timeline step.
    static func tools(_ title: String) -> [String] {
        if title.hasPrefix("Fold ") {
            return ["A small bowl of water for your hand", "A roomy bowl or tub with a lid"]
        }
        switch title {
        case "The Poolish", "The Biga":
            return ["Digital scale (0.1 g for the yeast)", "Bowl + whisk or fork", "Cover or a lidded tub"]
        case "Autolyse":
            return ["Mixing bowl", "Cover or cling film"]
        case "The Dough":
            return ["Digital kitchen scale", "Large mixing bowl", "Dough scraper", "A little olive oil"]
        case "Bulk Rise":
            return ["A lidded tub or covered bowl", "A warm-ish spot out of draughts"]
        case "Ball Roll":
            return ["Dough scraper", "Fine semolina", "An airtight tray or proofing boxes"]
        case "Into Pans", "Into the Pan":
            return ["A metal baking pan", "Olive oil to coat it well"]
        case "Ready It":
            return ["Just counter space — let it warm up"]
        case "Shape It":
            return ["Fine semolina (not flour)", "A pizza peel"]
        case "Dimple & Brine":
            return ["Well-oiled fingers", "A small bowl for the oil-water-salt brine"]
        case "Top It":
            return ["A ladle or spoon for sauce", "A box grater for the cheese"]
        case "Bake It":
            return ["A pizza stone or steel", "A pizza peel", "Oven gloves"]
        default:
            return []
        }
    }

    /// Plain-English explainer for the concept behind a step.
    static func concept(_ title: String) -> String? {
        switch title {
        case "The Poolish":
            return "A poolish is a loose, 100%-hydration pre-ferment — equal parts flour and water with a pinch of yeast, left to bubble for around 12 hours. Mixing some of your flour ahead like this builds flavour, extensibility and a lighter crumb."
        case "The Biga":
            return "A biga is a stiff, ~50%-hydration Italian pre-ferment with a little yeast, rested around 16 hours (often somewhere cool). It gives the dough extra strength and a deeper, slightly tangy, aromatic flavour."
        case "Autolyse":
            return "An autolyse is a short rest with just the flour and water — no salt or yeast yet. The flour hydrates fully and the dough relaxes, so it stretches far more easily later."
        case "The Dough":
            return "This is the final mix, where everything comes together. It then has its first long rise as one mass — the bulk ferment — which is where most of the flavour and structure develop."
        case "Ball Roll", "Into Pans":
            return "The dough is divided and shaped into balls (or pressed into pans) so each portion proofs evenly and is ready to stretch. This final rest is called the proof."
        case "Ready It":
            return "Cold dough is tight and tears easily. Letting it come back to room temperature first relaxes the gluten so it shapes without fighting back."
        case "Shape It":
            return "Shaping is stretching each ball into a base by hand — from the centre outwards, never with a rolling pin, so you keep the air in the rim."
        case "Top It":
            return "Toppings go on in the order that bakes best — usually sauce, then cheese, then the rest. Go light so the base doesn't turn soggy."
        case "Bake It":
            return "The bake. The hotter your oven and the more preheated your stone or steel, the better the crust."
        default:
            return nil
        }
    }
}
