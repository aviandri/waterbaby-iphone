import XCTest
@testable import MilkBaby

final class GoalCalculatorTests: XCTestCase {
    func testNewbornUses150mlPerKg() {
        XCTAssertEqual(GoalCalculator.dailyGoalML(weightKg: 4, ageMonths: 1), 600)
    }

    func testOlderBabyUses120mlPerKg() {
        XCTAssertEqual(GoalCalculator.dailyGoalML(weightKg: 8, ageMonths: 7), 960)
        XCTAssertEqual(GoalCalculator.dailyGoalML(weightKg: 7, ageMonths: 7), 840)
    }

    func testGoalIsCapped() {
        XCTAssertEqual(GoalCalculator.dailyGoalML(weightKg: 12, ageMonths: 3), 960)
    }

    func testOuncesRoundTrip() {
        XCTAssertEqual(VolumeUnit.oz.toML(VolumeUnit.oz.fromML(120)), 120, accuracy: 0.001)
    }
}
