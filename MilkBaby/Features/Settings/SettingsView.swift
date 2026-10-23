import SwiftUI
import SwiftData
import UIKit

// OWNER: onboarding/history session. Contract: presented as a sheet from HomeView's top-right menu button.
/// Baby profile, daily goal, unit, first weekday, reminders and data reset.
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @State private var confirmingReset = false
    @State private var showingNotificationsDenied = false

    private static let reminderIntervals: [Double] = [1.5, 2, 2.5, 3, 3.5, 4, 5, 6]

    private var suggestedGoalML: Double {
        GoalCalculator.dailyGoalML(weightKg: settings.babyWeightKg, ageMonths: settings.babyAgeMonths)
    }

    /// Daily goal in the user's unit, stored back in ml.
    private var goalInUnit: Binding<Double> {
        Binding(
            get: { settings.unit.fromML(settings.dailyGoalML) },
            set: { settings.dailyGoalML = settings.unit.toML($0) }
        )
    }

    private var goalRange: ClosedRange<Double> { settings.unit == .ml ? 200...1500 : 7...50 }
    private var goalStep: Double { settings.unit == .ml ? 10 : 0.5 }

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            Form {
                Section("Baby") {
                    LabeledContent("Name") {
                        TextField("Name", text: $settings.babyName)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }
                    DatePicker("Birth date", selection: $settings.babyBirthDate, in: ...Date.now, displayedComponents: .date)
                    Stepper(value: $settings.babyWeightKg, in: 1.5...25, step: 0.1) {
                        LabeledContent("Weight", value: String(format: "%.1f kg", settings.babyWeightKg))
                    }
                }

                Section {
                    Stepper(value: goalInUnit, in: goalRange, step: goalStep) {
                        LabeledContent("Daily goal", value: settings.unit.format(settings.dailyGoalML))
                    }
                    if abs(suggestedGoalML - settings.dailyGoalML) >= 1 {
                        Button("Use suggested goal (\(settings.unit.format(suggestedGoalML)))") {
                            settings.dailyGoalML = suggestedGoalML
                        }
                        .foregroundStyle(Theme.accent)
                    }
                } header: {
                    Text("Daily goal")
                } footer: {
                    Text("Suggested from age and weight: about 150 ml per kg a day under six months, 120 ml per kg after. A rule of thumb, not medical advice.")
                }

                Section("Display") {
                    Picker("Units", selection: $settings.unit) {
                        Text("Millilitres (ml)").tag(VolumeUnit.ml)
                        Text("Ounces (oz)").tag(VolumeUnit.oz)
                    }
                    Picker("Week starts on", selection: $settings.firstWeekday) {
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                    }
                }

                Section {
                    Toggle("Feed reminders", isOn: $settings.remindersEnabled)
                        .tint(Theme.accent)
                    if settings.remindersEnabled {
                        Picker("Remind every", selection: $settings.reminderIntervalHours) {
                            ForEach(Self.reminderIntervals, id: \.self) { hours in
                                Text("\(hours.formatted()) hours").tag(hours)
                            }
                        }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("A gentle nudge if no feed has been logged for a while.")
                }

                Section {
                    Button("Delete all feeds", role: .destructive) { confirmingReset = true }
                } header: {
                    Text("Data")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton { dismiss() }
                }
            }
            .confirmationDialog("Delete every logged feed?", isPresented: $confirmingReset, titleVisibility: .visible) {
                Button("Delete all feeds", role: .destructive, action: deleteAllFeeds)
            } message: {
                Text("Your streak and history will be cleared. This can't be undone.")
            }
            .alert("Notifications are off", isPresented: $showingNotificationsDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                Button("Not now", role: .cancel) {}
            } message: {
                Text("Allow notifications for MilkBaby in the Settings app to get feed reminders.")
            }
        }
        .onChange(of: settings.remindersEnabled) { _, enabled in
            guard enabled else {
                ReminderScheduler.cancel()
                return
            }
            Task {
                guard await ReminderScheduler.requestAuthorization() else {
                    settings.remindersEnabled = false
                    showingNotificationsDenied = true
                    return
                }
                await ReminderScheduler.sync(with: settings)
            }
        }
        .onChange(of: settings.reminderIntervalHours) {
            Task { await ReminderScheduler.sync(with: settings) }
        }
        .onDisappear {
            // Picks up a renamed baby in the reminder text.
            Task { await ReminderScheduler.sync(with: settings) }
        }
    }

    private func deleteAllFeeds() {
        let entries = (try? modelContext.fetch(FetchDescriptor<FeedEntry>())) ?? []
        for entry in entries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings(defaults: UserDefaults(suiteName: "SettingsPreview")!))
        .modelContainer(for: FeedEntry.self, inMemory: true)
}
