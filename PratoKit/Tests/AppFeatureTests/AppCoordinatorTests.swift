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

    private func makeCoordinator() -> AppCoordinator {
        AppCoordinator(analyzer: MockMealAnalyzer(delay: .zero), catalog: .development)
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
        #expect(coordinator.lastSavedMeal == nil)
    }

    @Test func savedMealIsKeptWhileTheFlowStaysOpen() throws {
        let coordinator = makeCoordinator()
        coordinator.select(.scan)
        let scan = try #require(coordinator.activeScan)
        let draft = MealDraft(kind: .lunch, portions: [], photo: nil, date: .now)

        scan.send(ScanEvent.mealSaved(draft))

        #expect(coordinator.lastSavedMeal == draft)
        #expect(coordinator.activeScan === scan)
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
