import SwiftUI

/// Full-screen white splash: the centred capybara mark pops in, with a two-tone footer line
/// like Waterllama's "Made with love in Ukraine".
struct SplashView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            CapybaraLogo()
                .frame(width: 96, height: 96)
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
            VStack(spacing: 2) {
                Spacer()
                Text("Made with love")
                    .foregroundStyle(Theme.milkSky)
                Text("for little tummies")
                    .foregroundStyle(Theme.accent)
            }
            .font(Theme.rounded(15, .semibold))
            .padding(.bottom, 24)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appeared = true }
        }
    }
}

#Preview {
    SplashView()
}
