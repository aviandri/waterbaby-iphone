import SwiftUI

/// "See how much Mia needs": AGE and WEIGHT rows feed `GoalCalculator`; the result sits in a wavy
/// panel at the bottom. "SET CUSTOM" lets parents override it.
struct GoalCalculatorStep: View {
    @Binding var draft: OnboardingDraft
    let onBack: () -> Void
    let onEditAge: () -> Void
    let onEditWeight: () -> Void
    let onContinue: () -> Void
    @State private var showingCustom = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                OnboardingBackButton(action: onBack)
                Spacer()
                Button("Set custom") { showingCustom = true }
                    .font(Theme.capsLabel)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Text("See how much \(draft.displayName) needs")
                .font(Theme.rounded(30))
                .foregroundStyle(Theme.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 28)

            VStack(spacing: 0) {
                Divider()
                row("Age", value: draft.ageText, action: onEditAge)
                Divider()
                row("Weight", value: String(format: "%.1f kg", draft.weightKg), action: onEditWeight)
                Divider()
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 24)
            goalPanel
        }
        .sheet(isPresented: $showingCustom) {
            CustomGoalSheet(goalML: draft.goalML, suggestedML: draft.suggestedGoalML) { draft.customGoalML = $0 }
                .presentationDetents([.height(340)])
                .presentationCornerRadius(28)
        }
    }

    private func row(_ title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title.uppercased())
                    .font(Theme.capsLabel)
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(value)
                    .font(Theme.rounded(15, .bold))
                    .foregroundStyle(Theme.accent)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.subtle)
            }
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var goalPanel: some View {
        VStack(spacing: 6) {
            Text(VolumeUnit.ml.format(draft.goalML))
                .font(Theme.rounded(56))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(draft.customGoalML == nil ? "Suggested daily goal" : "Your custom daily goal")
                .font(Theme.capsLabel)
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.85))
            Button("Continue", action: onContinue)
                .buttonStyle(PillButtonStyle(background: .white, foreground: Theme.ink))
                .padding(.top, 24)
            Text("A rule of thumb, not medical advice. You can change it any time.")
                .font(Theme.rounded(12, .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)
        }
        .padding(.top, 48)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background {
            GoalPanelWave()
                .fill(Theme.accent)
                .ignoresSafeArea(edges: .bottom)
        }
        .animation(.snappy, value: draft.goalML)
    }
}

/// Rectangle whose top edge is a gentle wave, like Waterllama's water panel.
struct GoalPanelWave: Shape {
    var amplitude: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + amplitude))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + amplitude),
            control1: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY - amplitude),
            control2: CGPoint(x: rect.minX + rect.width * 0.65, y: rect.minY + amplitude * 3)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Bottom sheet for typing in a custom daily goal (in ml; units are picked after this step).
struct CustomGoalSheet: View {
    @State private var goalML: Double
    let suggestedML: Double
    let onSave: (Double?) -> Void
    @Environment(\.dismiss) private var dismiss

    init(goalML: Double, suggestedML: Double, onSave: @escaping (Double?) -> Void) {
        _goalML = State(initialValue: goalML)
        self.suggestedML = suggestedML
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Use suggested \(VolumeUnit.ml.format(suggestedML))") {
                    onSave(nil)
                    dismiss()
                }
                .font(Theme.capsLabel)
                .textCase(.uppercase)
                .foregroundStyle(Theme.accent)
                Spacer()
                CloseButton { dismiss() }
            }

            Text(VolumeUnit.ml.format(goalML))
                .font(Theme.rounded(48))
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
                .animation(.snappy, value: goalML)

            Slider(value: $goalML, in: 200...1500, step: 10)
                .tint(Theme.accent)

            Button("Save goal") {
                onSave(goalML)
                dismiss()
            }
            .buttonStyle(PillButtonStyle())
        }
        .padding(24)
    }
}

#Preview {
    GoalCalculatorStep(
        draft: .constant(OnboardingDraft()),
        onBack: {}, onEditAge: {}, onEditWeight: {}, onContinue: {}
    )
}

#Preview("Custom goal") {
    CustomGoalSheet(goalML: 680, suggestedML: 680) { _ in }
}
