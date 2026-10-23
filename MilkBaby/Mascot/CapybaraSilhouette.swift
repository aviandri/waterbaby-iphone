import SwiftUI

// OWNER: mascot session. Replace the placeholder path with a real side-profile capybara.
// Contract: a Shape that draws a capybara silhouette filling its rect, aspect ~1.25:1 (w:h).
struct CapybaraSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect.insetBy(dx: rect.width * 0.05, dy: rect.height * 0.15))
    }
}
