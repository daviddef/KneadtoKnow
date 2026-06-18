import SwiftUI
import UIKit

/// The merged "what you'll make & buy" card: total dough, the staged recipe,
/// and the topping shopping list with planner + share actions.
struct ResultView: View {
    let result: DoughResult
    var metric: Bool = true
    var toppingLines: [ShoppingLine] = []
    /// Show a "N pizzas" badge per topping (only useful with >1 pizza selected).
    var showPizzaCounts: Bool = false
    var extras: [String] = []
    var hasSelection: Bool = false
    var shareText: String = ""
    var onPlan: () -> Void = {}

    private func grams(_ g: Double) -> String { Units.weight(g, metric: metric) }
    private var guidance: WeightGuidance {
        DoughCalculator.guidance(forBall: result.ballWeight, shape: result.shape)
    }

    var body: some View {
        VStack(spacing: 16) {
            headline

            ForEach(Array(result.stages.enumerated()), id: \.element.id) { _, stage in
                stageBlock(stage, showTitle: result.stages.count > 1)
            }

            Divider().overlay(Palette.textSoft.opacity(0.2))

            toppingsBlock
        }
        .padding(20)
        .softCard(cornerRadius: 28)
    }

    // MARK: Headline

    private var headline: some View {
        VStack(spacing: 3) {
            Text(grams(result.totalWeight))
                .font(.rounded(34, weight: .bold))
                .foregroundStyle(Palette.accent)
                .contentTransition(.numericText())
            Text("Total dough · \(result.ballCount) × \(grams(result.ballWeight)) \(result.shape.nounPlural)")
                .font(.rounded(12, weight: .medium))
                .foregroundStyle(guidance.color)
                .multilineTextAlignment(.center)
            Text(guidance.message)
                .font(.rounded(11))
                .foregroundStyle(Palette.textSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Toppings

    private var toppingsBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Toppings")
                    .font(.rounded(15, weight: .bold))
                    .foregroundStyle(Palette.accent)
                Spacer()
                Button { onPlan() } label: {
                    Image(systemName: "basket.fill").font(.rounded(16, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Palette.accent)
                ShareMenuButton(shareText: shareText)
            }

            if hasSelection {
                HStack(spacing: 5) {
                    Image(systemName: "square.3.layers.3d.top.filled")
                    Text("In the order they go on.")
                }
                .font(.rounded(10))
                .foregroundStyle(Palette.textSoft)

                ForEach(Array(toppingLines.enumerated()), id: \.element.id) { idx, line in
                    if idx > 0 { Divider().overlay(Palette.textSoft.opacity(0.08)) }
                    HStack(spacing: 6) {
                        Text(line.name)
                            .font(.rounded(13, weight: .medium))
                            .foregroundStyle(Palette.text)
                        if showPizzaCounts && line.pizzaCount > 0 {
                            Text("\(line.pizzaCount) pizza\(line.pizzaCount == 1 ? "" : "s")")
                                .font(.rounded(10, weight: .bold))
                                .foregroundStyle(Palette.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Palette.accent.opacity(0.14)))
                        }
                        Spacer(minLength: 6)
                        Text(grams(line.grams))
                            .font(.rounded(13, weight: .semibold))
                            .foregroundStyle(Palette.text)
                    }
                    .padding(.vertical, 4)
                }
                extrasList
            } else if !extras.isEmpty {
                extrasList
            } else {
                Text("Pick which pizzas you're making to add topping ingredients to your shopping list.")
                    .font(.rounded(12))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
                Button { onPlan() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "basket.fill")
                        Text("Open the Pizza & topping planner")
                    }
                    .font(.rounded(15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                }
                .buttonStyle(TactileButtonStyle(isProminent: true))
            }
        }
    }

    @ViewBuilder
    private var extrasList: some View {
        if !extras.isEmpty {
            Divider().overlay(Palette.textSoft.opacity(0.12)).padding(.vertical, 4)
            Text("EXTRAS")
                .font(.rounded(11, weight: .bold))
                .foregroundStyle(Palette.textSoft)
            ForEach(extras, id: \.self) { name in
                Text(name)
                    .font(.rounded(15, weight: .medium))
                    .foregroundStyle(Palette.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
            }
        }
    }

    // MARK: Recipe stage

    @ViewBuilder
    private func stageBlock(_ stage: RecipeStage, showTitle: Bool) -> some View {
        VStack(spacing: 0) {
            if showTitle {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(stage.title)
                        .font(.rounded(16, weight: .bold))
                        .foregroundStyle(Palette.accent)
                    if let note = stage.note {
                        Text(note)
                            .font(.rounded(11))
                            .foregroundStyle(Palette.textSoft)
                    }
                    Spacer()
                }
                .padding(.top, 6)
                .padding(.bottom, 2)
            }

            ForEach(Array(stage.ingredients.enumerated()), id: \.element.id) { idx, item in
                if idx > 0 {
                    Divider().overlay(Palette.textSoft.opacity(0.12))
                }
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(item.name)
                        .font(.rounded(14, weight: .medium))
                        .foregroundStyle(Palette.text)
                    if let note = item.note {
                        Text(note)
                            .font(.rounded(11))
                            .foregroundStyle(Palette.textSoft)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    Spacer(minLength: 6)
                    Text(grams(item.grams))
                        .font(.rounded(15, weight: .semibold))
                        .foregroundStyle(Palette.text)
                        .contentTransition(.numericText())
                }
                .padding(.vertical, 6)
            }
        }
    }
}

/// A share control offering Messages, Email and the system share sheet.
/// Reused in the result card and the app header.
struct ShareMenuButton: View {
    let shareText: String
    var iconSize: CGFloat = 16
    @Environment(\.openURL) private var openURL

    private var encodedSubject: String {
        "Kneady Pizza shopping list".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    private var encodedBody: String {
        shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    private var smsURL: URL? { URL(string: "sms:&body=\(encodedBody)") }
    private var mailURL: URL? {
        URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)")
    }
    private var gmailURL: URL? {
        URL(string: "googlegmail://co?subject=\(encodedSubject)&body=\(encodedBody)")
    }

    /// Open the Gmail app if it's installed; otherwise fall back to the default
    /// mail app so the button always does something useful.
    private func openGmail() {
        guard let gmailURL else { return }
        UIApplication.shared.open(gmailURL, options: [:]) { ok in
            if !ok, let mailURL { openURL(mailURL) }
        }
    }

    var body: some View {
        Menu {
            if let mailURL {
                Button { openURL(mailURL) } label: { Label("Email (default app)", systemImage: "envelope.fill") }
            }
            Button { openGmail() } label: { Label("Gmail", systemImage: "envelope.badge.fill") }
            if let smsURL {
                Button { openURL(smsURL) } label: { Label("Messages", systemImage: "message.fill") }
            }
            ShareLink(item: shareText) {
                Label("More options & people…", systemImage: "person.2.fill")
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.rounded(iconSize, weight: .medium))
                .foregroundStyle(Palette.accent)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
    }
}
