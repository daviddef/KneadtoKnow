import SwiftUI

/// Choose how many of each traditional pizza to make (capped at the ball
/// count), and get a scaled shopping list for dough + toppings.
struct RecipePlannerView: View {
    @ObservedObject var vm: DoughViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newExtra = ""

    private var recipes: [PizzaRecipe] { vm.availableRecipes(for: vm.input.style.id) }
    private var savoury: [PizzaRecipe] { recipes.filter { $0.category == .savoury } }
    private var sweet: [PizzaRecipe] { recipes.filter { $0.category == .dessert } }
    private var total: Int { max(vm.input.ballCount, 1) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                frozenHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        group("Savoury", savoury)
                        group("Sweet", sweet)
                        extrasCard
                        if vm.selectedPizzaTotal > 0 || !vm.extras.isEmpty { shoppingCard }
                    }
                    .padding(20)
                }
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationTitle("Pizza & shopping")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    ShareMenuButton(shareText: vm.shareText())
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.rounded(16, weight: .semibold))
                        .tint(Palette.accent)
                }
            }
        }
        .tint(Palette.accent)
    }

    // MARK: Frozen header

    private var frozenHeader: some View {
        VStack(spacing: 2) {
            Text("\(vm.selectedPizzaTotal) of \(total) chosen")
                .font(.rounded(22, weight: .bold))
                .foregroundStyle(vm.selectedPizzaTotal == total ? Palette.sage : Palette.text)
                .contentTransition(.numericText())
            Text("Traditional \(vm.input.style.name) pizzas")
                .font(.rounded(11))
                .foregroundStyle(Palette.textSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Palette.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Palette.shadowDark.opacity(0.4)).frame(height: 0.5)
        }
    }

    @ViewBuilder
    private func group(_ title: String, _ list: [PizzaRecipe]) -> some View {
        if !list.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.rounded(12, weight: .bold))
                    .foregroundStyle(Palette.textSoft)
                ForEach(list) { recipeRow($0) }
            }
        }
    }

    private func recipeRow(_ recipe: PizzaRecipe) -> some View {
        let count = vm.pizzaSelection[recipe.id] ?? 0
        let showHidePineapple = vm.hasFavourite && RecipeCatalog.isPineapple(recipe)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.name)
                        .font(.rounded(16, weight: .semibold))
                        .foregroundStyle(Palette.text)
                    Text(recipe.assembly)
                        .font(.rounded(11))
                        .foregroundStyle(Palette.textSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 10)
                HStack(spacing: 12) {
                    circle("minus") { vm.setRecipeCount(recipe.id, count - 1) }
                    Text("\(count)")
                        .font(.rounded(18, weight: .semibold))
                        .foregroundStyle(count > 0 ? Palette.accent : Palette.textSoft)
                        .frame(minWidth: 22)
                        .contentTransition(.numericText())
                    circle("plus") { vm.setRecipeCount(recipe.id, count + 1) }
                }
            }
            if showHidePineapple {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        vm.neverShowPineapple()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "nosign")
                        Text("Never show me pineapple again")
                    }
                    .font(.rounded(12, weight: .semibold))
                    .foregroundStyle(Palette.textSoft)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(cornerRadius: 18)
    }

    private func circle(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.rounded(14, weight: .bold))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(TactileButtonStyle(cornerRadius: 18))
    }

    // MARK: Extras

    private var extrasCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXTRAS")
                .font(.rounded(12, weight: .bold))
                .foregroundStyle(Palette.textSoft)
            Text("Extra toppings to buy — tick the usual ones or add your own. Added ones are saved for next time.")
                .font(.rounded(11))
                .foregroundStyle(Palette.textSoft)
                .fixedSize(horizontal: false, vertical: true)

            let presets = RecipeCatalog.commonExtras.filter { !vm.favouriteExtras.contains($0) }
            ForEach(presets, id: \.self) { name in
                Button { vm.toggleExtra(name) } label: {
                    HStack(spacing: 8) {
                        Image(systemName: vm.extras.contains(name) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(vm.extras.contains(name) ? Palette.accent : Palette.textSoft)
                        Text(name)
                            .font(.rounded(15))
                            .foregroundStyle(Palette.text)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }

            if !vm.favouriteExtras.isEmpty {
                Divider().overlay(Palette.textSoft.opacity(0.15))
            }

            ForEach(vm.favouriteExtras, id: \.self) { name in
                HStack {
                    Button { vm.toggleExtra(name) } label: {
                        HStack(spacing: 8) {
                            Image(systemName: vm.extras.contains(name) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(vm.extras.contains(name) ? Palette.accent : Palette.textSoft)
                            Text(name)
                                .font(.rounded(15))
                                .foregroundStyle(Palette.text)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button { vm.removeFavouriteExtra(name) } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Palette.textSoft)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 8) {
                TextField("Add an ingredient", text: $newExtra)
                    .font(.rounded(15))
                    .submitLabel(.done)
                    .onSubmit { vm.addExtra(newExtra); newExtra = "" }
                Button { vm.addExtra(newExtra); newExtra = "" } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.rounded(20, weight: .medium))
                        .foregroundStyle(Palette.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .softWell(cornerRadius: 14)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(cornerRadius: 18)
    }

    // MARK: Shopping list

    private var shoppingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Shopping list")
                .font(.rounded(18, weight: .bold))
                .foregroundStyle(Palette.accent)

            listSection("Dough", lines: vm.doughLines(), ordered: false)
            let toppings = vm.toppingLines()
            if !toppings.isEmpty {
                Divider().overlay(Palette.textSoft.opacity(0.2))
                listSection("Toppings", lines: toppings, ordered: true)
            }
            if !vm.extras.isEmpty {
                Divider().overlay(Palette.textSoft.opacity(0.2))
                VStack(alignment: .leading, spacing: 0) {
                    Text("EXTRAS")
                        .font(.rounded(11, weight: .bold))
                        .foregroundStyle(Palette.textSoft)
                    ForEach(Array(vm.selectedExtras.enumerated()), id: \.element) { idx, name in
                        if idx > 0 { Divider().overlay(Palette.textSoft.opacity(0.1)) }
                        Text(name)
                            .font(.rounded(15, weight: .medium))
                            .foregroundStyle(Palette.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 9)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(cornerRadius: 24)
    }

    private func listSection(_ title: String, lines: [ShoppingLine], ordered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.rounded(11, weight: .bold))
                .foregroundStyle(Palette.textSoft)
            if ordered {
                HStack(spacing: 5) {
                    Image(systemName: "square.3.layers.3d.top.filled")
                    Text("In the order they go on the pizza")
                }
                .font(.rounded(10))
                .foregroundStyle(Palette.textSoft)
                .padding(.top, 2)
            }
            ForEach(Array(lines.enumerated()), id: \.element.id) { idx, line in
                if idx > 0 { Divider().overlay(Palette.textSoft.opacity(0.1)) }
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(line.name)
                            .font(.rounded(15, weight: .medium))
                            .foregroundStyle(Palette.text)
                        if let hint = line.hint {
                            Text(hint).font(.rounded(11)).foregroundStyle(Palette.textSoft)
                        }
                    }
                    Spacer()
                    Text(Units.weight(line.grams, metric: vm.metric))
                        .font(.rounded(15, weight: .semibold))
                        .foregroundStyle(Palette.text)
                }
                .padding(.vertical, 9)
            }
        }
        .padding(.top, 4)
    }
}
