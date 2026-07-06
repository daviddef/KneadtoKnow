import SwiftUI

/// The three poke-test outcomes — a quick, hands-on way to judge whether
/// shaped dough is ready to bake, from underproofed to overproofed.
enum PokeStage: CaseIterable, Hashable {
    case underproofed, ready, overproofed

    var verdict: String {
        switch self {
        case .underproofed: return "Underproofed — give it more time"
        case .ready:        return "Ready to bake"
        case .overproofed:  return "Overproofed"
        }
    }

    var detail: String {
        switch self {
        case .underproofed:
            return "The dent fills back in almost instantly. It hasn't built enough gas yet — rest it a while longer."
        case .ready:
            return "The dent fills back in slowly, leaving a slight, shallow mark. That's the sweet spot — shape and bake now."
        case .overproofed:
            return "The dent barely moves, or the dough looks deflated. Bake it now rather than losing more structure, and rest it less time next time."
        }
    }

    /// How far the dent's rebound gets drawn — 1 springs fully back, 0 stays put.
    var reboundFraction: Double {
        switch self {
        case .underproofed: return 1.0
        case .ready:         return 0.45
        case .overproofed:   return 0.05
        }
    }

    var color: Color {
        switch self {
        case .underproofed: return Palette.amber
        case .ready:         return Palette.sage
        case .overproofed:   return Palette.danger
        }
    }
}

/// A minimal side-profile of dough with a finger dimple and an arrow showing
/// how much (and how fast) it springs back — the test in one small drawing
/// rather than a paragraph.
private struct PokeDimpleGraphic: View {
    let color: Color
    let reboundFraction: Double

    var body: some View {
        Canvas { context, size in
            let w = size.width, h = size.height
            let baseline = h * 0.74
            let dimpleDepth = h * 0.42 * (1 - reboundFraction * 0.85)
            let dimpleX = w * 0.42

            var surface = Path()
            surface.move(to: CGPoint(x: 0, y: baseline - h * 0.08))
            surface.addCurve(to: CGPoint(x: dimpleX, y: baseline + dimpleDepth),
                              control1: CGPoint(x: w * 0.18, y: baseline - h * 0.06),
                              control2: CGPoint(x: w * 0.30, y: baseline + dimpleDepth))
            surface.addCurve(to: CGPoint(x: w * 0.68, y: baseline),
                              control1: CGPoint(x: w * 0.56, y: baseline + dimpleDepth),
                              control2: CGPoint(x: w * 0.60, y: baseline))
            surface.addCurve(to: CGPoint(x: w, y: baseline - h * 0.1),
                              control1: CGPoint(x: w * 0.84, y: baseline + h * 0.03),
                              control2: CGPoint(x: w * 0.94, y: baseline - h * 0.05))
            context.stroke(surface, with: .color(color), lineWidth: 2.5)

            var fill = surface
            fill.addLine(to: CGPoint(x: w, y: h))
            fill.addLine(to: CGPoint(x: 0, y: h))
            fill.closeSubpath()
            context.fill(fill, with: .color(color.opacity(0.14)))

            // The rebound arrow — taller the faster it springs back; absent
            // when it barely moves at all (overproofed).
            if reboundFraction > 0.15 {
                let arrowHeight = h * 0.36 * reboundFraction
                let tip = CGPoint(x: dimpleX, y: baseline - h * 0.1 - arrowHeight)
                var arrow = Path()
                arrow.move(to: CGPoint(x: dimpleX, y: baseline - h * 0.12))
                arrow.addLine(to: tip)
                arrow.move(to: CGPoint(x: dimpleX - 4, y: tip.y + 6))
                arrow.addLine(to: tip)
                arrow.addLine(to: CGPoint(x: dimpleX + 4, y: tip.y + 6))
                context.stroke(arrow, with: .color(color),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }

            // The finger — a small dot marking where it pressed in.
            context.fill(Path(ellipseIn: CGRect(x: dimpleX - 3, y: baseline + dimpleDepth - 3, width: 6, height: 6)),
                          with: .color(color))
        }
    }
}

private struct PokeStageRow: View {
    let stage: PokeStage

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            PokeDimpleGraphic(color: stage.color, reboundFraction: stage.reboundFraction)
                .frame(width: 56, height: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(stage.verdict)
                    .font(.rounded(15, weight: .bold))
                    .foregroundStyle(stage.color)
                Text(stage.detail)
                    .font(.rounded(13))
                    .foregroundStyle(Palette.textSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// The full illustrated guide — dropped inline during a shaped-dough proofing
/// step, since the poke test only makes sense once there's dough to press.
struct PokeTestGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("The poke test", systemImage: "hand.point.down.fill")
                .font(.rounded(13, weight: .bold))
                .foregroundStyle(Palette.textSoft)
            Text("Flour a fingertip and press gently into the dough, about a centimetre deep.")
                .font(.rounded(13))
                .foregroundStyle(Palette.textSoft)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 14) {
                ForEach(PokeStage.allCases, id: \.self) { stage in
                    PokeStageRow(stage: stage)
                }
            }
        }
    }
}
