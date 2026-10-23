import SwiftUI

/// The MilkBaby capybara hero art: chubby, front-facing, a yuzu on its head and a baby bottle in
/// its paws, for onboarding (Waterllama's bear/tiger/otter art). The `CapybaraHero` asset is a
/// transparent PNG cut from `docs/brand/source/capybara-v2.png`, so it sits cleanly on any background.
struct CapybaraIllustration: View {
    var body: some View {
        Image("CapybaraHero")
            .resizable()
            .scaledToFit()
            .accessibilityLabel("A capybara holding a baby bottle")
    }
}

#Preview("On white") {
    CapybaraIllustration()
        .frame(height: 360)
        .padding()
}

#Preview("On accent") {
    CapybaraIllustration()
        .frame(height: 220)
        .padding()
        .background(Theme.accent)
}
