import SwiftUI

// OWNER: mascot session. Contract: a friendly full-colour capybara (sitting, holding a baby bottle)
// for the onboarding welcome screen — the equivalent of Waterllama's bear/tiger/otter art.
struct CapybaraIllustration: View {
    var body: some View {
        CapybaraSilhouette().fill(Theme.capybaraBrown)
    }
}
