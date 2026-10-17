import Coordinator
import Foundation
import MealKit
import Testing
@testable import ScanFeature

/// Stands in for the app coordinator and records how the flow ended.
@MainActor
private final class ParentSpy: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []
    private(set) var events: [ScanEvent] = []

    func handle(_ event: any Event) -> Bool {
        guard let event = event as? ScanEvent else { return false }
        events.append(event)
        return true
    }
}

private struct FailingAnalyzer: MealAnalyzing {
    struct Failure: Error {}
    func analyze(photo: Data) async throws -> [FoodSuggestion] { throw Failure() }
}

@MainActor
struct ScanCoordinatorTests {

    private let photo = Data([0xFF, 0xD8, 0xFF])

    private func makeFlow(analyzer: any MealAnalyzing = MockMealAnalyzer(delay: .zero)) -> (ScanCoordinator, ParentSpy) {
        let parent = ParentSpy()
        let scan = ScanCoordinator(source: .camera, analyzer: analyzer, catalog: .development)
        parent.addChild(scan)
        return (scan, parent)
    }

    @Test func photoTakenShowsTheCheck() {
        let (scan, _) = makeFlow()

        scan.send(CaptureEvent.photoTaken(photo))

        #expect(scan.photo == photo)
        #expect(scan.router.path == [.confirm])
    }

    @Test func retakeGoesBackToTheCamera() {
        let (scan, _) = makeFlow()
        scan.send(CaptureEvent.photoTaken(photo))

        scan.send(PhotoConfirmEvent.retakeRequested)

        #expect(scan.router.path.isEmpty)
    }

    @Test func analysisReplacesItselfWithTheReview() async throws {
        let (scan, _) = makeFlow()
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)
        #expect(scan.router.path == [.confirm, .analyzing])

        let analyzing = try #require(scan.analyzingViewModel)
        await analyzing.analyze()

        #expect(scan.router.path == [.confirm, .review])
        #expect(scan.analyzingViewModel == nil)
        let review = try #require(scan.reviewViewModel)
        #expect(review.portions.map(\.food.id) == ["rice-white-cooked", "chicken-breast-grilled", "leaf-salad"])
        #expect(review.photo == photo)
    }

    @Test func failedAnalysisStaysAndCanContinueByHand() async throws {
        let (scan, _) = makeFlow(analyzer: FailingAnalyzer())
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)
        let analyzing = try #require(scan.analyzingViewModel)

        await analyzing.analyze()
        #expect(analyzing.state == .failed)
        #expect(scan.router.path == [.confirm, .analyzing])

        analyzing.continueWithoutAnalysisTapped()
        #expect(scan.router.path == [.confirm, .review])
        #expect(try #require(scan.reviewViewModel).portions.isEmpty)
    }

    @Test func lateAnalysisResultIsIgnoredAfterLeaving() async throws {
        let (scan, _) = makeFlow()
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)
        let analyzing = try #require(scan.analyzingViewModel)

        scan.router.pop()
        await analyzing.analyze()

        #expect(scan.router.path == [.confirm])
        #expect(scan.reviewViewModel == nil)
    }

    @Test func withoutPhotoGoesStraightToAnEmptyReview() throws {
        let (scan, _) = makeFlow()

        scan.send(CaptureEvent.skipPhotoRequested)

        #expect(scan.router.path == [.review])
        let review = try #require(scan.reviewViewModel)
        #expect(review.portions.isEmpty)
        #expect(review.photo == nil)
    }

    @Test func savingReportsTheMealAndShowsTheConfirmation() throws {
        let (scan, parent) = makeFlow()
        scan.send(CaptureEvent.skipPhotoRequested)
        let review = try #require(scan.reviewViewModel)
        review.addFoodTapped()
        review.apply(try #require(review.editor))

        review.saveTapped()

        guard case .mealSaved(let draft) = try #require(parent.events.first) else {
            Issue.record("Expected a mealSaved event")
            return
        }
        #expect(draft.portions.count == 1)
        #expect(scan.savedDraft == draft)
        #expect(scan.router.path == [.saved])
    }

    @Test func savingTwiceReportsOnce() throws {
        let (scan, parent) = makeFlow()
        scan.send(CaptureEvent.skipPhotoRequested)
        let review = try #require(scan.reviewViewModel)
        review.addFoodTapped()
        review.apply(try #require(review.editor))

        review.saveTapped()
        review.saveTapped()

        #expect(parent.events.count == 1)
    }

    @Test func doneOnTheConfirmationFinishesTheFlow() throws {
        let (scan, parent) = makeFlow()
        scan.send(CaptureEvent.skipPhotoRequested)
        let review = try #require(scan.reviewViewModel)
        review.addFoodTapped()
        review.apply(try #require(review.editor))
        review.saveTapped()

        scan.send(SavedEvent.doneTapped)

        guard case .finished? = parent.events.last else {
            Issue.record("Expected a finished event")
            return
        }
        #expect(parent.events.count == 2)
    }

    @Test func closeReportsCancelToTheParent() {
        let (scan, parent) = makeFlow()

        scan.captureViewModel.closeTapped()

        guard case .cancelled? = parent.events.first else {
            Issue.record("Expected a cancelled event")
            return
        }
    }
}
