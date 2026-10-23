import SwiftUI

enum FeedStreak {
    /// Consecutive days, ending today, on which the goal was met. If today's goal isn't met yet,
    /// the streak counts back from yesterday so it doesn't reset to 0 every morning.
    static func current(
        entries: [FeedEntry],
        goalML: Double,
        today: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        guard goalML > 0 else { return 0 }
        var totals: [Date: Double] = [:]
        for entry in entries {
            totals[calendar.startOfDay(for: entry.date), default: 0] += entry.amountML
        }

        var day = calendar.startOfDay(for: today)
        if (totals[day] ?? 0) < goalML {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while (totals[day] ?? 0) >= goalML {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }
}

/// Top-left home badge: "3 days" capsule, or just the number when there is no streak.
struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("\(days)")
                .font(Theme.rounded(15))
                .foregroundStyle(.white)
                .frame(minWidth: 28, minHeight: 28)
                .background(Theme.accent, in: Circle())
                .contentTransition(.numericText())
            if days > 0 {
                Text(days == 1 ? "day" : "days")
                    .font(Theme.rounded(15, .bold))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.leading, 3)
        .padding(.trailing, days > 0 ? 12 : 3)
        .padding(.vertical, 3)
        .background(Theme.accent.opacity(0.15), in: Capsule())
        .animation(.snappy, value: days)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(days == 1 ? "1 day streak" : "\(days) day streak")
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakBadge(days: 0)
        StreakBadge(days: 1)
        StreakBadge(days: 12)
    }
}
