import SwiftUI

// OWNER: onboarding session. Contract: sets up AppSettings and finally sets `hasOnboarded = true`.
struct OnboardingFlow: View {
    @Environment(AppSettings.self) private var settings
    var body: some View {
        Button("Get started") { settings.hasOnboarded = true }
    }
}
