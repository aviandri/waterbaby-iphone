import SwiftUI

/// Side-profile capybara facing right: barrel body, flat-topped boxy head with a blunt snout,
/// small round ear and short legs. Drawn in a 125×100 view box (the shape stretches to its rect,
/// so give it a 1.25:1 frame). Master artwork: `docs/brand/capybara-silhouette.svg`.
struct CapybaraSilhouette: Shape {
    static let aspect: CGFloat = 1.25
    /// Ear tip to soles as fractions of the rect height, so fills can map 0–100% onto the body itself.
    static let verticalExtent: ClosedRange<CGFloat> = 0.086...0.96
    private static let viewBox = CGSize(width: 125, height: 100)
    private static let outline = SVGPath("""
        M 12 60 C 5 42 14 24 36 20 C 52 17 66 18 73 20
        C 76 19 78 17.5 80 16 C 80 10 85 7 88.5 9.5 C 91 11.5 91 14.5 89.5 16.5
        C 98 16 109 17 115 21 C 121 25 123 34 121 40 C 119 45 115 48 109 49
        C 104 50 101 53 98 56 C 95 58 92 59 90 60 C 89 65 90 70 89 76
        L 90 91 C 90 94 88 96 85 96 L 79 96 C 76 96 75 94 76 91 L 76 80
        C 66 83 54 83 46 80
        L 44 92 C 44 95 42 96 39 96 L 27 96 C 24 96 23 94 24 91 C 17 86 12 76 12 60 Z
        """)

    func path(in rect: CGRect) -> Path {
        Self.outline.path(in: rect, viewBox: Self.viewBox)
    }
}

#Preview {
    CapybaraSilhouette()
        .fill(Theme.capybaraBrown)
        .aspectRatio(CapybaraSilhouette.aspect, contentMode: .fit)
        .padding()
}
