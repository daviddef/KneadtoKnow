import Foundation

/// How often the floating pizza joke pops up.
enum HumourLevel: String, CaseIterable, Identifiable, Codable {
    case less, some, lots

    var id: String { rawValue }

    var label: String {
        switch self {
        case .less: return "A little"
        case .some: return "Some"
        case .lots: return "Lots"
        }
    }

    /// The popup timer ticks every 15 s; this is how many ticks between jokes.
    /// → roughly every 3 min / 90 s / 30 s.
    var ticksBetween: Int {
        switch self {
        case .less: return 12
        case .some: return 6
        case .lots: return 2
        }
    }
}

/// A little bank of groan-worthy pizza & dough jokes. Used for the occasional
/// floating pizza popup and a random quip inside every info sheet.
enum Jokes {

    static let general = [
        "Why did the pizza maker go broke? He just couldn't make enough dough.",
        "I'm on a seafood pizza diet: I see food on a pizza, I eat it.",
        "I told a joke about pizza, but it was a little too cheesy.",
        "What's a pizza's favourite music? Anything with a lot of slice.",
        "I ordered a pizza with no crust. It was pointless — but a-round it went.",
        "Pizza is the only love triangle I'm comfortable with: me, the slice and the cheese pull.",
        "What did the pizza say to the topping? 'I never sausage a beautiful face.'",
        "Why are pizzas never lonely? They come in slices — there's always a piece for everyone.",
        "I entered a pizza-eating contest. I lost by a crust.",
        "What do you call a sleeping pizza? A piiiizzZZa.",
        "How do you fix a broken pizza? With tomato paste.",
        "Why did the pizza apply for a loan? It was a little short on dough.",
        "What's a pizza's life motto? Live every slice to the fullest.",
        "I have a pizza-shaped hole in my heart. And, somehow, in my pizza.",
        "My doctor told me to cut back on pizza. So now I order it pre-sliced.",
        "What do you call a pizza that plays it cool? A little extra calm-and-cheese.",
        "Round food, square box, triangle slices. Pizza is a shape conspiracy and I'm here for it.",
        "What does a pizza say before a fight? 'Let's settle this, slice to slice.'",
        "I'm not obsessed with pizza — it's just the only thing I knead.",
        "Why did the pizza go to therapy? Deep-dish issues.",
        "What do you call a counterfeit pizza? A pepper-phony.",
        "Why did the crust break up with the topping? It needed a bit of space to breathe.",
        "What's a ghost's favourite pizza? One with boo-ffalo mozzarella.",
        "What kind of person doesn't like pizza? A weir-dough.",
        "I dropped my pizza on the floor and shouted 'a-cheese-us!'",
        "Pizza: round, but somehow never pointless.",
        "Why are pizzas terrible at tennis? They keep dropping the crust.",
        "Why don't secrets survive around pizza? Someone always spills the sauce.",
        "What do you call a pizza detective? A pepper-spy-roni.",
        "How does a pizza answer the phone? 'Aaah-llo, you've reached the hot line.'",
        "My favourite exercise is a cross between a lunge and a crunch — it's called lunch.",
        "Why did the pizzaiolo win the award? He was a cut above the rest of the crust.",
        "What did the slice say to the topping it fancied? 'You've got a pizza my heart.'",
        "I ordered a pizza in Italy and it was so good I almost a-pizza-logised for doubting it.",
        "What's a pizza's least favourite day? Knead-day. Every day, really.",
        "Why did the mushroom keep getting invited back? He really knew how to top the bill.",
        "Pizza is proof that with a little warmth and time, flat things rise to greatness.",
        "I asked the waiter if my pizza would be long. He said no — it'll be round.",
        "I'm reading a thriller about a stolen pizza. There's a lot of cheese at steak.",
        "Why did the pizza get a promotion? Outstanding crust in the workplace.",
        "A calzone is just a pizza that got too shy to show its toppings.",
        "What's a pizza's favourite martial art? Dough-jo karate.",
        "I asked my pizza for relationship advice. It said 'don't be so saucy.'",
        "What did the oven say to the pizza? 'You're looking hot today.'",
        "Why don't pizzas play hide and seek? Good luck hiding that smell.",
        "What's a pizza's favourite Shakespeare line? 'To brie, or not to brie.'",
        "Pizza delivery: the only time 'a-round the corner' is genuinely great news.",
        "I gave my pizza a pep talk and now it's full of pepper-roni-tude.",
        "What do you call a nervous pizza? A little shy of a full topping.",
        "My pizza joined a band — it's the one that really brings the slices.",
        "Why did the calzone blush? It heard what the pizza was stuffed with.",
        "What's the most honest pizza? One with nothing to hide — extra cheese aside.",
        "I trusted a pizza with a secret. Big mistake — it folded immediately.",
    ]

    static let poolish = [
        "A poolish walks into a bar. Twelve hours later it's the life of the party.",
        "Why is poolish so chilled out? It's 100% well-hydrated.",
        "Poolish: because 'wet flour soup left out overnight' didn't test well with focus groups.",
        "My poolish got so bubbly it left me on read and went to a rave.",
        "Poolish is just dough that went to a pool party and came back glowing.",
        "How wet is a poolish? It's basically dough doing the backstroke.",
        "My poolish has rested for 12 hours. Honestly — goals.",
        "Poolish: proof that doing nothing, wetly, for ages, is a legitimate skill.",
    ]

    static let biga = [
        "Biga deal? Honestly, yes — it's a pretty stiff commitment.",
        "Why did the biga skip the gym? It was already incredibly well-developed.",
        "I asked my biga to loosen up. It said 'no chance, I'm only 50% water'.",
        "Biga by name, biga by nature — it doesn't do things by halves. By 50% hydration, technically.",
        "A biga is just a poolish that started lifting weights.",
        "Why is biga so dependable? It never goes soft on a promise.",
        "Biga walked into the gym. The gym walked out.",
        "My biga is stiff, aromatic and emotionally unavailable. Perfect crust, though.",
    ]

    static let autolyse = [
        "Autolyse is just dough doing nothing and somehow getting better at it. Relatable.",
        "Why did the flour and water take a break before the salt showed up? They needed some 'me time'.",
        "Autolyse: the only productive thing you can do by leaving something completely alone.",
        "My dough did an autolyse and now it's more flexible than my New Year's resolutions.",
        "Autolyse: where flour and water go for a 30-minute first date before things get serious.",
        "I tried to rush the autolyse. The dough filed a complaint with HR.",
        "Autolyse is basically mindfulness for gluten.",
        "Flour and water, resting quietly together — the original power couple.",
    ]

    static let yeast = [
        "Why was the yeast such a great employee? It always knew how to rise to the occasion.",
        "I'm reading a book about yeast — I can't put it down, it keeps rising.",
        "Don't trust old yeast. It's been a little flat lately.",
        "Yeast are tiny, but boy do they loaf around all day.",
        "The yeast told a joke and really got a rise out of the room.",
        "Yeast are the original influencers — absolutely massive on the rise.",
        "How does yeast say hello? 'Well, well, well… look who's rising.'",
        "A yeast cell's favourite exercise? The bread-lift.",
        "Yeast's motto: work hard, rise often, peak before you collapse.",
        "What's yeast's favourite genre? Anything with a strong build and a big drop.",
    ]

    static let dough = [
        "I kneaded this joke for hours. It's still a bit half-baked.",
        "Why did the dough go to therapy? It kept falling apart under pressure.",
        "What do you call dough that won't rise? A sad sack of flour.",
        "My dough and I have great chemistry — it's pure gluten attraction.",
        "Me and my dough? We have a very kneaded relationship.",
        "My dough is seriously rich — it's got loads of dough.",
        "Why was the dough so calm? It had learned to just let things rise.",
        "What's a baker's favourite dance move? The dough-si-dough.",
        "My dough has commitment issues — it won't stop pulling back.",
        "What did the dough say after a good knead? 'I feel so much more put together.'",
        "Therapist: and how does the dough make you feel? Me: supported, but also a bit sticky.",
    ]

    static let shape = [
        "Why did the dough ball blush? It saw the pizza dressing.",
        "I tried to stretch the dough and it snapped back. Even my pizza has boundaries.",
        "Shaping pizza is 10% skill and 90% pretending you meant to make it that shape.",
        "Roll a Neapolitan with a rolling pin and a pizzaiolo somewhere feels a disturbance in the crust.",
        "I stretched my dough so thin I could read the recipe through it. Mistake.",
        "My pizza came out heart-shaped. I said it was on purpose. It was not on purpose.",
        "Shaping dough is like parenting: stretch too hard and it tears, look away and it spreads everywhere.",
        "They said 'just gently coax it into a circle.' My circle has opinions.",
    ]

    static let toppings = [
        "I put my watch on the pizza — I wanted to make it on thyme.",
        "Why did the mushroom get invited to the pizza party? Because he's a fun-guy.",
        "Less is more with toppings… unless it's cheese, in which case more is more.",
        "Pineapple on pizza isn't the problem. It's the arguments that are toxic.",
        "Two tomatoes on a pizza. One says 'we make a great pair.' The other: 'you say that to all the pizzas.'",
        "Anchovies: the topping that turns one pizza into two arguments.",
        "What's the most romantic topping? Hugs and basil.",
        "I asked for extra cheese. The pizza whispered, 'say no mo-zzarella.'",
    ]

    static let bake = [
        "A watched pizza never browns; a forgotten one becomes charcoal. Balance is everything.",
        "My oven and I have a hot-and-cold relationship — mostly I wish it ran hotter.",
        "Pizza stone: because 'aggressively heated rock' sounds less premium.",
        "Why did the pizza hit the gym before baking? To get a little more oven-ready.",
        "I told my pizza stone to chill. It said 'absolutely not, I peaked at 450.'",
        "Why did the pizza go to school? To come out a little more well-bread.",
        "Pizza ovens run hot — much like my opinions about pineapple.",
        "Bake it till you make it.",
    ]

    static let proof = [
        "Patience is a virtue — especially when your dinner is busy fermenting.",
        "Cold proof: teaching your dough that good things come to those who fridge.",
        "I asked the dough how long it'd be. It said 'I'll rise when I'm ready.' Bold.",
        "Warm proof is just a spa day for yeast.",
        "Cold proofing is the dough's gap year — comes back with way more personality.",
        "Good dough, like good gossip, takes time to develop.",
        "Proofing: dough doing absolutely nothing and calling it 'developing flavour.' Iconic.",
        "I told the dough to hurry up. It told me about delayed gratification.",
        "Proofing is the dough's beauty sleep — wake it too early and it's grumpy and flat.",
        "Why did the dough refuse to be rushed? It had its own time-zone: dough-clock.",
    ]

    // MARK: Non-repeating draw

    /// Per-category shuffle bags so jokes don't repeat until the pool runs out.
    private static var bags: [String: [String]] = [:]

    private static func draw(_ pool: [String], _ key: String) -> String {
        guard !pool.isEmpty else { return "" }
        var bag = bags[key] ?? []
        if bag.isEmpty { bag = pool.shuffled() }
        let joke = bag.removeLast()
        bags[key] = bag
        return joke
    }

    /// A random (non-repeating) joke for the floating popup.
    static func randomGeneral() -> String {
        draw(general, "general")
    }

    /// A random joke matched to whatever an info sheet is about.
    static func forTopic(id: String, title: String) -> String {
        let key = (id + " " + title).lowercased()
        if key.contains("poolish") { return draw(poolish, "poolish") }
        if key.contains("biga") { return draw(biga, "biga") }
        if key.contains("autolyse") { return draw(autolyse, "autolyse") }
        if key.contains("yeast") || key.contains("starter") { return draw(yeast, "yeast") }
        if key.contains("ball") || key.contains("pan") || key.contains("shape") { return draw(shape, "shape") }
        if key.contains("top") { return draw(toppings, "toppings") }
        if key.contains("bake") || key.contains("oven") { return draw(bake, "bake") }
        if key.contains("ready") || key.contains("serve") || key.contains("schedule")
            || key.contains("ferment") || key.contains("proof") || key.contains("temperature") { return draw(proof, "proof") }
        if key.contains("dough") { return draw(dough, "dough") }
        return draw(general, "general")
    }
}
