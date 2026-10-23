import XCTest

/// Choosing an amount in the add-feed sheet without tapping: swiping the amount picker and
/// dragging on the bottle must both change the amount that "+ Formula" would save.
final class AmountInputTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // "-key value" arguments land in UserDefaults' argument domain, which the -uiTesting wipe
        // doesn't touch, so this skips onboarding and starts on an empty home screen.
        app.launchArguments = ["-uiTesting", "-hasOnboarded", "YES"]
        app.launch()
    }

    func testSwipingAmountPickerSelectsWithoutTap() throws {
        openAddFormula()
        let bottle = bottleElement()
        let before = try XCTUnwrap(bottle.value as? String)

        let picker = app.descendants(matching: .any)["amountPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "amount picker not found")
        picker.swipeLeft()

        XCTAssertTrue(
            wait(timeout: 5) { (bottle.value as? String) != before },
            "Swiping the picker didn't change the amount (still \(before)); it shouldn't need a tap"
        )
        settle(for: 1.5) // let the fling come to rest
        let after = try XCTUnwrap(bottle.value as? String)
        XCTAssertNotEqual(after, before)

        // The highlighted picker item is the amount that will be saved.
        let selected = app.staticTexts.matching(NSPredicate(format: "selected == YES")).firstMatch
        XCTAssertTrue(selected.waitForExistence(timeout: 2), "no picker item is marked selected")
        XCTAssertEqual(selected.label, after)
    }

    func testDraggingUpOnBottleIncreasesAmount() throws {
        openAddFormula()
        let bottle = bottleElement()
        let before = try XCTUnwrap(millilitres(bottle))

        let start = bottle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85))
        let end = bottle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)

        XCTAssertTrue(
            wait(timeout: 5) { (self.millilitres(bottle) ?? 0) > before },
            "Dragging up on the bottle didn't increase the amount from \(Int(before))ml"
        )

        // The picker follows the bottle.
        settle(for: 1)
        let selected = app.staticTexts.matching(NSPredicate(format: "selected == YES")).firstMatch
        XCTAssertTrue(selected.waitForExistence(timeout: 2), "no picker item is marked selected")
        XCTAssertEqual(selected.label, bottle.value as? String)
    }

    // MARK: - Helpers

    private func openAddFormula() {
        // The splash sits on top of the already-built home screen for 3 s under -uiTesting, and
        // XCUITest reports the buttons beneath it as hittable, so a tap before it fades is lost.
        let splash = app.staticTexts["Made with love"]
        if splash.waitForExistence(timeout: 3) {
            XCTAssertTrue(wait(timeout: 10) { !splash.exists }, "splash never went away")
        }
        let logFormula = app.buttons["Log Formula"]
        XCTAssertTrue(logFormula.waitForExistence(timeout: 10), "home carousel not shown")
        XCTAssertTrue(wait(timeout: 5) { logFormula.isHittable }, "home carousel never became tappable")
        logFormula.tap()
        let add = app.buttons.matching(NSPredicate(format: "label ==[c] %@", "+ Formula")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 5), "add feed sheet didn't open")
        settle(for: 0.8) // sheet animation and the picker's initial centring
    }

    private func bottleElement() -> XCUIElement {
        let bottle = app.descendants(matching: .any)["bottle"]
        XCTAssertTrue(bottle.waitForExistence(timeout: 5), "bottle not found")
        return bottle
    }

    /// The bottle's accessibility value ("150ml") as a number. The tests run in ml (the default unit).
    private func millilitres(_ bottle: XCUIElement) -> Double? {
        guard let value = bottle.value as? String else { return nil }
        return Double(value.filter { $0.isNumber || $0 == "." })
    }

    private func wait(timeout: TimeInterval, until condition: @escaping () -> Bool) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    private func settle(for seconds: TimeInterval) {
        let neverFulfilled = XCTestExpectation(description: "Let animations settle")
        _ = XCTWaiter().wait(for: [neverFulfilled], timeout: seconds)
    }
}
