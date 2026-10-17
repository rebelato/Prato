import Coordinator
import Foundation
import HomeFeature
import MealKit
import ScanFeature
import Testing
@testable import AppFeature

private struct UnrelatedEvent: Event {}

@MainActor
struct AppCoordinatorTests {

    private func makeCoordinator(store: any MealStoring = InMemoryMealStore()) -> AppCoordinator {
        AppCoordinator(analyzer: MockMealAnalyzer(delay: .zero), catalog: .development, store: store)
    }

    @Test func startsOnTodayWithNothingPresented() {
        let coordinator = makeCoordinator()

        #expect(coordinator.selectedTab == .today)
        #expect(coordinator.activeScan == nil)
        #expect(coordinator.router.sheet == nil)
    }

    @Test func historyTabIsSelected() {
        let coordinator = makeCoordinator()

        coordinator.select(.history)

        #expect(coordinator.selectedTab == .history)
    }

    @Test func scanTabOpensCameraScanAndKeepsCurrentTab() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.history)

        coordinator.select(.scan)

        let scan = try #require(coordinator.activeScan)
        #expect(scan.source == .camera)
        #expect(coordinator.selectedTab == .history)
        #expect(coordinator.childCoordinators.count == 1)
        #expect(scan.parentCoordinator === coordinator)
    }

    @Test func homeGalleryButtonOpensGalleryScan() throws {
        let coordinator = makeCoordinator()

        coordinator.homeViewModel.galleryTapped()

        #expect(try #require(coordinator.activeScan).source == .gallery)
    }

    @Test func secondScanRequestKeepsTheOpenFlow() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.scan)
        let first = try #require(coordinator.activeScan)

        coordinator.homeViewModel.scanTapped()

        #expect(coordinator.activeScan === first)
        #expect(coordinator.childCoordinators.count == 1)
    }

    @Test func cancellingScanClosesTheFlow() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.scan)
        let scan = try #require(coordinator.activeScan)

        scan.send(ScanEvent.cancelled)

        #expect(coordinator.activeScan == nil)
        #expect(coordinator.childCoordinators.isEmpty)
    }

    @Test func savedMealKeepsTheFlowOpenOnTheConfirmation() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.scan)
        let scan = try #require(coordinator.activeScan)
        let meal = Meal(kind: .lunch, date: .now, portions: [], photo: nil)

        scan.send(ScanEvent.mealSaved(meal))

        #expect(coordinator.activeScan === scan)
    }

    @Test func homeShowsMealsFromTheSameStoreAsTheScan() async throws {
        let store = InMemoryMealStore()
        let coordinator = makeCoordinator(store: store)
        let rice = try #require(FoodCatalog.development.foods.first)
        let meal = try await store.save(MealDraft(kind: .lunch, portions: [FoodPortion(food: rice, grams: 100)], photo: nil, date: .now))

        await coordinator.homeViewModel.load()

        #expect(coordinator.homeViewModel.todayMeals == [meal])
    }

    @Test func finishingScanClosesTheFlowAndShowsToday() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.history)
        coordinator.select(.scan)
        let scan = try #require(coordinator.activeScan)

        scan.send(ScanEvent.finished)

        #expect(coordinator.activeScan == nil)
        #expect(coordinator.childCoordinators.isEmpty)
        #expect(coordinator.selectedTab == .today)
    }

    @Test func unrelatedEventsAreNotHandled() {
        let coordinator = makeCoordinator()

        #expect(coordinator.handle(UnrelatedEvent()) == false)
    }
}
