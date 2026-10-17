import Coordinator
import HomeFeature
import Observation

/// Root of the coordinator tree: owns the tab bar and what is presented over it.
@MainActor
@Observable
public final class AppCoordinator: Coordinator {

    @ObservationIgnored public weak var parentCoordinator: (any Coordinator)?
    @ObservationIgnored public var childCoordinators: [any Coordinator] = []

    /// The visible tab. Never `.scan`: that tab opens the scan flow instead.
    public private(set) var selectedTab: AppTab = .today

    /// Presentations over the tab bar.
    public let router = Router<AppRoute>()

    @ObservationIgnored public private(set) lazy var homeViewModel = HomeViewModel { [weak self] event in
        self?.send(event)
    }

    public init() {}

    /// Called by the tab bar. The scan tab starts a scan and keeps the current tab selected.
    public func select(_ tab: AppTab) {
        switch tab {
        case .scan:
            startScan(from: .camera)
        case .today, .history:
            selectedTab = tab
        }
    }

    public func handle(_ event: any Event) -> Bool {
        switch event {
        case let event as HomeEvent:
            switch event {
            case .scanRequested(let source):
                startScan(from: source)
            }
            return true

        case let event as ScanPlaceholderEvent:
            switch event {
            case .closeRequested:
                router.dismiss()
            }
            return true

        default:
            return false
        }
    }

    private func startScan(from source: ScanSource) {
        router.present(.scan(source), style: .fullScreenCover)
    }
}
