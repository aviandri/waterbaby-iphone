import SwiftUI

/// Friendly full-colour capybara sitting up with a baby bottle and a yuzu on its head, for the
/// onboarding welcome screen (Waterllama's bear/tiger/otter art). Drawn in a 200×240 view box and
/// scaled to fit. Master artwork: `docs/brand/capybara-illustration.svg`.
struct CapybaraIllustration: View {
    private static let viewBox = CGSize(width: 200, height: 240)

    private enum Palette {
        static let fur = Theme.capybaraBrown
        static let furDark = Color(red: 0.604, green: 0.416, blue: 0.271)   // #9A6A45 muzzle, ears, paws
        static let belly = Color(red: 0.851, green: 0.682, blue: 0.522)     // #D9AE85
        static let feet = Theme.capybaraDark
        static let earInner = Color(red: 0.910, green: 0.643, blue: 0.541)  // #E8A48A
        static let nose = Color(red: 0.290, green: 0.188, blue: 0.125)      // #4A3020
        static let yuzu = Color(red: 0.992, green: 0.706, blue: 0.294)     // #FDB44B
        static let leaf = Color(red: 0.549, green: 0.773, blue: 0.420)      // #8CC56B
        static let bottleOutline = Color(red: 0.890, green: 0.902, blue: 0.925) // #E3E6EC
    }

    private static let torso = SVGPath("""
        M 100 96 C 150 96 172 144 170 186 C 168 218 140 231 100 231
        C 60 231 32 218 30 186 C 28 144 50 96 100 96 Z
        """)
    private static let head = SVGPath("""
        M 100 20 C 136 20 148 34 148 60 L 148 102 C 148 124 130 134 100 134
        C 70 134 52 124 52 102 L 52 60 C 52 34 64 20 100 20 Z
        """)
    private static let teat = SVGPath("M 93 144 C 93 136 96 130 100 130 C 104 130 107 136 107 144 Z")
    private static let milk = SVGPath("""
        M 85 172 C 94 168 106 176 115 172 L 115 201 C 115 207 111 211 105 211
        L 95 211 C 89 211 85 207 85 201 Z
        """)
    private static let mouth = SVGPath("M 92 116 Q 96 120 100 116 Q 104 120 108 116")

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / Self.viewBox.width, size.height / Self.viewBox.height)
            context.translateBy(
                x: (size.width - Self.viewBox.width * scale) / 2,
                y: (size.height - Self.viewBox.height * scale) / 2
            )
            context.scaleBy(x: scale, y: scale)

            func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
                Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
            }
            func fill(_ path: Path, _ color: Color) {
                context.fill(path, with: .color(color))
            }

            // Ground shadow, body, belly, feet
            fill(ellipse(100, 233, 72, 6), Theme.ink.opacity(0.06))
            fill(Self.torso.path, Palette.fur)
            fill(ellipse(100, 190, 44, 38), Palette.belly)
            fill(ellipse(64, 227, 22, 9), Palette.feet)
            fill(ellipse(136, 227, 22, 9), Palette.feet)

            // Bottle, tilted in its paws
            var bottle = context
            bottle.translateBy(x: 100, y: 180)
            bottle.rotate(by: .degrees(-12))
            bottle.translateBy(x: -100, y: -180)
            bottle.fill(Self.teat.path, with: .color(Theme.accent))
            bottle.fill(Path(roundedRect: CGRect(x: 87, y: 142, width: 26, height: 11), cornerRadius: 4),
                        with: .color(Theme.milkSky))
            let flask = Path(roundedRect: CGRect(x: 83, y: 151, width: 34, height: 62), cornerRadius: 12)
            bottle.fill(flask, with: .color(.white))
            bottle.stroke(flask, with: .color(Palette.bottleOutline), lineWidth: 2)
            bottle.fill(Self.milk.path, with: .color(Theme.milkCream))
            for y: CGFloat in [160, 169, 178] {
                bottle.fill(Path(roundedRect: CGRect(x: 103, y: y, width: 8, height: 2.5), cornerRadius: 1.25),
                            with: .color(Theme.milkSky))
            }

            // Paws over the bottle
            fill(ellipse(80, 192, 12, 10), Palette.furDark)
            fill(ellipse(124, 180, 12, 10), Palette.furDark)

            // Ears, head, muzzle
            fill(ellipse(61, 30, 9, 9), Palette.furDark)
            fill(ellipse(139, 30, 9, 9), Palette.furDark)
            fill(ellipse(62, 31, 4.5, 4.5), Palette.earInner)
            fill(ellipse(138, 31, 4.5, 4.5), Palette.earInner)
            fill(Self.head.path, Palette.fur)
            fill(Path(roundedRect: CGRect(x: 62, y: 84, width: 76, height: 46), cornerRadius: 23), Palette.furDark)

            // Yuzu on its head
            fill(ellipse(100, 17, 12, 12), Palette.yuzu)
            fill(ellipse(107.5, 6, 6.5, 3.2).rotated(by: .degrees(-25), around: CGPoint(x: 107.5, y: 6)), Palette.leaf)
            fill(ellipse(96, 13, 2.8, 2.8), Color.white.opacity(0.5))

            // Face
            fill(ellipse(74, 60, 5.5, 5.5), Theme.ink)
            fill(ellipse(126, 60, 5.5, 5.5), Theme.ink)
            fill(ellipse(76, 58, 1.8, 1.8), .white)
            fill(ellipse(128, 58, 1.8, 1.8), .white)
            fill(ellipse(60, 78, 7, 4.5), Theme.accent.opacity(0.5))
            fill(ellipse(140, 78, 7, 4.5), Theme.accent.opacity(0.5))
            fill(ellipse(87, 98, 3.5, 5), Palette.nose)
            fill(ellipse(113, 98, 3.5, 5), Palette.nose)
            context.stroke(Self.mouth.path, with: .color(Palette.nose),
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .aspectRatio(Self.viewBox.width / Self.viewBox.height, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("A capybara holding a baby bottle")
    }
}

#Preview {
    CapybaraIllustration()
        .frame(height: 360)
        .padding()
}
