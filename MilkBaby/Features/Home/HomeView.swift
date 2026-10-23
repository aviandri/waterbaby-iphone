import Combine
import SwiftUI
import SwiftData

/// The main screen shown after onboarding: streak badge and menu, today's amount and % of goal,
/// the filling capybara, and the milk type carousel that opens `AddFeedSheet`.
struct HomeView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \FeedEntry.date, order: .reverse) private var entries: [FeedEntry]

    @State private var today = Date.now
    @State private var addingType: MilkType?
    @State private var showDayLog = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var confettiID: UUID?
    /// Start of the last day the goal celebration played, so it shows at most once a day.
    @AppStorage("lastGoalCelebrationDay") private var lastCelebrationDay: Double = 0

    private var todayEntries: [FeedEntry] { entries.on(today) }
    private var todayTotalML: Double { todayEntries.totalML }

    private var percentOfGoal: Int {
        guard settings.dailyGoalML > 0 else { return 0 }
        return Int((todayTotalML / settings.dailyGoalML * 100).rounded())
    }

    private var streak: Int {
        FeedStreak.current(entries: entries, goalML: settings.dailyGoalML, today: today)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: 6) {
                Text(settings.unit.format(todayTotalML))
                    .font(Theme.rounded(56))
                    .foregroundStyle(Theme.accent)
                    .contentTransition(.numericText(value: todayTotalML))
                Text(todayEntries.isEmpty ? "Log the first feed" : "Milk today · \(percentOfGoal)% of your goal")
                    .font(Theme.rounded(16, .bold))
                    .foregroundStyle(Theme.subtle)
            }
            .animation(.snappy, value: todayTotalML)
            .padding(.top, 8)

            Spacer(minLength: 16)

            Button {
                showDayLog = true
            } label: {
                MascotFillView(segments: FillSegment.from(todayEntries, goalML: settings.dailyGoalML))
                    .padding(.horizontal, 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Today's feeds, \(percentOfGoal)% of goal")
            .accessibilityHint("Shows today's feed log")

            Spacer(minLength: 16)

            MilkTypeCarousel { addingType = $0 }
                .padding(.bottom, 12)
        }
        .background(Color.white.ignoresSafeArea())
        .overlay {
            if let confettiID {
                ZStack {
                    GoalReachedOverlay {
                        withAnimation(.easeOut(duration: 0.25)) {
                            if self.confettiID == confettiID { self.confettiID = nil }
                        }
                    }
                    ConfettiView()
                }
                .id(confettiID)
                .transition(.opacity)
            }
        }
        .sheet(item: $addingType) { type in
            AddFeedSheet(type: type)
        }
        .sheet(isPresented: $showDayLog) {
            DayLogSheet(day: today)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: todayTotalML) { oldValue, newValue in
            celebrateIfGoalReached(from: oldValue, to: newValue)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { today = .now }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
            today = .now
        }
    }

    private var header: some View {
        HStack {
            Button {
                showHistory = true
            } label: {
                StreakBadge(days: streak)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens history")

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Theme.ink.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(Theme.silhouetteEmpty, in: Circle())
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func celebrateIfGoalReached(from oldValue: Double, to newValue: Double) {
        let goal = settings.dailyGoalML
        let dayKey = Calendar.current.startOfDay(for: today).timeIntervalSince1970
        guard goal > 0, oldValue < goal, newValue >= goal, lastCelebrationDay != dayKey else { return }
        lastCelebrationDay = dayKey
        confettiID = UUID()
        FeedHaptics.success()
    }
}

#Preview("Partly fed") {
    HomeView()
        .modelContainer(FeedPreviewData.container())
        .environment(AppSettings())
}

#Preview("Empty") {
    HomeView()
        .modelContainer(FeedPreviewData.container(todayFeeds: false, goalMetDays: 0))
        .environment(AppSettings())
}
