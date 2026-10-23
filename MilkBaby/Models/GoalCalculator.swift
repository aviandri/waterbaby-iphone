import Foundation

/// Suggested daily milk goal from the baby's age and weight.
///
/// Rule of thumb used by paediatric feeding guides: about 150 ml per kg per day for the first
/// six months, tapering to ~120 ml/kg after six months as solids are introduced, capped at
/// roughly 960 ml (32 oz). The app always lets parents override this; it is not medical advice.
enum GoalCalculator {
    static let maxDailyML: Double = 960

    static func dailyGoalML(weightKg: Double, ageMonths: Int) -> Double {
        let perKg: Double = ageMonths < 6 ? 150 : 120
        let raw = min(weightKg * perKg, maxDailyML)
        return (raw / 10).rounded() * 10
    }
}
