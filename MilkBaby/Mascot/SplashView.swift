import SwiftUI

// OWNER: mascot session. Contract: full-screen white splash with the centred logo.
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            CapybaraLogo().frame(width: 96, height: 96)
        }
    }
}
