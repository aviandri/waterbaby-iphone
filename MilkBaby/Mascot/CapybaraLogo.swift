import SwiftUI

/// The MilkBaby brand mark: a side-profile capybara head built from stacked milk-colour bands
/// (Waterllama's layered llama head, done as a capybara). Square, scales to any size.
/// Master artwork: `docs/brand/logo.svg`; the app icon is this mark on `CapybaraLogo.iconBackground`.
struct CapybaraLogo: View {
    /// Warm cream behind the mark on the app icon.
    static let iconBackground = Color(red: 1.0, green: 0.965, blue: 0.902) // #FFF6E6

    private static let viewBox: CGFloat = 100
    private static let head = SVGPath("""
        M 20 40 C 24 30 32 25 42 25 C 58 25 74 26 85 30 C 93 33 96 41 95 49
        C 94 57 89 62 81 63 C 73 64 66 65 60 66 C 54 67 50 71 49 76
        C 48 81 50 86 52 90 C 40 94 24 94 14 89 C 12 72 14 52 20 40 Z
        """)
    /// Each band covers everything below its wavy top edge; later bands paint over earlier ones.
    private static let bands: [(path: SVGPath, color: Color)] = [
        (SVGPath("M 0 0 L 100 0 L 100 100 L 0 100 Z"), Theme.milkButter),
        (SVGPath("M 0 45 C 30 41 60 49 100 43 L 100 100 L 0 100 Z"), Theme.milkPeach),
        (SVGPath("M 0 63 C 20 59 40 67 100 61 L 100 100 L 0 100 Z"), Theme.milkSky),
        (SVGPath("M 0 79 C 20 75 40 81 100 77 L 100 100 L 0 100 Z"), Theme.capybaraDark),
    ]

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / Self.viewBox
            context.translateBy(
                x: (size.width - Self.viewBox * scale) / 2,
                y: (size.height - Self.viewBox * scale) / 2
            )
            context.scaleBy(x: scale, y: scale)

            let ear = Path(ellipseIn: CGRect(x: 26.5, y: 16.5, width: 13, height: 15))
                .rotated(by: .degrees(-25), around: CGPoint(x: 33, y: 24))
            context.fill(ear, with: .color(Theme.accent))

            context.drawLayer { layer in
                layer.clip(to: Self.head.path)
                for band in Self.bands {
                    layer.fill(band.path.path, with: .color(band.color))
                }
            }

            context.fill(Path(ellipseIn: CGRect(x: 55, y: 33, width: 6, height: 6)), with: .color(Theme.ink))
            let nostril = Path(ellipseIn: CGRect(x: 88.4, y: 35.6, width: 3.2, height: 4.8))
                .rotated(by: .degrees(20), around: CGPoint(x: 90, y: 38))
            context.fill(nostril, with: .color(Theme.ink.opacity(0.8)))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("MilkBaby")
    }
}

#Preview("Mark") {
    CapybaraLogo()
        .frame(width: 200, height: 200)
}

#Preview("App icon") {
    CapybaraLogo()
        .padding(40)
        .frame(width: 256, height: 256)
        .background(CapybaraLogo.iconBackground)
        .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
}
