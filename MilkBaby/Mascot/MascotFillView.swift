import SwiftUI

// OWNER: mascot session. Contract: render the capybara silhouette in `Theme.silhouetteEmpty`,
// with `segments` stacked bottom-up inside it (clipped to the silhouette), animating height changes.
// Total fill is clamped to 100%.
struct MascotFillView: View {
    var segments: [FillSegment]

    var body: some View {
        CapybaraSilhouette()
            .fill(Theme.silhouetteEmpty)
            .aspectRatio(1.25, contentMode: .fit)
    }
}
