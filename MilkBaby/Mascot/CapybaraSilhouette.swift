import SwiftUI

/// The MilkBaby capybara from the front, as on the hero art: domed head with two small round ears,
/// round cheeks, chubby belly and two short legs (the yuzu is left out). Drawn in a 68×100 view box,
/// the art's own proportions; the shape stretches to its rect, so give it a `CapybaraSilhouette.aspect`
/// frame. Master artwork: `docs/brand/capybara-silhouette.svg`.
struct CapybaraSilhouette: Shape {
    /// Width ÷ height.
    static let aspect: CGFloat = viewBox.width / viewBox.height
    /// Ear tips to soles as fractions of the rect height, so fills can map 0–100% onto the body itself.
    static let verticalExtent: ClosedRange<CGFloat> = 0...0.998
    private static let viewBox = CGSize(width: 68, height: 100)
    private static let outline = SVGPath("""
        M 34 2.2 C 40.5 2.2 46 3.4 49.5 5.6 C 49.8 2 52.5 0.3 55.2 0.3
        C 58.6 0.3 60.6 2.8 60.4 5.6 C 60.3 6.8 59.9 7.6 59.3 8.2 C 63.6 12 66.6 21 66.6 31
        C 66.6 39 63 42 63 48 C 63 55 68 60 68 69 C 68 80 63 88 56.5 91.5
        C 56 95 56.4 99.8 53 99.8 C 49 99.8 46 99.8 43 99.8 C 41 99.8 40.9 96 40.6 93.5
        C 38.5 92.9 36.5 92.8 34 92.8 C 31.5 92.8 29.5 92.9 27.4 93.5 C 27.1 96 27 99.8 25 99.8
        C 22 99.8 19 99.8 15 99.8 C 11.6 99.8 12 95 11.5 91.5 C 5 88 0 80 0 69
        C 0 60 5 55 5 48 C 5 42 1.4 39 1.4 31 C 1.4 21 4.4 12 8.7 8.2
        C 8.1 7.6 7.7 6.8 7.6 5.6 C 7.4 2.8 9.4 0.3 12.8 0.3 C 15.5 0.3 18.2 2 18.5 5.6
        C 22 3.4 27.5 2.2 34 2.2 Z
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
