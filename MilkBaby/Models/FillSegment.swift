import SwiftUI

/// One coloured band of the capybara fill. `fraction` is the share of the daily goal (0...1+).
/// Bands stack bottom-up in array order, like Waterllama's per-drink layers.
struct FillSegment: Identifiable, Equatable {
    let id: String
    let color: Color
    let fraction: Double

    /// Builds bands from a day's feeds against the goal, one band per milk type.
    static func from(_ entries: [FeedEntry], goalML: Double) -> [FillSegment] {
        guard goalML > 0 else { return [] }
        return entries.totalsByType.map {
            FillSegment(id: $0.type.rawValue, color: $0.type.color, fraction: $0.ml / goalML)
        }
    }
}
