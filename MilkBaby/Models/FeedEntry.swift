import Foundation
import SwiftData

/// One logged feed. Amounts are always stored in millilitres; convert for display with `VolumeUnit`.
@Model
final class FeedEntry {
    var id: UUID
    var date: Date
    var amountML: Double
    var typeRaw: String
    var note: String?

    var type: MilkType {
        get { MilkType(rawValue: typeRaw) ?? .breastMilk }
        set { typeRaw = newValue.rawValue }
    }

    init(date: Date = .now, amountML: Double, type: MilkType, note: String? = nil) {
        self.id = UUID()
        self.date = date
        self.amountML = amountML
        self.typeRaw = type.rawValue
        self.note = note
    }
}

extension Array where Element == FeedEntry {
    /// Entries whose `date` falls on the same calendar day as `day`.
    func on(_ day: Date, calendar: Calendar = .current) -> [FeedEntry] {
        filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    var totalML: Double { reduce(0) { $0 + $1.amountML } }

    /// Total per milk type, in `MilkType.allCases` order, skipping types with no feeds.
    var totalsByType: [(type: MilkType, ml: Double)] {
        MilkType.allCases.compactMap { type in
            let ml = filter { $0.type == type }.totalML
            return ml > 0 ? (type, ml) : nil
        }
    }
}
