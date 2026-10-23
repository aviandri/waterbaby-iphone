import XCTest

/// Taps through the whole app from a clean state and saves a screenshot of every screen.
///
/// Each screenshot is attached to the test result as "NN-name". When the runner has `SCREENSHOT_DIR`
/// set (run xcodebuild with `TEST_RUNNER_SCREENSHOT_DIR=/some/path`), it is also written there as
/// "NN-name.png".
final class TapThroughTests: XCTestCase {
    private var app: XCUIApplication!
    private var shotNumber = 0

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Wipes UserDefaults and keeps feeds in memory, so the run starts at onboarding with no feeds.
        app.launchArguments = ["-uiTesting"]
    }

    func testTapThroughEveryScreen() throws {
        app.launch()

        // MARK: Splash (held for 3s under -uiTesting)
        let splash = app.staticTexts["Made with love"]
        if splash.waitForExistence(timeout: 3) {
            snapshot("splash", settleFor: 0.3)
        } else {
            // Don't fail the whole walk over a missed splash; keep the numbering stable.
            print("⚠️ Splash was gone before it could be captured")
            shotNumber += 1
        }
        waitForDisappearance(of: splash, step: "splash fades out")

        // MARK: Onboarding
        waitFor(app.buttons["Get started"], step: "welcome")
        snapshot("welcome")
        tapButton("Get started", step: "welcome")

        let nameField = app.textFields["babyNameField"]
        waitFor(nameField, step: "name")
        nameField.tap()
        nameField.typeText("Mia")
        snapshot("name")
        nameField.typeText("\n") // Return submits the name and moves on.

        waitFor(app.staticTexts["When was Mia born?"], step: "birth date")
        snapshot("birth-date")
        tapButton("Continue", step: "birth date")

        waitFor(app.staticTexts["How much does Mia weigh?"], step: "weight")
        for _ in 0..<5 { tapButton("Increase weight", step: "weight") } // 4.5 → 5.0 kg
        snapshot("weight")
        tapButton("Continue", step: "weight")

        waitFor(app.staticTexts["See how much Mia needs"], step: "goal calculator")
        snapshot("goal-calculator")
        tapButton("Continue", step: "goal calculator")

        waitFor(app.staticTexts["What's your units?"], step: "units")
        snapshot("units")
        tapButton("ml (millilitres)", step: "units")

        waitFor(app.staticTexts["What's the first day of your week?"], step: "first weekday")
        snapshot("first-weekday")
        tapButton("Monday", step: "first weekday")

        waitFor(app.staticTexts["Smart Reminders"], step: "reminders")
        snapshot("reminders")
        tapButton("Skip", step: "reminders") // Skipping avoids the system permission alert.

        // MARK: Home and logging
        waitFor(app.buttons["Settings"], step: "home (empty)")
        waitFor(app.staticTexts["Log the first feed"], step: "home (empty)")
        snapshot("home-empty")

        tapButton("Log Formula", step: "home carousel → formula")
        waitFor(app.buttons["+ Formula"], step: "add feed sheet (formula)")
        snapshot("add-feed-formula")
        tapButton("+ Formula", step: "add feed sheet (formula)")
        waitForHomeWithFeeds(step: "home after formula")
        snapshot("home-one-feed")

        logFeedAtDefaultAmount("Breast Milk")

        tapButton("Log Pumped Milk", step: "home carousel → pumped milk")
        waitFor(app.buttons["+ Pumped Milk"], step: "add feed sheet (pumped milk)")
        tapButton("Custom amount", step: "add feed sheet (pumped milk)")
        waitFor(app.buttons["Delete"], step: "custom amount keypad")
        tapButton("9", step: "custom amount keypad")
        tapButton("0", step: "custom amount keypad")
        snapshot("custom-amount-keypad")
        tapButton("customAmountAddButton", step: "custom amount keypad")
        waitForHomeWithFeeds(step: "home after pumped milk")
        snapshot("home-layered")

        // MARK: Day log
        let mascot = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Today's feeds")).firstMatch
        tap(mascot, step: "home → day log")
        waitFor(app.buttons["Add missed feed"], step: "day log")
        snapshot("day-log")
        tapButton("Close", step: "day log")
        waitForHomeWithFeeds(step: "home after day log")

        // MARK: History
        let streakBadge = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", "day streak")).firstMatch
        tap(streakBadge, step: "home → history")
        waitFor(app.buttons["Previous month"], step: "history")
        snapshot("history")
        tapButton("Close", step: "history")
        waitForHomeWithFeeds(step: "home after history")

        // MARK: Settings
        tapButton("Settings", step: "home → settings")
        waitFor(app.switches["Feed reminders"], step: "settings")
        snapshot("settings")
    }

    // MARK: - Steps

    private func logFeedAtDefaultAmount(_ typeName: String) {
        tapButton("Log \(typeName)", step: "home carousel → \(typeName)")
        waitFor(app.buttons["+ \(typeName)"], step: "add feed sheet (\(typeName))")
        tapButton("+ \(typeName)", step: "add feed sheet (\(typeName))")
        waitForHomeWithFeeds(step: "home after \(typeName)")
    }

    /// Home is showing (no sheet on top) and at least one feed is logged today.
    private func waitForHomeWithFeeds(step: String) {
        let summary = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Milk today")).firstMatch
        waitFor(summary, step: step)
        let settingsButton = app.buttons["Settings"]
        waitFor(settingsButton, step: step)
        if !wait(timeout: 5, until: { settingsButton.isHittable }) {
            XCTFail("[\(step)] home never became tappable (is a sheet still open?)")
        }
    }

    // MARK: - Helpers

    /// Taps the button whose accessibility label or identifier is `label`.
    private func tapButton(_ label: String, step: String, file: StaticString = #filePath, line: UInt = #line) {
        let matches = app.buttons.matching(identifier: label)
        guard waitFor(matches.firstMatch, step: step, file: file, line: line) else { return }
        // While a page slides out, its copy of the button (e.g. "Continue") can linger for a moment.
        _ = wait(timeout: 3, until: { matches.count == 1 })
        let button = matches.allElementsBoundByIndex.first(where: \.isHittable) ?? matches.firstMatch
        tap(button, step: "\(step) — tap '\(label)'", file: file, line: line)
    }

    private func tap(_ element: XCUIElement, step: String, file: StaticString = #filePath, line: UInt = #line) {
        guard waitFor(element, step: step, file: file, line: line) else { return }
        guard wait(timeout: 5, until: { element.isHittable }) else {
            XCTFail("[\(step)] \(element) exists but never became hittable", file: file, line: line)
            return
        }
        element.tap()
    }

    @discardableResult
    private func waitFor(
        _ element: XCUIElement,
        step: String,
        timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        if element.waitForExistence(timeout: timeout) { return true }
        XCTFail("[\(step)] timed out after \(Int(timeout))s waiting for \(element)", file: file, line: line)
        return false
    }

    private func waitForDisappearance(of element: XCUIElement, step: String, timeout: TimeInterval = 10) {
        if !wait(timeout: timeout, until: { !element.exists }) {
            XCTFail("[\(step)] \(element) was still on screen after \(Int(timeout))s")
        }
    }

    /// Polls `condition` until it holds or `timeout` passes. Returns whether it held.
    private func wait(timeout: TimeInterval, until condition: @escaping () -> Bool) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Gives transitions and springs a moment to finish, without `sleep()`.
    private func settle(for seconds: TimeInterval) {
        let neverFulfilled = XCTestExpectation(description: "Let animations settle")
        _ = XCTWaiter().wait(for: [neverFulfilled], timeout: seconds)
    }

    /// Captures the screen as attachment "NN-name" and, if SCREENSHOT_DIR is set, as NN-name.png there.
    private func snapshot(_ name: String, settleFor seconds: TimeInterval = 0.8) {
        settle(for: seconds)
        shotNumber += 1
        let fullName = (shotNumber < 10 ? "0" : "") + "\(shotNumber)-\(name)"
        let screenshot = XCUIScreen.main.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = fullName
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let dir = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !dir.isEmpty else { return }
        let folder = URL(fileURLWithPath: dir, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try screenshot.pngRepresentation.write(to: folder.appendingPathComponent("\(fullName).png"))
        } catch {
            // The attachment is still in the result bundle, so don't fail the walk over the file copy.
            print("⚠️ Couldn't write \(fullName).png to \(dir): \(error)")
        }
    }
}
