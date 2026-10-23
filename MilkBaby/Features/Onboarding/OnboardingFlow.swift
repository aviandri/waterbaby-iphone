import SwiftUI

// OWNER: onboarding session. Contract: sets up AppSettings and finally sets `hasOnboarded = true`.
struct OnboardingFlow: View {
    @Environment(AppSettings.self) private var settings
    @State private var step: OnboardingStep = .welcome
    @State private var draft = OnboardingDraft()
    @State private var didLoadDraft = false
    @State private var goingBack = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            page
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: goingBack ? .leading : .trailing).combined(with: .opacity),
                    removal: .move(edge: goingBack ? .trailing : .leading).combined(with: .opacity)
                ))
        }
        .onAppear {
            guard !didLoadDraft else { return }
            draft = OnboardingDraft(settings: settings)
            didLoadDraft = true
        }
    }

    @ViewBuilder
    private var page: some View {
        switch step {
        case .welcome:
            WelcomeStep(onStart: advance)
        case .name:
            NameStep(name: $draft.babyName, progress: step.progress, onBack: back, onContinue: advance)
        case .birthDate:
            BirthDateStep(draft: $draft, progress: step.progress, onBack: back, onContinue: advance)
        case .weight:
            WeightStep(draft: $draft, progress: step.progress, onBack: back, onContinue: advance)
        case .goal:
            GoalCalculatorStep(
                draft: $draft,
                onBack: back,
                onEditAge: { go(to: .birthDate) },
                onEditWeight: { go(to: .weight) },
                onContinue: {
                    saveProfile()
                    advance()
                }
            )
        case .units:
            OnboardingChoiceSheet(title: "What's your units?", options: [
                .init(label: "oz (ounces)") { settings.unit = .oz; advance() },
                .init(label: "ml (millilitres)") { settings.unit = .ml; advance() },
            ])
        case .firstWeekday:
            OnboardingChoiceSheet(title: "What's the first day of your week?", options: [
                .init(label: "Sunday") { settings.firstWeekday = 1; advance() },
                .init(label: "Monday") { settings.firstWeekday = 2; advance() },
            ])
        case .reminders:
            RemindersPitchStep(onEnable: enableReminders, onSkip: finish)
        }
    }

    private func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return finish() }
        go(to: next)
    }

    private func back() {
        guard let previous = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        go(to: previous)
    }

    private func go(to target: OnboardingStep) {
        goingBack = target.rawValue < step.rawValue
        withAnimation(.spring(duration: 0.4)) { step = target }
    }

    private func saveProfile() {
        settings.babyName = draft.babyName.trimmingCharacters(in: .whitespacesAndNewlines)
        settings.babyBirthDate = draft.birthDate
        settings.babyWeightKg = draft.weightKg
        settings.dailyGoalML = draft.goalML
    }

    private func enableReminders() async {
        settings.remindersEnabled = await ReminderScheduler.requestAuthorization()
        await ReminderScheduler.sync(with: settings)
        finish()
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.35)) { settings.hasOnboarded = true }
    }
}

enum OnboardingStep: Int, CaseIterable {
    case welcome, name, birthDate, weight, goal, units, firstWeekday, reminders

    /// Share of the profile questions answered, for the progress bar on question pages.
    var progress: Double { Double(rawValue) / Double(OnboardingStep.goal.rawValue) }
}

/// Profile answers collected before they are saved to `AppSettings` on the goal step.
struct OnboardingDraft {
    var babyName = ""
    var birthDate = Date.now
    var weightKg = 4.5
    /// Set by "SET CUSTOM"; nil means use the calculator's suggestion.
    var customGoalML: Double?

    init() {}

    init(settings: AppSettings) {
        babyName = settings.babyName
        birthDate = settings.babyBirthDate
        weightKg = settings.babyWeightKg
    }

    var ageMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
    }

    var suggestedGoalML: Double {
        GoalCalculator.dailyGoalML(weightKg: weightKg, ageMonths: ageMonths)
    }

    var goalML: Double { customGoalML ?? suggestedGoalML }

    /// "Mia", or "your baby" before a name is entered.
    var displayName: String {
        let name = babyName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "your baby" : name
    }
}

#Preview {
    OnboardingFlow()
        .environment(AppSettings(defaults: UserDefaults(suiteName: "OnboardingPreview")!))
}
