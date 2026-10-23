import SwiftUI

// PLACEHOLDER added by the onboarding/history branch so HistoryView compiles.
// OWNER: home session — replace with the real DayLogView at merge.
struct DayLogView: View {
    var day: Date

    var body: some View {
        Text(day.formatted(date: .long, time: .omitted))
    }
}
