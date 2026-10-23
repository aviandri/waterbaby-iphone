import Foundation

enum VolumeUnit: String, Codable, CaseIterable, Identifiable {
    case ml
    case oz

    var id: String { rawValue }
    static let mlPerOz = 29.5735

    func fromML(_ ml: Double) -> Double { self == .ml ? ml : ml / Self.mlPerOz }
    func toML(_ value: Double) -> Double { self == .ml ? value : value * Self.mlPerOz }

    /// "120ml" or "4.1oz", matching Waterllama's compact amount style.
    func format(_ ml: Double) -> String {
        switch self {
        case .ml: "\(Int(ml.rounded()))ml"
        case .oz: String(format: "%.1foz", fromML(ml))
        }
    }
}
