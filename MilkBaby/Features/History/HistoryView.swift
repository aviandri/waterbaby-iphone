import SwiftUI
import SwiftData

// OWNER: onboarding/history session. Contract: presented as a sheet from HomeView's top-left streak badge.
/// Big % ring for the selected day, a month calendar of goal-met days, and that day's log below.
struct HistoryView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FeedEntry.date) private var entries: [FeedEntry]

    @State private var selectedDay = Calendar.current.startOfDay(for: .now)
    @State private var displayedMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now

    var body: some View {
        let calendar = settings.calendar
        let totals = dailyTotals(calendar: calendar)

        ScrollView {
            VStack(spacing: 28) {
                PercentRing(
                    fraction: fraction(totals[calendar.startOfDay(for: selectedDay)] ?? 0),
                    caption: ringCaption(calendar: calendar)
                )
                .frame(width: 250, height: 250)
                .padding(.top, 56)

                MonthCalendar(
                    month: $displayedMonth,
                    selectedDay: $selectedDay,
                    calendar: calendar,
                    status: { status(of: $0, totals: totals, calendar: calendar) }
                )
                .padding(.horizontal, 12)

                DayLogView(day: selectedDay)
            }
            .padding(.bottom, 32)
        }
        .background(Color.white.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            CloseButton { dismiss() }
                .padding(16)
        }
    }

    /// Millilitres logged per day, keyed by start of day.
    private func dailyTotals(calendar: Calendar) -> [Date: Double] {
        entries.reduce(into: [:]) { totals, entry in
            totals[calendar.startOfDay(for: entry.date), default: 0] += entry.amountML
        }
    }

    private func fraction(_ ml: Double) -> Double {
        settings.dailyGoalML > 0 ? ml / settings.dailyGoalML : 0
    }

    private func status(of day: Date, totals: [Date: Double], calendar: Calendar) -> DayStatus {
        let start = calendar.startOfDay(for: day)
        if start > calendar.startOfDay(for: .now) { return .future }
        let ml = totals[start] ?? 0
        if ml <= 0 { return .empty }
        return fraction(ml) >= 1 ? .goalMet : .partial
    }

    private func ringCaption(calendar: Calendar) -> String {
        if calendar.isDateInToday(selectedDay) { return "Today's milk" }
        if calendar.isDateInYesterday(selectedDay) { return "Yesterday's milk" }
        return "Milk on " + selectedDay.formatted(.dateTime.month(.abbreviated).day())
    }
}

enum DayStatus {
    case future, empty, partial, goalMet
}

/// Filled circle with a progress arc around it, like Waterllama's "TODAY'S HYDRATION" ring.
/// Turns fully peach once the goal is reached.
struct PercentRing: View {
    let fraction: Double
    let caption: String

    private var met: Bool { fraction >= 1 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.accent.opacity(0.2), lineWidth: 18)
                .padding(9)
            Circle()
                .trim(from: 0, to: min(fraction, 1))
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(9)
            Circle()
                .fill(met ? Theme.accent : Theme.capybaraBrown)
                .padding(met ? 0 : 24)

            VStack(spacing: 4) {
                Text(verbatim: "\(Int((fraction * 100).rounded()))%")
                    .font(Theme.rounded(64))
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(caption)
                    .font(Theme.capsLabel)
                    .textCase(.uppercase)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
        }
        .animation(.spring(duration: 0.5), value: fraction)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(caption): \(Int((fraction * 100).rounded())) percent of goal")
    }
}

#Preview {
    let container = try! ModelContainer(
        for: FeedEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let calendar = Calendar.current
    let amounts: [Double] = [720, 0, 410, 760, 800, 120, 0, 700, 300]
    for (offset, ml) in amounts.enumerated() where ml > 0 {
        let day = calendar.date(byAdding: .day, value: -offset, to: .now)!
        container.mainContext.insert(FeedEntry(date: day, amountML: ml, type: .formula))
    }
    return HistoryView()
        .environment(AppSettings(defaults: UserDefaults(suiteName: "HistoryPreview")!))
        .modelContainer(container)
}
