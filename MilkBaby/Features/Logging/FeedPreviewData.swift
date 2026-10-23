import Foundation
import SwiftData

/// In-memory SwiftData containers with sample feeds, for `#Preview`s.
@MainActor
enum FeedPreviewData {
    /// - Parameters:
    ///   - todayFeeds: whether to add a few feeds for today.
    ///   - goalMetDays: number of days before today that each reach a 700ml goal (gives a streak).
    static func container(todayFeeds: Bool = true, goalMetDays: Int = 3) -> ModelContainer {
        let container = try! ModelContainer(
            for: FeedEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        func time(_ dayOffset: Int, _ hour: Int, _ minute: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }

        if todayFeeds {
            context.insert(FeedEntry(date: time(0, 2, 10), amountML: 120, type: .breastMilk))
            context.insert(FeedEntry(date: time(0, 6, 35), amountML: 90, type: .pumpedMilk))
            context.insert(FeedEntry(date: time(0, 10, 5), amountML: 150, type: .formula))
            context.insert(FeedEntry(date: time(0, 13, 40), amountML: 120, type: .breastMilk))
        }

        for offset in stride(from: 1, through: goalMetDays, by: 1) {
            for (index, hour) in [1, 5, 9, 13, 17, 21].enumerated() {
                let type: MilkType = index.isMultiple(of: 2) ? .breastMilk : .formula
                context.insert(FeedEntry(date: time(offset, hour, 15), amountML: 120, type: type))
            }
        }
        return container
    }
}
