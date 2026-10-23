import SwiftUI

/// Shows the splash, then onboarding until it is finished, then the home screen.
struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if settings.hasOnboarded {
                HomeView()
            } else {
                OnboardingFlow()
            }
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeOut(duration: 0.3)) { showSplash = false }
        }
    }
}
