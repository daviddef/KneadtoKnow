import SwiftUI

/// One multiple-choice question about a style's real history — including,
/// deliberately, questions that test whether a "fact" is actually disputed
/// rather than settled, since several beloved pizza origin stories are.
struct HistoryQuestion: Identifiable {
    let id = UUID()
    let styleName: String
    let question: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String
}

enum HistoryQuizBank {
    static let all: [HistoryQuestion] = [
        // Neapolitan Classic
        HistoryQuestion(styleName: "Neapolitan Classic",
            question: "What ingredient, once feared as poisonous in Europe, became Naples' essential pizza topping in the early 1700s?",
            choices: ["Basil", "Tomato", "Mozzarella", "Olive oil"], correctIndex: 1,
            explanation: "Tomatoes arrived from the Americas in the 1500s and were long thought poisonous before Naples' poor adopted them."),
        HistoryQuestion(styleName: "Neapolitan Classic",
            question: "True or false: historians agree with certainty that Queen Margherita's 1889 visit is exactly how the Margherita pizza got its name.",
            choices: ["True", "False"], correctIndex: 1,
            explanation: "The story is widely told, but historians consider it partly legend — what's certain is the name stuck from 1889 onward."),
        HistoryQuestion(styleName: "Neapolitan Classic",
            question: "What did UNESCO recognize about Neapolitan pizza-making in 2017?",
            choices: ["A World Heritage Site", "Intangible Cultural Heritage", "A Slow Food Presidium", "A Michelin Star"], correctIndex: 1,
            explanation: "UNESCO inscribed \"The Art of Neapolitan Pizzaiuoli\" as Intangible Cultural Heritage of Humanity."),

        // New York
        HistoryQuestion(styleName: "New York",
            question: "What fuel gave early New York pizza its bigger size and crispier crust compared to Naples?",
            choices: ["Wood", "Coal", "Gas", "Electric"], correctIndex: 1,
            explanation: "New York's pizzerias used coal-fired ovens — hotter than wood, allowing bigger pies with a crispier char."),
        HistoryQuestion(styleName: "New York",
            question: "True or false: it's scientifically proven that New York's tap water is the secret to its pizza's taste.",
            choices: ["True", "False"], correctIndex: 1,
            explanation: "It's a popular theory, but no definitive research has ever confirmed the \"NYC water\" claim."),
        HistoryQuestion(styleName: "New York",
            question: "What decade saw the rise of New York's famous \"dollar slice\"?",
            choices: ["1950s", "1970s", "1990s", "2010s"], correctIndex: 2,
            explanation: "Cheap cheese and canned sauce gave rise to $1-slice culture in the 1990s."),

        // Roman Tonda
        HistoryQuestion(styleName: "Roman Tonda",
            question: "What's the nickname for Roman tonda's famously crisp crust?",
            choices: ["Frico", "Cornicione", "Scrocchiarella", "Canotto"], correctIndex: 2,
            explanation: "\"Scrocchiarella\" means roughly \"the crispy one\" — Roman tonda's signature snap."),
        HistoryQuestion(styleName: "Roman Tonda",
            question: "How is Rome's rectangular \"pizza al taglio\" traditionally sold?",
            choices: ["By the whole pie only", "By weight", "Only on Sundays", "Frozen"], correctIndex: 1,
            explanation: "Pizza al taglio has been sold by weight, cut to order, since the style rose through the 1960s."),
        HistoryQuestion(styleName: "Roman Tonda",
            question: "True or false: \"pinsa romana\" is an authentic recipe passed down since ancient Rome.",
            choices: ["True", "False"], correctIndex: 1,
            explanation: "Despite the ancient-sounding name, pinsa is a modern, patented flour blend from the 2000s."),

        // Detroit / Pan
        HistoryQuestion(styleName: "Detroit / Pan",
            question: "What kind of business did Gus and Anna Guerra convert into Detroit's first pizzeria in 1946?",
            choices: ["A bakery", "A speakeasy", "A gas station", "A grocery store"], correctIndex: 1,
            explanation: "Buddy's Rendezvous started as a speakeasy before becoming Detroit's first pizza spot in 1946."),
        HistoryQuestion(styleName: "Detroit / Pan",
            question: "True or false: historians have fully confirmed Detroit's pans really were repurposed automotive factory parts trays.",
            choices: ["True", "False"], correctIndex: 1,
            explanation: "It's beloved Detroit lore — even Gus Guerra's own son wasn't certain, and one historian found the family also mentioned a hardware store."),
        HistoryQuestion(styleName: "Detroit / Pan",
            question: "What cheese is pressed to a Detroit pizza's edges to create its caramelized crust?",
            choices: ["Mozzarella", "Parmesan", "Wisconsin brick cheese", "Provolone"], correctIndex: 2,
            explanation: "Wisconsin brick cheese caramelizes against the hot steel pan into the signature \"frico\" edge."),

        // Sicilian Sfincione
        HistoryQuestion(styleName: "Sicilian Sfincione",
            question: "What does the word \"sfincione\" relate to?",
            choices: ["Sponge", "Sun", "Salt", "Sicily"], correctIndex: 0,
            explanation: "\"Sfincione\" relates to \"spugna\" (sponge) — describing its thick, airy crumb."),
        HistoryQuestion(styleName: "Sicilian Sfincione",
            question: "Traditional sfincione is topped with caciocavallo cheese and breadcrumbs — never with...",
            choices: ["Anchovies", "Onions", "Mozzarella", "Tomato sauce"], correctIndex: 2,
            explanation: "Traditional sfincione never uses mozzarella — that's a hallmark of the different, Americanized \"Sicilian pizza.\""),
        HistoryQuestion(styleName: "Sicilian Sfincione",
            question: "Sfincione is traditionally central to which meal in Palermo?",
            choices: ["Easter brunch", "Christmas Eve dinner", "A summer wedding", "New Year's breakfast"], correctIndex: 1,
            explanation: "Sfincione is a fixture of Palermo's Christmas Eve (Vigilia) table, alongside baccalà."),

        // Focaccia
        HistoryQuestion(styleName: "Focaccia",
            question: "The word \"focaccia\" comes from the Latin word for...",
            choices: ["Flour", "Hearth", "Oil", "Sponge"], correctIndex: 1,
            explanation: "\"Panis focacius\" — bread of the hearth (Latin focus = hearth)."),
        HistoryQuestion(styleName: "Focaccia",
            question: "Which region is most associated with the modern, olive-oil-rich focaccia we know today?",
            choices: ["Sicily", "Rome", "Liguria (Genoa)", "Naples"], correctIndex: 2,
            explanation: "Genoa, in Liguria, developed the softer, yeasted style known today as focaccia genovese."),
        HistoryQuestion(styleName: "Focaccia",
            question: "What's the purpose of dimpling focaccia dough with your fingers?",
            choices: ["Decoration only", "To let steam escape", "To hold pools of oil and salt", "To measure the dough"], correctIndex: 2,
            explanation: "The dimples hold pools of olive oil and coarse salt — focaccia's defining gesture."),

        // Neapolitan Contemporary
        HistoryQuestion(styleName: "Neapolitan Contemporary",
            question: "What part of the pizza became the star of the \"contemporary\" Neapolitan movement?",
            choices: ["The sauce", "The cornicione (crust rim)", "The cheese", "The base"], correctIndex: 1,
            explanation: "Contemporary pizzaioli chase a taller, airier, more dramatic cornicione — the crust rim."),
        HistoryQuestion(styleName: "Neapolitan Contemporary",
            question: "The exaggerated, raft-like puffed crust style is nicknamed...",
            choices: ["Canotto", "Scrocchiarella", "Frico", "Al taglio"], correctIndex: 0,
            explanation: "\"Canotto\" means dinghy/raft — a smaller base with a dramatically inflated crust ring."),
        HistoryQuestion(styleName: "Neapolitan Contemporary",
            question: "What helped spread the \"contemporary\" Neapolitan look globally through the 2010s–2020s?",
            choices: ["Government subsidies", "Social media (Instagram/TikTok)", "A UNESCO ruling", "Cookbook sales"], correctIndex: 1,
            explanation: "Pioneering pizzaiolos built global followings via Instagram and TikTok, spreading the style worldwide."),
    ]
}

/// A short, self-scoring multiple-choice quiz on real pizza-style history —
/// including a few questions that test whether a popular story is actually
/// disputed rather than settled.
struct StyleHistoryQuizView: View {
    @State private var order: [HistoryQuestion] = HistoryQuizBank.all.shuffled()
    @State private var index = 0
    @State private var selected: Int? = nil
    @State private var correctCount = 0

    private var question: HistoryQuestion? { order.indices.contains(index) ? order[index] : nil }
    private var finished: Bool { index >= order.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let q = question {
                    Text("Question \(index + 1) of \(order.count) · \(q.styleName)")
                        .font(.rounded(12, weight: .bold))
                        .foregroundStyle(Palette.textSoft)

                    Text(q.question)
                        .font(.rounded(20, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 10) {
                        ForEach(q.choices.indices, id: \.self) { i in
                            choiceButton(q, index: i)
                        }
                    }

                    if let selected {
                        VStack(alignment: .leading, spacing: 6) {
                            Label(selected == q.correctIndex ? "Correct" : "Not quite",
                                  systemImage: selected == q.correctIndex ? "checkmark.circle.fill" : "info.circle.fill")
                                .font(.rounded(14, weight: .bold))
                                .foregroundStyle(selected == q.correctIndex ? Palette.sage : Palette.amber)
                            Text(q.explanation)
                                .font(.rounded(13))
                                .foregroundStyle(Palette.textSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.well))

                        Button {
                            Haptics.tap()
                            self.selected = nil
                            index += 1
                        } label: {
                            Text(index == order.count - 1 ? "See my score" : "Next question")
                                .font(.rounded(16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.accent))
                        }
                        .buttonStyle(.plain)
                    }
                } else if finished {
                    scoreCard
                }
            }
            .padding(20)
        }
        .background(Palette.background.ignoresSafeArea())
        .navigationTitle("Pizza History Quiz")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func choiceButton(_ q: HistoryQuestion, index i: Int) -> some View {
        let isSelected = selected == i
        let isCorrect = i == q.correctIndex
        let showResult = selected != nil
        var tint: Color {
            guard showResult else { return Palette.text }
            if isCorrect { return Palette.sage }
            if isSelected { return Palette.danger }
            return Palette.textSoft
        }
        return Button {
            guard selected == nil else { return }
            selected = i
            if isCorrect { correctCount += 1; Haptics.success() } else { Haptics.tap() }
        } label: {
            HStack {
                Text(q.choices[i])
                    .font(.rounded(15, weight: .medium))
                Spacer()
                if showResult && (isCorrect || isSelected) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                }
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 16).padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.surface))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(tint.opacity(showResult ? 0.4 : 0.15), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(selected != nil)
    }

    private var scoreCard: some View {
        VStack(spacing: 14) {
            Text("🎉").font(.system(size: 48))
            Text("\(correctCount) of \(order.count) correct")
                .font(.rounded(24, weight: .bold))
                .foregroundStyle(Palette.text)
            Text(scoreLine)
                .font(.rounded(14))
                .foregroundStyle(Palette.textSoft)
                .multilineTextAlignment(.center)
            Button {
                Haptics.tap()
                order = HistoryQuizBank.all.shuffled()
                index = 0
                selected = nil
                correctCount = 0
            } label: {
                Text("Play again")
                    .font(.rounded(16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.accent))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var scoreLine: String {
        let ratio = Double(correctCount) / Double(max(order.count, 1))
        switch ratio {
        case 0.9...: return "Bona fide pizza historian."
        case 0.6..<0.9: return "Solid grasp of where your dough comes from."
        default: return "Some real surprises in pizza history, huh?"
        }
    }
}
