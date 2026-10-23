import SwiftUI

/// The kinds of feed a parent can log. Plays the role of Waterllama's drink types.
enum MilkType: String, Codable, CaseIterable, Identifiable {
    case breastMilk
    case pumpedMilk
    case formula
    case wholeMilk

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breastMilk: "Breast Milk"
        case .pumpedMilk: "Pumped Milk"
        case .formula: "Formula"
        case .wholeMilk: "Whole Milk"
        }
    }

    /// Colour used for this type's band in the capybara fill, its icon and its log row.
    var color: Color {
        switch self {
        case .breastMilk: Theme.milkCream
        case .pumpedMilk: Theme.milkPeach
        case .formula: Theme.milkButter
        case .wholeMilk: Theme.milkSky
        }
    }

    var symbolName: String {
        switch self {
        case .breastMilk: "heart.fill"
        case .pumpedMilk: "drop.fill"
        case .formula: "takeoutbag.and.cup.and.straw.fill"
        case .wholeMilk: "mug.fill"
        }
    }

    /// Quick-add presets in millilitres, shown in the add-feed sheet's amount carousel.
    var presetsML: [Double] {
        switch self {
        case .breastMilk, .pumpedMilk: [30, 60, 90, 120, 150]
        case .formula: [60, 90, 120, 150, 180, 240]
        case .wholeMilk: [100, 150, 200, 250]
        }
    }
}
