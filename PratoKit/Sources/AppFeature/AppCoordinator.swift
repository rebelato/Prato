import Coordinator
import HistoryFeature
import HomeFeature
import MealKit
import MealStore
import Observation
import ScanFeature
import os

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

    @ObservationIgnored public private(set) lazy var homeViewModel = HomeViewModel(store: store) { [weak self] event in
        self?.send(event)
    }

    @ObservationIgnored public private(set) lazy var historyViewModel = HistoryViewModel(store: store) { [weak self] event in
        self?.send(event)
    }

    private let analyzer: any MealAnalyzing
    private let catalog: FoodCatalog
    private let store: any MealStoring

    public init(
        analyzer: any MealAnalyzing = MockMealAnalyzer(),
        catalog: FoodCatalog = .development,
        store: any MealStoring
    ) {
        self.analyzer = analyzer
        self.catalog = catalog
        self.store = store
    }

    /// The app as it runs on a device: meals kept on disk.
    ///
    /// If the database can't be opened, the app still starts, keeping meals in memory
    /// for this session, rather than crashing at launch.
    public static func live() -> AppCoordinator {
        let store: any MealStoring
        do {
            store = try SwiftDataMealStore.make()
        } catch {
            Logger(subsystem: "com.rebelato.prato", category: "storage")
                .error("Could not open the meal database: \(error.localizedDescription, privacy: .public)")
            store = InMemoryMealStore()
        }
        return AppCoordinator(store: store)
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

        case let event as HistoryEvent:
            switch event {
            case .scanRequested:
                startScan(from: .camera)
            }
            return true

        case let event as ScanEvent:
            switch event {
            case .mealSaved:
                // Refresh both tabs while the confirmation is on screen, so they're ready when the flow closes.
                Task {
                    await homeViewModel.load()
                    await historyViewModel.load()
                }
            case .finished:
                selectedTab = .today
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
        let scan = ScanCoordinator(source: source, analyzer: analyzer, catalog: catalog, store: store)
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
