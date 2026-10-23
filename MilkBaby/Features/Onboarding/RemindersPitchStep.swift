import SwiftUI

/// "Smart Reminders" pitch card. The CTA asks for notification permission; SKIP finishes without it.
struct RemindersPitchStep: View {
    let onEnable: () async -> Void
    let onSkip: () -> Void
    @Environment(AppSettings.self) private var settings
    @State private var requesting = false

    private var babyName: String { settings.babyName.isEmpty ? "your baby" : settings.babyName }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip", action: onSkip)
                    .font(Theme.capsLabel)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.subtle)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Text("Smart Reminders")
                .font(Theme.rounded(32))
                .foregroundStyle(Theme.ink)
                .padding(.top, 16)
            Text("Gentle nudges when it's time for \(babyName)'s next feed")
                .font(Theme.rounded(15, .semibold))
                .foregroundStyle(Theme.subtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 6)

            pitchCard
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer(minLength: 24)
            Button {
                requesting = true
                Task {
                    await onEnable()
                    requesting = false
                }
            } label: {
                if requesting {
                    ProgressView().tint(.white)
                } else {
                    Text("Remind me to feed")
                }
            }
            .buttonStyle(PillButtonStyle())
            .disabled(requesting)
            .padding(.bottom, 24)
        }
    }

    private var pitchCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            Text("Only \(settings.unit.format(120)) to go!")
                .font(Theme.rounded(26))
                .foregroundStyle(.white)
            CapybaraIllustration()
                .frame(maxWidth: 240, maxHeight: 220)
        }
        .padding(.top, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .bottom) {
            // Speech-bubble tail.
            SpeechTail()
                .fill(Theme.accent)
                .frame(width: 28, height: 14)
                .offset(y: 13)
        }
    }
}

private struct SpeechTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    RemindersPitchStep(onEnable: {}, onSkip: {})
        .environment(AppSettings(defaults: UserDefaults(suiteName: "RemindersPreview")!))
}
