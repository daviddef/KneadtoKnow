import SwiftUI

/// A silly, kid-friendly pizza question — emoji answers, no wrong-answer shame.
struct KidTriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let choices: [String]
    let correctIndex: Int
}

enum KidTriviaBank {
    static let all: [KidTriviaQuestion] = [
        KidTriviaQuestion(question: "What makes pizza dough go puffy and full of bubbles?",
                           choices: ["🫧 Yeast", "🧂 Salt", "🧊 Ice", "🪨 Rocks"], correctIndex: 0),
        KidTriviaQuestion(question: "What makes a pizza crust go bubbly and a little crispy-black?",
                           choices: ["❄️ A freezer", "🔥 A super-hot oven", "💧 Steam only", "🌬️ A fan"], correctIndex: 1),
        KidTriviaQuestion(question: "What Italian city is famous for inventing pizza?",
                           choices: ["🗼 Paris", "🗽 New York", "🇮🇹 Naples", "🏯 Tokyo"], correctIndex: 2),
        KidTriviaQuestion(question: "A Margherita pizza's colors are supposed to match what?",
                           choices: ["🌈 A rainbow", "🇮🇹 The Italian flag", "⚫️ Black and white", "🟦 Blue and yellow"], correctIndex: 1),
        KidTriviaQuestion(question: "In Detroit, pizza is baked in a special-shaped pan. What shape?",
                           choices: ["⭐ Star", "⭕ Circle", "⬛ Square", "🔺 Triangle"], correctIndex: 2),
        KidTriviaQuestion(question: "What thick, spongy pizza-cousin from Sicily is eaten at Christmas?",
                           choices: ["🎄 Sfincione", "🍩 Donut pizza", "🥯 Bagel pizza", "🧇 Waffle pizza"], correctIndex: 0),
    ]
}

/// A short, silly quiz — one question at a time, big emoji answers, instant
/// happy feedback either way. Finishing a round earns the Quiz Whiz sticker.
struct KidTriviaView: View {
    var onFinish: () -> Void = {}
    @State private var order: [KidTriviaQuestion] = KidTriviaBank.all.shuffled()
    @State private var index = 0
    @State private var selected: Int? = nil
    @State private var burst = false

    private var question: KidTriviaQuestion? { order.indices.contains(index) ? order[index] : nil }
    private var finished: Bool { index >= order.count }

    var body: some View {
        ZStack {
            Kid.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    if let q = question {
                        Text("Question \(index + 1) of \(order.count)")
                            .font(.rounded(14, weight: .bold))
                            .foregroundStyle(Kid.inkSoft)
                        Text(q.question)
                            .font(.rounded(24, weight: .bold))
                            .foregroundStyle(Kid.tomatoDk)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: 10) {
                            ForEach(q.choices.indices, id: \.self) { i in
                                choiceButton(q, index: i)
                            }
                        }

                        if selected != nil {
                            Button {
                                Haptics.tap()
                                selected = nil
                                index += 1
                            } label: {
                                Text(index == order.count - 1 ? "See how I did! 🎉" : "Next question ➡️")
                                    .font(.rounded(18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Kid.tomato))
                            }
                            .buttonStyle(.plain)
                        }
                    } else if finished {
                        finishedCard
                    }
                }
                .padding(20)
            }
            if burst { ConfettiView(looping: true).ignoresSafeArea() }
        }
        .tint(Kid.tomato)
        .onAppear {
            if finished { KidStickerStore.award("quiz") }
        }
    }

    private func choiceButton(_ q: KidTriviaQuestion, index i: Int) -> some View {
        let isSelected = selected == i
        let isCorrect = i == q.correctIndex
        let showResult = selected != nil
        var bg: Color {
            guard showResult else { return .white }
            if isCorrect { return Kid.leaf }
            if isSelected { return Color(red: 1.0, green: 0.85, blue: 0.83) }
            return .white
        }
        return Button {
            guard selected == nil else { return }
            selected = i
            if isCorrect { Haptics.success() } else { Haptics.tap() }
        } label: {
            Text(q.choices[i])
                .font(.rounded(18, weight: .bold))
                .foregroundStyle(Kid.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(bg))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Kid.inkSoft.opacity(0.2), lineWidth: 2))
        }
        .buttonStyle(.plain)
        .disabled(selected != nil)
    }

    private var finishedCard: some View {
        VStack(spacing: 16) {
            Text("🧠🎉").font(.system(size: 56))
            Text("You did it!").font(.rounded(28, weight: .bold)).foregroundStyle(Kid.tomatoDk)
            Text("+1 sticker: Quiz Whiz").font(.rounded(16, weight: .bold)).foregroundStyle(Kid.inkSoft)
            Button {
                Haptics.tap()
                onFinish()
            } label: {
                Text("Done").font(.rounded(18, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Kid.green))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 40)
        .onAppear {
            KidStickerStore.award("quiz")
            burst = true
        }
    }
}
