import SwiftUI
import SwiftData

/// One day's feeds: date title, "480ml milk · 69% of your goal", rows with a red minus to delete,
/// and "ADD MISSED FEED".
///
/// This is a plain, non-scrolling stack so `HistoryView` can embed it inside its own scroll view.
/// Use `DayLogSheet` for the standalone scrolling sheet with a close button.
struct DayLogView: View {
    let day: Date
    /// Hide the big date title when the host already shows the date (e.g. under a calendar).
    var showsTitle = true

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Query private var entries: [FeedEntry]
    @State private var showAddMissed = false

    init(day: Date, showsTitle: Bool = true) {
        self.day = day
        self.showsTitle = showsTitle
        let start = Calendar.current.startOfDay(for: day)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        _entries = Query(
            filter: #Predicate<FeedEntry> { $0.date >= start && $0.date < end },
            sort: \FeedEntry.date,
            order: .reverse
        )
    }

    private var totalML: Double { entries.totalML }

    private var percentOfGoal: Int {
        guard settings.dailyGoalML > 0 else { return 0 }
        return Int((totalML / settings.dailyGoalML * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 0) {
            if showsTitle {
                Text(day.formatted(.dateTime.month(.wide).day().year()))
                    .font(Theme.rounded(30))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
            }

            Text("\(settings.unit.format(totalML)) milk · \(percentOfGoal)% of your goal")
                .font(Theme.rounded(16, .bold))
                .foregroundStyle(Theme.accent)
                .padding(.bottom, 4)
            Text(feedCountText)
                .font(Theme.rounded(14, .semibold))
                .foregroundStyle(Theme.subtle)
                .padding(.bottom, 16)

            Divider()
            if entries.isEmpty {
                Text("No feeds logged")
                    .font(Theme.rounded(15, .semibold))
                    .foregroundStyle(Theme.subtle)
                    .padding(.vertical, 28)
                Divider()
            } else {
                ForEach(entries) { entry in
                    row(entry)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    Divider()
                }
            }

            Button("Add missed feed") { showAddMissed = true }
                .buttonStyle(SoftPillButtonStyle())
                .padding(.top, 28)
        }
        .animation(.snappy, value: entries.map(\.id))
        .sheet(isPresented: $showAddMissed) {
            AddMissedFeedSheet(day: day)
        }
    }

    private var feedCountText: String {
        entries.count == 1 ? "1 feed" : "\(entries.count) feeds"
    }

    private func row(_ entry: FeedEntry) -> some View {
        HStack(spacing: 12) {
            MilkTypeIcon(type: entry.type, size: 30)
            Text(entry.type.displayName)
                .font(Theme.rounded(15))
                .textCase(.uppercase)
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
            Spacer(minLength: 8)
            Text("\(entry.date.formatted(date: .omitted, time: .shortened)) · \(settings.unit.format(entry.amountML))")
                .font(Theme.rounded(15, .bold))
                .foregroundStyle(Theme.subtle)
                .monospacedDigit()
            Button {
                delete(entry)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Theme.danger)
                    .frame(width: 28, height: 28)
                    .background(Theme.danger.opacity(0.15), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(entry.type.displayName) feed")
        }
        .padding(.vertical, 14)
    }

    private func delete(_ entry: FeedEntry) {
        FeedHaptics.tap()
        withAnimation(.snappy) {
            modelContext.delete(entry)
        }
    }
}

/// Standalone sheet presentation of `DayLogView`, opened by tapping the mascot on the home screen.
struct DayLogSheet: View {
    let day: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            DayLogView(day: day)
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 32)
        }
        .overlay(alignment: .topTrailing) {
            CloseButton { dismiss() }
                .padding(16)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview("Day log sheet") {
    Color.white
        .sheet(isPresented: .constant(true)) {
            DayLogSheet(day: .now)
        }
        .modelContainer(FeedPreviewData.container())
        .environment(AppSettings())
}

#Preview("Embedded, empty") {
    ScrollView {
        DayLogView(day: .now, showsTitle: false)
            .padding(20)
    }
    .modelContainer(FeedPreviewData.container(todayFeeds: false))
    .environment(AppSettings())
}
