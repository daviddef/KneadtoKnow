import SwiftUI

// MARK: - Confetti

struct ConfettiView: View {
    var looping = false
    private let pieces = 30
    private let cols: [Color] = [Kid.tomato, Kid.green, Kid.sunny, Kid.grape, Kid.sky]
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieces, id: \.self) { i in
                    let x = Double((i * 73) % 100) / 100.0
                    let size = CGFloat(6 + (i % 4) * 3)
                    let delay = Double(i % 10) * 0.07
                    let rot = Double((i * 47) % 360)
                    Rectangle()
                        .fill(cols[i % cols.count])
                        .frame(width: size, height: size * 1.4)
                        .rotationEffect(.degrees(rot))
                        .position(x: x * geo.size.width, y: animate ? geo.size.height + 40 : -40)
                        .opacity(animate ? 1 : 0)
                        .animation(baseAnim.delay(delay), value: animate)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }

    private var baseAnim: Animation {
        looping ? .easeIn(duration: 1.7).repeatForever(autoreverses: false)
                : .easeIn(duration: 1.7)
    }
}

// MARK: - Coordinator

struct KidModeView: View {
    @ObservedObject var vm: DoughViewModel

    private enum Phase { case pick, build, dough, cook, celebrate }
    @State private var phase: Phase = .pick
    @State private var pizza: KidPizza?
    @State private var dough: KidDough = .rightNow
    @State private var steps: [KidStep] = []
    @State private var stepPage = 0
    @State private var burst = false
    @State private var videosMuted = false   // one mute switch for every clip (sound on by default)

    // Make-your-own selections
    @State private var bSauce = true
    @State private var bCheese = true
    @State private var bExtras: Set<String> = ["Ham", "Peppers"]

    var body: some View {
        ZStack {
            Kid.cream.ignoresSafeArea()
            content
            if burst { ConfettiView().ignoresSafeArea() }
        }
        .tint(Kid.tomato)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true; KidAudio.activate() }
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .pick:      pickView
        case .build:     buildView
        case .dough:     doughView
        case .cook:      cookView
        case .celebrate: celebrateView
        }
    }

    // MARK: Shared bits

    private var exitButton: some View {
        Button {
            Haptics.tap()
            vm.kidMode = false
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                Text("Grown-ups")
            }
            .font(.rounded(15, weight: .bold))
            .foregroundStyle(Kid.inkSoft)
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(Capsule().fill(.white))
            .overlay(Capsule().stroke(Kid.inkSoft.opacity(0.25), lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func bigButton(_ title: String, color: Color = Kid.green, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.rounded(22, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(color))
        }
        .buttonStyle(.plain)
    }

    private func popConfetti() {
        burst = true
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            burst = false
        }
    }

    // MARK: Pick

    private var pickView: some View {
        let saved = KidPizzaStore.load()
        return ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("🍕 Pizza Party").font(.rounded(14, weight: .bold)).foregroundStyle(Kid.inkSoft)
                    Spacer()
                    exitButton
                }
                Group {
                    if VideoLoopView.exists("kid-hero-toss") {
                        KidVideo(resource: "kid-hero-toss", muted: $videosMuted)
                            .frame(height: 130).frame(maxWidth: .infinity)
                    } else {
                        Image("kid-hero-toss").resizable().scaledToFill()
                            .frame(height: 130).frame(maxWidth: .infinity).clipped()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text("Pick your pizza!")
                    .font(.rounded(30, weight: .bold)).foregroundStyle(Kid.tomatoDk)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(KidLibrary.presets) { p in
                        tile(p.emoji, p.name, blurb: p.blurb, art: p.art, bg: Kid.sunnySoft) { choose(p) }
                    }
                    Button { Haptics.tap(); resetBuilder(); withAnimation { phase = .build } } label: {
                        VStack(spacing: 4) {
                            Text("➕").font(.system(size: 30))
                            Text("Make your own!").font(.rounded(13, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Kid.tomato, style: StrokeStyle(lineWidth: 2, dash: [6])))
                    }
                    .buttonStyle(.plain)
                }

                if !saved.isEmpty {
                    Text("⭐ My Pizzas").font(.rounded(16, weight: .bold)).foregroundStyle(Kid.ink).padding(.top, 6)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(saved) { p in
                            tile(p.emoji, p.name, blurb: p.blurb, art: p.art, bg: Kid.grapeSoft) { choose(p) }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private func tile(_ emoji: String, _ name: String, blurb: String? = nil, art: String? = nil, bg: Color, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.tap(); action() }) {
            VStack(spacing: 0) {
                if let art {
                    Image(art).resizable().scaledToFill()
                        .frame(height: 84).frame(maxWidth: .infinity).clipped()
                } else {
                    Text(emoji).font(.system(size: 28)).frame(height: 58)
                }
                VStack(spacing: 3) {
                    Text(name).font(.rounded(14, weight: .bold)).foregroundStyle(Kid.ink)
                        .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.8)
                    if let b = blurb, !b.isEmpty {
                        Text(b).font(.rounded(11, weight: .medium)).foregroundStyle(Kid.inkSoft)
                            .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 10).padding(.horizontal, 6)
            }
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(bg))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func choose(_ p: KidPizza) {
        pizza = p
        withAnimation { phase = .dough }
    }

    // MARK: Build

    private func resetBuilder() {
        bSauce = true; bCheese = true; bExtras = ["Ham", "Peppers"]
    }

    private var buildView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button { Haptics.tap(); withAnimation { phase = .pick } } label: {
                        Image(systemName: "chevron.left").font(.rounded(20, weight: .bold)).foregroundStyle(Kid.inkSoft).frame(width: 46, height: 46).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Spacer()
                    exitButton
                }
                Text("Build your pizza!").font(.rounded(28, weight: .bold)).foregroundStyle(Kid.tomatoDk)

                toggleRow("🍅 Tomato sauce?", "Grown-up tip: passata or a thin pizza sauce", isOn: $bSauce)
                toggleRow("🧀 Cheese?", "Grown-up tip: low-moisture mozzarella, grated", isOn: $bCheese)
                grabRow("🍗🫛 Grab some protein", "meat or veggie!", "pre-cooked meat, or tofu, beans or halloumi", KidLibrary.proteins)
                grabRow("🥦 Grab some veg", nil, "chop small & thin so it cooks", KidLibrary.veg)
                grabRow("🍍 Grab something sweet", nil, "pat pineapple dry first", KidLibrary.sweet)

                bigButton("⭐ Save my pizza", color: Kid.tomato) { saveCustom() }
            }
            .padding(18)
        }
    }

    private func toggleRow(_ title: String, _ tip: String, isOn: Binding<Bool>) -> some View {
        Button { Haptics.tap(); isOn.wrappedValue.toggle() } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.rounded(15, weight: .bold)).foregroundStyle(Kid.ink)
                    Text(tip).font(.rounded(11)).foregroundStyle(Kid.inkSoft)
                }
                Spacer()
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.rounded(22, weight: .bold))
                    .foregroundStyle(isOn.wrappedValue ? Kid.green : Kid.inkSoft.opacity(0.4))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 15).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Kid.sunnySoft, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func grabRow(_ title: String, _ sub: String?, _ tip: String, _ options: [KidTopping]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(title).font(.rounded(15, weight: .bold)).foregroundStyle(Kid.ink)
                if let sub { Text("— \(sub)").font(.rounded(12)).foregroundStyle(Kid.leafDk) }
            }
            Text("Grown-up tip: \(tip)").font(.rounded(11)).foregroundStyle(Kid.inkSoft)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(options) { t in
                    let on = bExtras.contains(t.name)
                    Button {
                        Haptics.tap()
                        if on { bExtras.remove(t.name) } else { bExtras.insert(t.name) }
                    } label: {
                        Text("\(t.emoji) \(t.name)")
                            .font(.rounded(12, weight: .bold))
                            .foregroundStyle(on ? (t.veggie ? Kid.leafDk : Kid.ink) : Kid.inkSoft)
                            .padding(.horizontal, 10).padding(.vertical, 7)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(on ? (t.veggie ? Kid.leaf : Kid.sunny) : .white))
                            .overlay(Capsule().stroke(Kid.inkSoft.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 15).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Kid.sunnySoft, lineWidth: 2))
    }

    private func saveCustom() {
        let all = KidLibrary.proteins + KidLibrary.veg + KidLibrary.sweet
        let extras = all.filter { bExtras.contains($0.name) }
        let p = KidRecipe.custom(sauce: bSauce, cheese: bCheese, extras: extras)
        KidPizzaStore.add(p)
        Haptics.success()
        pizza = p
        withAnimation { phase = .dough }
    }

    // MARK: Dough

    private var doughView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button { Haptics.tap(); withAnimation { phase = .pick } } label: {
                        Image(systemName: "chevron.left").font(.rounded(20, weight: .bold)).foregroundStyle(Kid.inkSoft).frame(width: 46, height: 46).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Spacer()
                    exitButton
                }

                Group {
                    if VideoLoopView.exists("kid-choose") {
                        KidVideo(resource: "kid-choose", muted: $videosMuted)
                            .frame(height: 170).frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .id("kid-choose")
                    } else if let p = pizza, let art = p.art {
                        Image(art).resizable().scaledToFill()
                            .frame(height: 170).frame(maxWidth: .infinity).clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }

                Text("How quickly do you need it?")
                    .font(.rounded(26, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                    .fixedSize(horizontal: false, vertical: true)

                doughCard(.rightNow, bg: Kid.sunnySoft, ink: Color(red: 0.48, green: 0.31, blue: 0), pill: Kid.tomato, featured: true)
                doughCard(.puffy, bg: Kid.grapeSoft, ink: Color(red: 0.29, green: 0.18, blue: 0.51), pill: Kid.grape, featured: false)

                Text("pick one — you can always try the other next time!")
                    .font(.rounded(12, weight: .medium)).foregroundStyle(Kid.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .center)

                if let p = pizza {
                    VStack(spacing: 0) {
                        if let art = p.art {
                            Image(art).resizable().scaledToFill()
                                .frame(height: 88).frame(maxWidth: .infinity).clipped()
                        } else {
                            Text(p.emoji).font(.system(size: 40)).frame(height: 76).frame(maxWidth: .infinity)
                        }
                        HStack(spacing: 6) {
                            Text("Your pizza:").font(.rounded(13, weight: .medium)).foregroundStyle(Kid.inkSoft)
                            Text(p.name).font(.rounded(16, weight: .bold)).foregroundStyle(Kid.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                    }
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Kid.sunnySoft))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.top, 4)
                }
            }
            .padding(18)
        }
    }

    private func doughCard(_ d: KidDough, bg: Color, ink: Color, pill: Color, featured: Bool) -> some View {
        Button { Haptics.tap(); startCooking(d) } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Text("\(d.emoji) \(d.title)").font(.rounded(25, weight: .bold)).foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 4)
                    Text("⏱️ \(d.time)").font(.rounded(15, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(pill))
                }
                Text(d.blurb).font(.rounded(15)).foregroundStyle(ink.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                Text(d.flow).font(.rounded(18, weight: .bold)).foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 20).fill(bg))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(featured ? Kid.tomato : .clear, lineWidth: 3))
        }
        .buttonStyle(.plain)
    }

    private func startCooking(_ d: KidDough) {
        guard let pizza else { return }
        dough = d
        steps = KidRecipe.steps(for: pizza, dough: d, metric: vm.metric)
        stepPage = 0
        withAnimation { phase = .cook }
    }

    // MARK: Cook

    private var cookView: some View {
        VStack(spacing: 10) {
            HStack {
                Button { Haptics.tap(); withAnimation { phase = .dough } } label: {
                    Image(systemName: "chevron.left").font(.rounded(20, weight: .bold)).foregroundStyle(Kid.inkSoft).frame(width: 46, height: 46).contentShape(Rectangle())
                }.buttonStyle(.plain)
                Spacer()
                Text("Step \(stepPage + 1) of \(steps.count)")
                    .font(.rounded(15, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                Spacer()
                exitButton
            }
            .padding(.horizontal, 18).padding(.top, 14)

            TabView(selection: $stepPage) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    stepPageView(step, idx: idx).tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(steps.indices, id: \.self) { i in
                    Circle().fill(i == stepPage ? Kid.tomato : Kid.inkSoft.opacity(0.25))
                        .frame(width: i == stepPage ? 9 : 7, height: i == stepPage ? 9 : 7)
                }
            }
            .padding(.bottom, 14)
        }
    }

    private func stepPageView(_ step: KidStep, idx: Int) -> some View {
        let isLast = idx == steps.count - 1
        return VStack(spacing: 12) {
            // Pinned: the media and the "I did it!" button stay put while the
            // details below scroll.
            stepMedia(step, idx: idx)
            Text(step.title).font(.rounded(28, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            bigButton(isLast ? "It's ready! 🎉" : "I did it! ✓") {
                Haptics.success(); popConfetti()
                if isLast { withAnimation { phase = .celebrate } }
                else { withAnimation { stepPage += 1 } }
            }
            ScrollView(showsIndicators: false) {
                stepDetails(step).padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 18).padding(.top, 4)
    }

    @ViewBuilder private func stepMedia(_ step: KidStep, idx: Int) -> some View {
        if let video = step.video, VideoLoopView.exists(video) {
            KidVideo(resource: video, muted: $videosMuted, isActive: idx == stepPage)
                .frame(height: 150).frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .id("step-\(idx)-\(video)")
                .padding(.top, 4)
        } else if let art = step.art {
            Image(art).resizable().scaledToFill()
                .frame(height: 150).frame(maxWidth: .infinity).clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.top, 4)
        } else {
            Text(step.emoji).font(.system(size: 64)).frame(height: 120)
        }
    }

    private func stepDetails(_ step: KidStep) -> some View {
        VStack(spacing: 12) {
            Text(step.detail).font(.rounded(18, weight: .medium)).foregroundStyle(Kid.ink)
                .multilineTextAlignment(.center).lineSpacing(3).fixedSize(horizontal: false, vertical: true)

            if !step.ingredients.isEmpty {
                let darkAmber = Color(red: 0.48, green: 0.31, blue: 0)
                let darkRed = Color(red: 0.64, green: 0.18, blue: 0.10)
                VStack(spacing: 8) {
                    ForEach(step.ingredients) { ing in
                        HStack(spacing: 12) {
                            Text(ing.emoji).font(.system(size: 28))
                            (Text("\(ing.name) — ").font(.rounded(18, weight: .medium)).foregroundColor(Kid.ink)
                             + Text(ing.kid).font(.rounded(19, weight: .bold)).foregroundColor(darkAmber)
                             + Text("  [\(ing.precise(vm.metric))]").font(.rounded(15, weight: .medium)).foregroundColor(Kid.inkSoft))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 11).padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Kid.sunnySoft))

                        if let alt = ing.alt {
                            HStack(spacing: 12) {
                                Text(alt.emoji).font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 2) {
                                    (Text("\(alt.title) — ").font(.rounded(18, weight: .medium)).foregroundColor(darkRed)
                                     + Text(alt.kid).font(.rounded(19, weight: .bold)).foregroundColor(darkRed)
                                     + Text("  [\(alt.precise(vm.metric))]").font(.rounded(15, weight: .medium)).foregroundColor(darkRed.opacity(0.7)))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(alt.sub)
                                        .font(.rounded(12, weight: .semibold))
                                        .foregroundColor(darkRed.opacity(0.9))
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.vertical, 11).padding(.horizontal, 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 1.0, green: 0.91, blue: 0.90)))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Kid.tomato.opacity(0.55), lineWidth: 2))
                        }
                    }
                }
            }

            ForEach(step.chips, id: \.self) { c in
                Text(c).font(.rounded(14, weight: .bold)).foregroundStyle(Color(red: 0.48, green: 0.31, blue: 0))
                    .padding(.horizontal, 13).padding(.vertical, 7)
                    .background(Capsule().fill(Kid.sunny))
            }

            if let b = step.banner {
                VStack(spacing: 4) {
                    Text(b.icon).font(.system(size: 48))
                    Text(b.value).font(.rounded(22, weight: .bold))
                        .foregroundStyle(b.warm ? Kid.tomatoDk : Color(red: 0.29, green: 0.18, blue: 0.51))
                    Text(b.sub).font(.rounded(13, weight: .medium)).foregroundStyle(Kid.inkSoft)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 18)
                    .fill(b.warm ? Color(red: 1.0, green: 0.89, blue: 0.86) : Kid.grapeSoft))
            }

            if let joke = step.joke {
                Text("😄 \(joke)").font(.rounded(13, weight: .medium)).foregroundStyle(Color(red: 0.13, green: 0.27, blue: 0.45))
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    .padding(11).frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Kid.sky, lineWidth: 2))
            }

            if let tip = step.tip {
                Text("⭐ \(tip)").font(.rounded(12, weight: .bold)).foregroundStyle(Color(red: 0.48, green: 0.31, blue: 0))
            }

            if step.grownUp {
                Text("🔥 Ovens are HOT — grab a grown-up!")
                    .font(.rounded(14, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                    .multilineTextAlignment(.center)
                    .padding(11).frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(red: 1.0, green: 0.89, blue: 0.86)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Kid.tomato.opacity(0.5), lineWidth: 2))
            }
        }
    }

    // MARK: Celebrate

    private var celebrateView: some View {
        ZStack {
            ConfettiView(looping: true).ignoresSafeArea()
            VStack(spacing: 14) {
                Image("kid-chef-point")
                    .resizable().scaledToFill()
                    .frame(height: 150).frame(maxWidth: .infinity).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                Text("YOU MADE PIZZA!").font(.rounded(30, weight: .bold)).foregroundStyle(Kid.tomatoDk)
                    .multilineTextAlignment(.center)
                Text("You're a real pizza chef now.").font(.rounded(16, weight: .medium)).foregroundStyle(Kid.ink)
                HStack(spacing: 10) {
                    ForEach(["⭐", "🍕", "👩‍🍳", "🏅"], id: \.self) { s in
                        Text(s).font(.system(size: 24))
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(.white))
                            .overlay(Circle().stroke(Kid.sunny, lineWidth: 2))
                    }
                }
                Text("+1 sticker for your collection!").font(.rounded(13, weight: .bold)).foregroundStyle(Kid.inkSoft)

                bigButton("Make another! 🔁", color: Kid.tomato) {
                    Haptics.tap()
                    pizza = nil
                    withAnimation { phase = .pick }
                }
                .padding(.horizontal, 20).padding(.top, 6)
            }
            .padding(24)
        }
    }
}
