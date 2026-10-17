import Coordinator
import HomeFeature
import MealKit
import Observation
import ScanFeature

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

    /// The meal saved by the last scan. Temporary: replaced by persistence in a later PR.
    public private(set) var lastSavedMeal: MealDraft?

    @ObservationIgnored public private(set) lazy var homeViewModel = HomeViewModel { [weak self] event in
        self?.send(event)
    }

    private let analyzer: any MealAnalyzing
    private let catalog: FoodCatalog

    public init(
        analyzer: any MealAnalyzing = MockMealAnalyzer(),
        catalog: FoodCatalog = .development
    ) {
        self.analyzer = analyzer
        self.catalog = catalog
    }

    /// The scan flow on screen, if any.
    public var activeScan: ScanCoordinator? {
        guard case .scan(let scan) = router.fullScreenCover else { return nil }
        return scan
    }

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

        case let event as ScanEvent:
            switch event {
            case .finished(let draft):
                lastSavedMeal = draft
                closeScan()
            case .cancelled:
                closeScan()
            }
            return true

        default:
            return false
        }
    }

    private func startScan(from source: ScanSource) {
        guard activeScan == nil else { return }
        let scan = ScanCoordinator(source: source, analyzer: analyzer, catalog: catalog)
        addChild(scan)
        router.present(.scan(scan), style: .fullScreenCover)
    }

    private func closeScan() {
        if let scan = activeScan {
            childDidFinish(scan)
        }
        router.dismiss()
    }
}
