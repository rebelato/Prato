import AppFeature
import SwiftUI

@main
struct PratoApp: App {

    @State private var coordinator = AppCoordinator.live()

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
        }
    }
}
