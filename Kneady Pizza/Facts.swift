import Foundation

/// "Did you know" nuggets that float up alongside the coaching tips: the origin
/// of each style and the place it comes from, history of pizza itself, ingredient
/// trivia and topping ideas. Style-specific facts are biased toward whatever the
/// baker has selected, so a Neapolitan baker hears about Naples.
enum Facts {

    // MARK: Per-style — origin & sense of place (keyed by PizzaStyle.id)

    static let byStyle: [String: [String]] = [
        "neapolitan": [
            "The Margherita is said to have been made in 1889 for Queen Margherita of Savoy — tomato, mozzarella and basil for the red, white and green of the new Italian flag.",
            "Naples is the birthplace of pizza as we know it: cheap, fast street food for the city's working poor in the 1700s and 1800s.",
            "True Neapolitan pizza bakes in a wood oven at around 430–480 °C for just 60–90 seconds — that char on the rim is called the 'leoparding'.",
            "UNESCO added the 'art of the Neapolitan pizzaiuolo' to its list of intangible cultural heritage in 2017.",
            "The Associazione Verace Pizza Napoletana lays down strict rules: 00 flour, San Marzano tomatoes, buffalo or fior di latte mozzarella, and a hand-stretched base no thicker than a few millimetres.",
            "Pizza marinara is older than the Margherita — named for fishermen's wives ('alla marinara'), it has no seafood at all, just tomato, garlic, oregano and oil.",
        ],
        "neapolitan-contemporary": [
            "The puffy, dramatic rim of contemporary Neapolitan is nicknamed the 'canotto' — Italian for a little rubber dinghy.",
            "This high-hydration, big-cornicione look took off in Naples in the 2010s as a modern riff on the classic thin base.",
            "A favourite modern Naples topping is added cold after baking: mortadella, a cloud of stracciatella and crushed pistachio.",
            "The airy, leopard-spotted crust relies on a long, slow ferment and a screaming-hot oven to puff the rim before the middle sets.",
        ],
        "newyork": [
            "Lombardi's in Manhattan, licensed in 1905, is recognised as the first pizzeria in the United States.",
            "Classic New York slices were baked in coal-fired ovens — today's gas deck ovens are why the style runs a little drier and chewier.",
            "The 'New York fold' — folding a slice lengthways to eat it on the move — is practically the city's official grip.",
            "A touch of sugar and oil in the dough helps a New York crust brown and crisp in a cooler oven than Naples uses.",
            "New York's water is local legend: many swear the city's soft tap water is the secret to its bagels and pizza crust alike.",
        ],
        "roman": [
            "Pizza tonda romana is prized for being 'scrocchiarella' — so thin and crisp it audibly cracks when you bite it.",
            "Romans often add a little olive oil to the dough, which helps it roll out paper-thin and crisp rather than puff up.",
            "Don't confuse it with pizza al taglio or pinsa — those are the thick, high-hydration Roman styles sold by the slice and weight.",
            "Rome's thin round pizza is traditionally eaten one-per-person at the table, knife and fork in hand.",
        ],
        "detroit": [
            "Detroit-style pizza was first baked in 1946 at Buddy's Rendezvous — in blue steel pans originally made to hold automotive parts.",
            "The crunchy, lacy cheese edge is called 'frico', made by pushing cheese right to the walls of the pan.",
            "It's traditionally topped with Wisconsin brick cheese, which browns without going greasy.",
            "The sauce goes on last, ladled in stripes over the cheese — bakers call them 'racing stripes'.",
        ],
        "sfincione": [
            "Sfincione comes from Palermo in Sicily; the name traces to 'sfincia', meaning sponge — a nod to its thick, soft, airy crumb.",
            "It's usually finished with breadcrumbs, onions, anchovy and caciocavallo or pecorino rather than mozzarella.",
            "Sfincione is the ancestor of the thick American 'Sicilian slice' carried over by immigrants from Palermo.",
            "Traditionally a Christmas and New Year's treat in Palermo, sold from carts by 'sfincionari'.",
        ],
        "focaccia": [
            "Focaccia takes its name from the Latin 'panis focacius' — bread baked on the hearth ('focus', the fire).",
            "Genoa's focaccia is so beloved it's eaten for breakfast, sometimes dunked in a cappuccino.",
            "Those signature dimples aren't just for looks — they catch pools of olive oil and stop the bread doming as it bakes.",
            "Liguria's focaccia di Recco is the odd one out: unleavened, paper-thin and stuffed with soft cheese.",
        ],
        "everyday": [
            "Flatbreads topped with oil and herbs go back thousands of years — the ancient Greeks ate 'plakous' and the Romans 'panis focacius'.",
            "The word 'pizza' appears in a Latin document from Gaeta, south of Rome, in 997 AD — long before tomatoes ever reached Italy.",
            "A home oven and a good steel can get you surprisingly close to pizzeria results — the trick is heat, and lots of it.",
        ],
    ]

    // MARK: Pizza history

    static let history = [
        "Tomatoes only reached Europe from the Americas in the 1500s — and were feared as poisonous at first, partly because their acid leached lead from pewter plates.",
        "For its first centuries pizza had no tomato at all; early versions were flatbreads with oil, garlic, herbs or cheese.",
        "Pizza spread across the world with Italian emigrants in the late 1800s, then boomed globally after WWII soldiers came home craving it.",
        "The first recorded use of the word 'pizza' dates to 997 AD in Gaeta, Italy.",
        "Until the 1800s pizza was looked down on as poor people's food — it took a queen's endorsement to make it respectable.",
    ]

    // MARK: Ingredient trivia

    static let ingredients = [
        "San Marzano tomatoes get their sweetness and low acidity from the volcanic soil at the foot of Mount Vesuvius, and carry a protected DOP status.",
        "'00' on a flour bag refers to how finely it's milled, not how strong it is — you still need to check the protein for a long ferment.",
        "Mozzarella di bufala is made from water-buffalo milk; the firmer, less watery cow's-milk version is 'fior di latte', often preferred on pizza.",
        "Salt does double duty in dough: it tightens the gluten for structure and reins in the yeast so the rise stays under control.",
        "Fine semolina on the peel acts like tiny ball-bearings, letting the pizza slide off cleanly without burning like flour can.",
        "Fresh mozzarella holds a lot of water — tearing and draining it before baking is the difference between molten and soggy.",
        "Good extra-virgin olive oil added after baking tastes greener and more peppery than oil that's been cooked.",
    ]

    // MARK: Topping ideas

    static let toppings = [
        "Try a 'pizza bianca' — no tomato at all, just olive oil, garlic, rosemary and a little salt.",
        "Potato and rosemary pizza sounds odd but is a Roman classic: very thin potato slices, oil and salt.",
        "Quattro formaggi, quattro stagioni, diavola (spicy salami), capricciosa (ham, artichoke, mushroom, olive) — the old menu names each tell a little story.",
        "Spicy honey over hot salami — the 'bee sting' — has become a modern pizzeria favourite for good reason.",
        "Add prosciutto, rocket or fresh basil after the bake, never before, so they stay fragrant instead of wilting to nothing.",
        "'Nduja, the soft spicy spreadable salami from Calabria, melts into the cheese for a fiery kick.",
        "Mortadella, stracciatella and crushed pistachio piled on after baking is the topping Naples is obsessed with right now.",
        "New Haven's famous white clam pie skips tomato entirely: clams, garlic, oregano and a hit of olive oil.",
    ]

    // MARK: Non-repeating draw

    private static var bags: [String: [String]] = [:]

    private static func draw(_ pool: [String], _ key: String) -> String {
        guard !pool.isEmpty else { return "" }
        var bag = bags[key] ?? []
        if bag.isEmpty { bag = pool.shuffled() }
        let fact = bag.removeLast()
        bags[key] = bag
        return fact
    }

    /// A fact, biased toward the currently selected style when one is supplied.
    static func random(styleID: String?) -> String {
        if let id = styleID, let pool = byStyle[id], !pool.isEmpty,
           Int.random(in: 0..<100) < 55 {
            return draw(pool, "style-\(id)")
        }
        return draw(history + ingredients + toppings, "general")
    }
}
