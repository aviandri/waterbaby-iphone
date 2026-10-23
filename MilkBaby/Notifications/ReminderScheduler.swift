import Foundation
import UserNotifications

/// Schedules the repeating "time for a feed" reminder through `UNUserNotificationCenter`.
///
/// There is a single pending request that repeats every `reminderIntervalHours`. Its timer starts
/// when it is scheduled, so calling `sync(with:)` right after a feed is logged turns it into
/// "remind me N hours after the last feed".
enum ReminderScheduler {
    static let requestID = "milkbaby.feed-reminder"

    private static var center: UNUserNotificationCenter { .current() }

    /// Asks for permission if it hasn't been asked yet. Returns whether reminders can be shown.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    /// Replaces any pending reminder with one that repeats every `hours`.
    static func schedule(everyHours hours: Double, babyName: String) async {
        cancel()

        let content = UNMutableNotificationContent()
        content.title = babyName.isEmpty ? "Time for a feed?" : "Time for \(babyName)'s feed?"
        content.body = "Log it in MilkBaby and watch the capybara fill up 🍼"
        content.sound = .default

        // Repeating time-interval triggers must be at least 60 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(hours * 3600, 60), repeats: true)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
    }

    /// Brings the pending reminder in line with `settings`: reschedules it if reminders are on,
    /// removes it otherwise. Safe to call often.
    static func sync(with settings: AppSettings) async {
        guard settings.remindersEnabled else {
            cancel()
            return
        }
        await schedule(everyHours: settings.reminderIntervalHours, babyName: settings.babyName)
    }
}
