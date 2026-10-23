import SwiftUI
import SwiftData

@main
struct MilkBabyApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
        }
        .modelContainer(for: FeedEntry.self)
    }
}
