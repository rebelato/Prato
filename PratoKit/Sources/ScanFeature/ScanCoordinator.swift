import Coordinator
import Foundation
import MealKit
import Observation

/// Owns the scan flow: camera → photo check → analysis → review → saved.
///
/// It reports how the flow ended with a ``ScanEvent`` sent to its parent, which closes it.
@MainActor
@Observable
public final class ScanCoordinator: Coordinator {

    @ObservationIgnored public weak var parentCoordinator: (any Coordinator)?
    @ObservationIgnored public var childCoordinators: [any Coordinator] = []

    public let router = Router<ScanRoute>()
    public let source: ScanSource

    /// JPEG of the plate once a photo was taken or picked.
    public private(set) var photo: Data?
    public private(set) var analyzingViewModel: AnalyzingViewModel?
    public private(set) var reviewViewModel: ReviewViewModel?
    /// The meal shown on the confirmation screen, once saved.
    public private(set) var savedDraft: MealDraft?

    @ObservationIgnored public private(set) lazy var captureViewModel = CaptureViewModel(source: source) { [weak self] event in
        self?.send(event)
    }

    private let analyzer: any MealAnalyzing
    private let catalog: FoodCatalog
    private let now: () -> Date

    public init(
        source: ScanSource,
        analyzer: any MealAnalyzing,
        catalog: FoodCatalog,
        now: @escaping () -> Date = Date.init
    ) {
        self.source = source
        self.analyzer = analyzer
        self.catalog = catalog
        self.now = now
    }

    public func handle(_ event: any Event) -> Bool {
        switch event {
        case let event as CaptureEvent:
            handle(event)
        case let event as PhotoConfirmEvent:
            handle(event)
        case let event as AnalyzingEvent:
            handle(event)
        case let event as ReviewEvent:
            handle(event)
        case let event as SavedEvent:
            handle(event)
        default:
            return false
        }
        return true
    }

    private func handle(_ event: CaptureEvent) {
        switch event {
        case .photoTaken(let jpeg):
            photo = jpeg
            router.path = [.confirm]
        case .skipPhotoRequested:
            photo = nil
            showReview(with: [])
        case .closeRequested:
            parentCoordinator?.send(ScanEvent.cancelled)
        }
    }

    private func handle(_ event: PhotoConfirmEvent) {
        switch event {
        case .analyzeRequested:
            guard let photo else { return }
            analyzingViewModel = AnalyzingViewModel(photo: photo, analyzer: analyzer) { [weak self] event in
                self?.send(event)
            }
            router.push(.analyzing)
        case .retakeRequested:
            router.popToRoot()
        }
    }

    private func handle(_ event: AnalyzingEvent) {
        // A late result from an analysis the user already left is ignored.
        guard router.path.last == .analyzing else { return }
        switch event {
        case .finished(let suggestions):
            showReview(with: suggestions)
        case .continueWithoutAnalysis:
            showReview(with: [])
        }
    }

    private func handle(_ event: ReviewEvent) {
        switch event {
        case .saveRequested(let draft):
            guard savedDraft == nil else { return }
            savedDraft = draft
            parentCoordinator?.send(ScanEvent.mealSaved(draft))
            // Replacing the whole stack leaves nothing to go back to: the meal can't be saved twice.
            router.path = [.saved]
        }
    }

    private func handle(_ event: SavedEvent) {
        switch event {
        case .doneTapped:
            parentCoordinator?.send(ScanEvent.finished)
        }
    }

    /// Replaces the analysis screen with the review, so going back from the review returns
    /// to the photo check instead of analyzing again.
    private func showReview(with suggestions: [FoodSuggestion]) {
        reviewViewModel = ReviewViewModel(
            suggestions: suggestions,
            photo: photo,
            catalog: catalog,
            date: now()
        ) { [weak self] event in
            self?.send(event)
        }
        analyzingViewModel = nil
        router.path = photo == nil ? [.review] : [.confirm, .review]
    }
}

extension ScanCoordinator: Hashable {

    /// Identity: two values are equal only if they are the same coordinator.
    public nonisolated static func == (lhs: ScanCoordinator, rhs: ScanCoordinator) -> Bool {
        lhs === rhs
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
