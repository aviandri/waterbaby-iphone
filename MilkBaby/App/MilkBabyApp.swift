import SwiftUI
import SwiftData

@main
struct MilkBabyApp: App {
    /// UI tests launch with "-uiTesting" so every run starts at onboarding with no feeds:
    /// the app's UserDefaults are wiped before `AppSettings` reads them, and feeds live in memory only.
    static let isUITesting = CommandLine.arguments.contains("-uiTesting")

    @State private var settings: AppSettings = {
        if MilkBabyApp.isUITesting, let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        return AppSettings()
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
        }
        .modelContainer(for: FeedEntry.self, inMemory: Self.isUITesting)
    }
}
