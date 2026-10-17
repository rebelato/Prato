import Coordinator
import DesignSystem
import HomeFeature
import ScanFeature
import SwiftUI

/// The tab bar (Hoje, Escanear, Histórico) and whatever the app coordinator presents over it.
public struct AppRootView: View {

    private let coordinator: AppCoordinator

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        TabView(selection: tabSelection) {
            HomeView(viewModel: coordinator.homeViewModel)
                .tabItem { Label(L10n.Tab.today, systemImage: "house") }
                .tag(AppTab.today)

            // Placeholder content: selecting this tab opens the scan flow and never shows it.
            Color.clear
                .tabItem { Label(L10n.Tab.scan, systemImage: "viewfinder") }
                .tag(AppTab.scan)

            HistoryPlaceholderView()
                .tabItem { Label(L10n.Tab.history, systemImage: "clock") }
                .tag(AppTab.history)
        }
        .tint(PratoColor.accent)
        .presentations(of: coordinator.router) { route in
            switch route {
            case .scan(let scan):
                ScanFlowView(coordinator: scan)
            }
        }
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { coordinator.selectedTab },
            set: { coordinator.select($0) }
        )
    }
}
