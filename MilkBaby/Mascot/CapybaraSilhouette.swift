import SwiftUI

/// The MilkBaby capybara from the front, as on the hero art: yuzu on top, round head with tiny ears,
/// chubby pear-shaped body and short legs. Drawn in a 62×100 view box (the shape stretches to its
/// rect, so give it a `CapybaraSilhouette.aspect` frame). Master artwork: `docs/brand/capybara-silhouette.svg`.
struct CapybaraSilhouette: Shape {
    /// Width ÷ height.
    static let aspect: CGFloat = viewBox.width / viewBox.height
    /// Yuzu top to soles as fractions of the rect height, so fills can map 0–100% onto the body itself.
    static let verticalExtent: ClosedRange<CGFloat> = 0.002...0.998
    private static let viewBox = CGSize(width: 62, height: 100)
    private static let outline = SVGPath("""
        M 31 0.2 C 35.6 0.2 39.3 3.9 39.3 8.5 C 39.3 10 39 11.3 38.5 12
        C 40.5 11.3 42.5 11.2 44.5 11.6 C 45.5 8.8 49 8.4 52.5 8.5 C 56.5 8.6 58.6 11.5 57.8 16
        C 57.3 19 55.5 21 55.5 24.5 C 55.5 30 61.4 33 61.4 40 C 61.4 46 57.5 48 57.5 52
        C 57.5 57 62 63 62 71.5 C 62 82 56.5 90 51 93 C 50.4 96 51 99.8 48 99.8
        C 44 99.8 42 99.8 39 99.8 C 37 99.8 36.8 95.5 36.4 93.6 C 34.5 93 33 92.8 31 92.8
        C 29 92.8 27.5 93 25.6 93.6 C 25.2 95.5 25 99.8 23 99.8 C 20 99.8 18 99.8 14 99.8
        C 11 99.8 11.6 96 11 93 C 5.5 90 0 82 0 71.5 C 0 63 4.5 57 4.5 52
        C 4.5 48 0.6 46 0.6 40 C 0.6 33 6.5 30 6.5 24.5 C 6.5 21 4.7 19 4.2 16
        C 3.4 11.5 5.5 8.6 9.5 8.5 C 13 8.4 16.5 8.8 17.5 11.6 C 19.5 11.2 21.5 11.3 23.5 12
        C 23 11.3 22.7 10 22.7 8.5 C 22.7 3.9 26.4 0.2 31 0.2 Z
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
