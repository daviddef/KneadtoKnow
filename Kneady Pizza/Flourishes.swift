import SwiftUI

/// A subtle red-gingham tablecloth, drawn as overlapping translucent bands so
/// the intersections read a touch darker — the classic pizzeria cue. A
/// Vibrant-only flourish; call sites gate on `Palette.isVibrant`.
struct GinghamBackground: View {
    var tile: CGFloat = 26
    var color: Color = Palette.accent

    var body: some View {
        Canvas { ctx, size in
            let cols = Int(size.width / tile) + 1
            let rows = Int(size.height / tile) + 1
            for c in 0..<cols where c.isMultiple(of: 2) {
                let rect = CGRect(x: CGFloat(c) * tile, y: 0, width: tile, height: size.height)
                ctx.fill(Path(rect), with: .color(color.opacity(0.10)))
            }
            for r in 0..<rows where r.isMultiple(of: 2) {
                let rect = CGRect(x: 0, y: CGFloat(r) * tile, width: size.width, height: tile)
                ctx.fill(Path(rect), with: .color(color.opacity(0.10)))
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// A continuously spinning 🍕, used in place of the system spinner in Vibrant.
struct PizzaSpinner: View {
    var size: CGFloat = 16
    @State private var spin = false

    var body: some View {
        Text("🍕")
            .font(.system(size: size))
            .rotationEffect(.degrees(spin ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    spin = true
                }
            }
    }
}
