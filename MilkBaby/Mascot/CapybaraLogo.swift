import SwiftUI

/// The MilkBaby brand mark: the capybara's head and shoulders in a round cream badge, the same art
/// as the app icon. Square, scales to any size. The `CapybaraLogo` asset is a transparent PNG made
/// from `docs/brand/source/app-icon-higgsfield-2048.png`.
struct CapybaraLogo: View {
    /// Warm cream behind the capybara on the app icon and the badge.
    static let iconBackground = Color(red: 1.0, green: 0.965, blue: 0.902) // #FFF6E6

    var body: some View {
        Image("CapybaraLogo")
            .resizable()
            .scaledToFit()
            .accessibilityLabel("MilkBaby")
    }
}

#Preview("Mark") {
    CapybaraLogo()
        .frame(width: 200, height: 200)
}

#Preview("Splash size") {
    CapybaraLogo()
        .frame(width: 120, height: 120)
}
