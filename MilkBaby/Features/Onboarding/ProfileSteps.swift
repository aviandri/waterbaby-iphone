import SwiftUI

/// "What's your baby's name?"
struct NameStep: View {
    @Binding var name: String
    let progress: Double
    let onBack: () -> Void
    let onContinue: () -> Void
    @FocusState private var focused: Bool

    private var trimmed: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        OnboardingPage(
            title: "What's your baby's name?",
            subtitle: "We'll use it to cheer them on",
            progress: progress,
            canContinue: !trimmed.isEmpty,
            onBack: onBack,
            onContinue: onContinue
        ) {
            TextField("Name", text: $name)
                .font(Theme.rounded(34))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .textContentType(.givenName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focused)
                .onSubmit { if !trimmed.isEmpty { onContinue() } }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Capsule().fill(Theme.silhouetteEmpty).frame(height: 3)
                }
                .padding(.horizontal, 48)
        }
        .onAppear { focused = true }
    }
}

/// "When was Mia born?"
struct BirthDateStep: View {
    @Binding var draft: OnboardingDraft
    let progress: Double
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingPage(
            title: "When was \(draft.displayName) born?",
            subtitle: draft.ageText,
            progress: progress,
            onBack: onBack,
            onContinue: onContinue
        ) {
            DatePicker("Birth date", selection: $draft.birthDate, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 24)
        }
    }
}

/// "How much does Mia weigh?" — big number, −/+ buttons and a slider, shown in kg or lb but stored in kg.
struct WeightStep: View {
    @Binding var draft: OnboardingDraft
    let progress: Double
    let onBack: () -> Void
    let onContinue: () -> Void
    @State private var unit: WeightUnit = .kg

    private static let rangeKg = 1.5...25.0

    private var displayed: Binding<Double> {
        Binding(
            get: { draft.weightKg * unit.perKg },
            set: { draft.weightKg = min(max($0 / unit.perKg, Self.rangeKg.lowerBound), Self.rangeKg.upperBound) }
        )
    }

    var body: some View {
        OnboardingPage(
            title: "How much does \(draft.displayName) weigh?",
            subtitle: "Used to suggest a daily milk goal",
            progress: progress,
            onBack: onBack,
            onContinue: onContinue
        ) {
            VStack(spacing: 28) {
                Picker("Unit", selection: $unit) {
                    ForEach(WeightUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)

                HStack(spacing: 28) {
                    stepButton("minus") { displayed.wrappedValue -= 0.1 }
                    Text(String(format: "%.1f", displayed.wrappedValue))
                        .font(Theme.rounded(56))
                        .foregroundStyle(Theme.ink)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .frame(minWidth: 130)
                        .overlay(alignment: .bottom) {
                            Text(unit.rawValue.uppercased())
                                .font(Theme.capsLabel)
                                .foregroundStyle(Theme.subtle)
                                .offset(y: 20)
                        }
                    stepButton("plus") { displayed.wrappedValue += 0.1 }
                }

                Slider(
                    value: displayed,
                    in: (Self.rangeKg.lowerBound * unit.perKg)...(Self.rangeKg.upperBound * unit.perKg),
                    step: 0.1
                )
                .tint(Theme.accent)
                .padding(.horizontal, 40)
                .padding(.top, 12)
            }
            .animation(.snappy, value: draft.weightKg)
        }
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Theme.accent)
                .frame(width: 48, height: 48)
                .background(Theme.accent.opacity(0.15), in: Circle())
        }
        .buttonRepeatBehavior(.enabled)
    }
}

enum WeightUnit: String, CaseIterable, Identifiable {
    case kg, lb
    var id: String { rawValue }
    var perKg: Double { self == .kg ? 1 : 2.20462 }
}

extension OnboardingDraft {
    /// "Newborn", "3 months old", "1 year 2 months old".
    var ageText: String {
        let months = ageMonths
        switch months {
        case ..<1: return "Newborn"
        case 1: return "1 month old"
        case 2..<12: return "\(months) months old"
        default:
            let years = months / 12, rest = months % 12
            let yearText = years == 1 ? "1 year" : "\(years) years"
            guard rest > 0 else { return "\(yearText) old" }
            return "\(yearText) \(rest == 1 ? "1 month" : "\(rest) months") old"
        }
    }
}

#Preview("Name") {
    NameStep(name: .constant("Mia"), progress: 0.25, onBack: {}, onContinue: {})
}

#Preview("Birth date") {
    BirthDateStep(draft: .constant(OnboardingDraft()), progress: 0.5, onBack: {}, onContinue: {})
}

#Preview("Weight") {
    WeightStep(draft: .constant(OnboardingDraft()), progress: 0.75, onBack: {}, onContinue: {})
}
