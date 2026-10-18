import Coordinator
import DesignSystem
import HistoryFeature
import HomeFeature
import ScanFeature
import SwiftUI

/// The tab bar (Hoje, Escanear, Histórico) and whatever the app coordinator presents over it.
public struct AppRootView: View {

    private let coordinator: AppCoordinator

    /// The tab the `TabView` shows. It follows `coordinator.selectedTab`, except that it really
    /// becomes `.scan` while the scan flow is open and goes back when the flow closes. If the
    /// binding just refused `.scan`, the value would never change, the tab bar would keep the
    /// empty scan tab selected, and closing the flow would show a blank screen.
    @State private var shownTab: AppTab = .today

    public init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        TabView(selection: $shownTab) {
            HomeView(viewModel: coordinator.homeViewModel)
                .tabItem { Label(L10n.Tab.today, systemImage: "house") }
                .tag(AppTab.today)

            // Placeholder content: selecting this tab opens the scan flow, which covers it.
            Color.clear
                .tabItem {
                    Label {
                        Text(L10n.Tab.scan)
                    } icon: {
                        PratoImage.scanTabIcon
                    }
                }
                .tag(AppTab.scan)

            HistoryView(viewModel: coordinator.historyViewModel)
                .tabItem { Label(L10n.Tab.history, systemImage: "clock") }
                .tag(AppTab.history)
        }
        .tint(PratoColor.accent)
        .onAppear { shownTab = coordinator.selectedTab }
        .onChange(of: shownTab) { _, tab in
            guard tab != coordinator.selectedTab else { return }
            coordinator.select(tab)
            // The scan tab stays selected only while the flow is on screen.
            if tab == .scan, coordinator.activeScan == nil {
                shownTab = coordinator.selectedTab
            }
        }
        .onChange(of: coordinator.selectedTab) { _, tab in
            shownTab = tab
        }
        .onChange(of: coordinator.activeScan == nil) { _, isClosed in
            if isClosed {
                shownTab = coordinator.selectedTab
            }
        }
        .presentations(of: coordinator.router) { route in
            switch route {
            case .scan(let scan):
                ScanFlowView(coordinator: scan)
            }
        }
    }
}
