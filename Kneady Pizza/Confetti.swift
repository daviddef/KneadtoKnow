import SwiftUI

/// A light, celebratory shower of pizza emoji. Increment `trigger` to fire a
/// burst. A Vibrant-only flourish — call sites gate on `Palette.isVibrant`.
struct ConfettiBurst: View {
    let trigger: Int
    private let symbols = ["🍅", "🌿", "🧀", "🍕", "✨", "🫒"]

    var body: some View {
        ZStack {
            if trigger > 0 {
                ForEach(0..<26, id: \.self) { i in
                    ConfettiPiece(symbol: symbols[i % symbols.count], index: i)
                        // A fresh identity each burst so the animation replays.
                        .id("\(trigger)-\(i)")
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let symbol: String
    let index: Int
    @State private var on = false

    // Deterministic spread derived from the index — no randomness needed.
    private var dx: CGFloat { CGFloat((index * 73) % 320) - 160 }
    private var fall: CGFloat { 360 + CGFloat((index * 37) % 160) }
    private var delay: Double { Double(index % 6) * 0.035 }
    private var spin: Double { index.isMultiple(of: 2) ? 240 : -240 }
    private var size: CGFloat { 18 + CGFloat(index % 4) * 4 }

    var body: some View {
        Text(symbol)
            .font(.system(size: size))
            .opacity(on ? 0 : 1)
            .offset(x: on ? dx : 0, y: on ? fall : -30)
            .rotationEffect(.degrees(on ? spin : 0))
            .scaleEffect(on ? 0.6 : 1.15)
            .onAppear {
                withAnimation(.easeOut(duration: 1.4).delay(delay)) { on = true }
            }
    }
}
