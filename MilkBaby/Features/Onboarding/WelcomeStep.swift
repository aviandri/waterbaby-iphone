import SwiftUI

/// "Track your baby's milk" + capybara art + dark GET STARTED pill.
struct WelcomeStep: View {
    let onStart: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            Image(systemName: "hands.clap.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.milkSky)
                .symbolEffect(.bounce, value: appeared)
            Text("Track your baby's milk")
                .font(Theme.rounded(30))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 24)

            CapybaraIllustration()
                .frame(maxWidth: 300, maxHeight: 340)
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)

            Spacer(minLength: 24)
            Button("Get started", action: onStart)
                .buttonStyle(PillButtonStyle())
                .padding(.bottom, 24)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.35)) { appeared = true }
        }
    }
}

#Preview {
    WelcomeStep(onStart: {})
}
