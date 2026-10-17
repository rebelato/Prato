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
    var error: any Error = Failure()
    var sendsPhotoToCloud: Bool { true }
    func analyze(photo: Data) async throws -> MealAnalysis { throw error }
}

/// Counts calls, to prove the photo is sent once.
private actor CountingAnalyzer: MealAnalyzing {
    private(set) var calls = 0
    nonisolated var sendsPhotoToCloud: Bool { true }
    func analyze(photo: Data) async throws -> MealAnalysis {
        calls += 1
        try await Task.sleep(for: .milliseconds(50))
        return MealAnalysis(suggestions: [FoodSuggestion(foodID: "rice-white-cooked", grams: 100)])
    }
}

struct FailingStore: MealStoring {
    struct Failure: Error {}
    func save(_ draft: MealDraft) async throws -> Meal { throw Failure() }
    func meals(in interval: DateInterval) async throws -> [Meal] { throw Failure() }
}

@MainActor
struct ScanCoordinatorTests {

    private let photo = Data([0xFF, 0xD8, 0xFF])

    private func makeFlow(
        analyzer: any MealAnalyzing = MockMealAnalyzer(delay: .zero),
        store: any MealStoring = InMemoryMealStore()
    ) -> (ScanCoordinator, ParentSpy) {
        let parent = ParentSpy()
        let scan = ScanCoordinator(source: .camera, analyzer: analyzer, catalog: .development, store: store)
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

    @Test func noFoodOffersRetakeThatReturnsToTheCamera() async throws {
        let (scan, _) = makeFlow(analyzer: FailingAnalyzer(error: MealAnalysisError.noFoodFound))
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)
        let analyzing = try #require(scan.analyzingViewModel)

        await analyzing.analyze()
        #expect(analyzing.state == .noFood)

        analyzing.retakeTapped()
        #expect(scan.router.path.isEmpty)
        #expect(scan.analyzingViewModel == nil)
    }

    @Test func unmatchedFoodsReachTheReview() async throws {
        let unmatched = UnmatchedFood(name: "Farofa", preparation: nil, estimatedGrams: 40, alternatives: [])
        let (scan, _) = makeFlow(analyzer: MockMealAnalyzer(delay: .zero, unmatched: [unmatched]))
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)

        await scan.analyzingViewModel?.analyze()

        #expect(try #require(scan.reviewViewModel).unmatched == [unmatched])
    }

    @Test func overlappingAnalyzeCallsSendThePhotoOnce() async throws {
        let analyzer = CountingAnalyzer()
        let (scan, _) = makeFlow(analyzer: analyzer)
        scan.send(CaptureEvent.photoTaken(photo))
        scan.send(PhotoConfirmEvent.analyzeRequested)
        let analyzing = try #require(scan.analyzingViewModel)

        async let first: Void = analyzing.analyze()
        async let second: Void = analyzing.analyze()
        _ = await (first, second)

        #expect(await analyzer.calls == 1)
    }

    @Test func cloudNoticeFollowsTheAnalyzer() {
        #expect(makeFlow(analyzer: FailingAnalyzer()).0.sendsPhotoToCloud)
        #expect(!makeFlow(analyzer: MockMealAnalyzer()).0.sendsPhotoToCloud)
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

    /// Opens an empty review and adds one food, ready to save.
    private func reviewWithOneFood(_ scan: ScanCoordinator) throws -> ReviewViewModel {
        scan.send(CaptureEvent.skipPhotoRequested)
        let review = try #require(scan.reviewViewModel)
        review.addFoodTapped()
        review.apply(try #require(review.editor))
        return review
    }

    @Test func savingStoresTheMealAndShowsTheConfirmation() async throws {
        let store = InMemoryMealStore()
        let (scan, parent) = makeFlow(store: store)
        let review = try reviewWithOneFood(scan)

        await review.saveTapped()

        guard case .mealSaved(let meal) = try #require(parent.events.first) else {
            Issue.record("Expected a mealSaved event")
            return
        }
        #expect(meal.portions.count == 1)
        #expect(scan.savedMeal == meal)
        #expect(scan.router.path == [.saved])
        let stored = try await store.meals(in: DateInterval(start: .distantPast, end: .distantFuture))
        #expect(stored == [meal])
    }

    @Test func savingTwiceStoresOnce() async throws {
        let store = InMemoryMealStore()
        let (scan, parent) = makeFlow(store: store)
        let review = try reviewWithOneFood(scan)

        await review.saveTapped()
        await review.saveTapped()

        #expect(parent.events.count == 1)
        #expect(try await store.meals(in: DateInterval(start: .distantPast, end: .distantFuture)).count == 1)
    }

    @Test func failedSaveStaysOnTheReview() async throws {
        let (scan, parent) = makeFlow(store: FailingStore())
        let review = try reviewWithOneFood(scan)

        await review.saveTapped()

        #expect(review.showsSaveError)
        #expect(review.canSave)
        #expect(parent.events.isEmpty)
        #expect(scan.router.path == [.review])
    }

    @Test func doneOnTheConfirmationFinishesTheFlow() async throws {
        let (scan, parent) = makeFlow()
        let review = try reviewWithOneFood(scan)
        await review.saveTapped()

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
