import Foundation
import Observation

/// User preferences and baby profile, persisted to UserDefaults. Injected via `.environment`.
@Observable
final class AppSettings {
    private let defaults: UserDefaults

    var hasOnboarded: Bool { didSet { defaults.set(hasOnboarded, forKey: "hasOnboarded") } }
    var babyName: String { didSet { defaults.set(babyName, forKey: "babyName") } }
    var babyBirthDate: Date { didSet { defaults.set(babyBirthDate, forKey: "babyBirthDate") } }
    var babyWeightKg: Double { didSet { defaults.set(babyWeightKg, forKey: "babyWeightKg") } }
    var dailyGoalML: Double { didSet { defaults.set(dailyGoalML, forKey: "dailyGoalML") } }
    var unit: VolumeUnit { didSet { defaults.set(unit.rawValue, forKey: "unit") } }
    /// 1 = Sunday, 2 = Monday (Calendar.firstWeekday convention).
    var firstWeekday: Int { didSet { defaults.set(firstWeekday, forKey: "firstWeekday") } }
    var remindersEnabled: Bool { didSet { defaults.set(remindersEnabled, forKey: "remindersEnabled") } }
    /// Hours between feed reminders.
    var reminderIntervalHours: Double { didSet { defaults.set(reminderIntervalHours, forKey: "reminderIntervalHours") } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasOnboarded = defaults.bool(forKey: "hasOnboarded")
        babyName = defaults.string(forKey: "babyName") ?? ""
        babyBirthDate = defaults.object(forKey: "babyBirthDate") as? Date ?? .now
        babyWeightKg = defaults.object(forKey: "babyWeightKg") as? Double ?? 4.5
        dailyGoalML = defaults.object(forKey: "dailyGoalML") as? Double ?? 700
        unit = VolumeUnit(rawValue: defaults.string(forKey: "unit") ?? "") ?? .ml
        firstWeekday = defaults.object(forKey: "firstWeekday") as? Int ?? 2
        remindersEnabled = defaults.bool(forKey: "remindersEnabled")
        reminderIntervalHours = defaults.object(forKey: "reminderIntervalHours") as? Double ?? 3
    }

    var babyAgeMonths: Int {
        Calendar.current.dateComponents([.month], from: babyBirthDate, to: .now).month ?? 0
    }

    var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = firstWeekday
        return cal
    }
}
