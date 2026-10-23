import SwiftUI

/// Shared layout for the profile questions: back button + progress bar, a big title, the question's
/// control, and a CONTINUE pill pinned to the bottom.
struct OnboardingPage<Content: View>: View {
    let title: String
    var subtitle: String?
    let progress: Double
    var canContinue: Bool
    let onBack: () -> Void
    let onContinue: () -> Void
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        progress: Double,
        canContinue: Bool = true,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.canContinue = canContinue
        self.onBack = onBack
        self.onContinue = onContinue
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                OnboardingBackButton(action: onBack)
                OnboardingProgressBar(progress: progress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(spacing: 8) {
                Text(title)
                    .font(Theme.rounded(30))
                    .foregroundStyle(Theme.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.rounded(16, .semibold))
                        .foregroundStyle(Theme.subtle)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .padding(.top, 40)

            Spacer(minLength: 24)
            content
            Spacer(minLength: 24)

            Button("Continue", action: onContinue)
                .buttonStyle(PillButtonStyle())
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.4)
                .padding(.bottom, 24)
        }
    }
}

/// Grey circular "‹" in the top-left, the mirror of `CloseButton`.
struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.gray.opacity(0.35), in: Circle())
        }
        .accessibilityLabel("Back")
    }
}

struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.silhouetteEmpty)
                Capsule()
                    .fill(Theme.accent)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 8)
        .animation(.spring(duration: 0.4), value: progress)
    }
}

/// Waterllama-style single-choice question: a white bottom card with tinted pills over a dimmed,
/// still-empty home screen.
struct OnboardingChoiceSheet: View {
    struct Option: Identifiable {
        let label: String
        let action: () -> Void
        var id: String { label }
    }

    let title: String
    let options: [Option]

    var body: some View {
        ZStack(alignment: .bottom) {
            emptyHome
            Color.black.opacity(0.35).ignoresSafeArea()
            card
        }
    }

    private var emptyHome: some View {
        VStack(spacing: 40) {
            Text("Log the first feed")
                .font(Theme.rounded(28))
                .foregroundStyle(Theme.ink)
                .padding(.top, 40)
            CapybaraSilhouette()
                .fill(Theme.silhouetteEmpty)
                .aspectRatio(CapybaraSilhouette.aspect, contentMode: .fit)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }

    private var card: some View {
        VStack(spacing: 14) {
            Text(title)
                .font(Theme.rounded(26, .bold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            ForEach(options) { option in
                Button(action: option.action) {
                    Text(option.label).frame(minWidth: 190)
                }
                .buttonStyle(PillButtonStyle(background: Theme.accent))
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 36)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview("Question page") {
    OnboardingPage(title: "What's your baby's name?", progress: 0.25, onBack: {}, onContinue: {}) {
        Text("Content")
    }
}

#Preview("Choice sheet") {
    OnboardingChoiceSheet(title: "What's your units?", options: [
        .init(label: "oz (ounces)") {},
        .init(label: "ml (millilitres)") {},
    ])
}
