import Coordinator
import HomeFeature
import Testing
@testable import AppFeature

private struct UnrelatedEvent: Event {}

@MainActor
struct AppCoordinatorTests {

    @Test func startsOnTodayWithNothingPresented() {
        let coordinator = AppCoordinator()

        #expect(coordinator.selectedTab == .today)
        #expect(coordinator.router.fullScreenCover == nil)
        #expect(coordinator.router.sheet == nil)
    }

    @Test func historyTabIsSelected() {
        let coordinator = AppCoordinator()

        coordinator.select(.history)

        #expect(coordinator.selectedTab == .history)
    }

    @Test func scanTabOpensCameraScanAndKeepsCurrentTab() {
        let coordinator = AppCoordinator()
        coordinator.select(.history)

        coordinator.select(.scan)

        #expect(coordinator.selectedTab == .history)
        #expect(coordinator.router.fullScreenCover == .scan(.camera))
    }

    @Test func homeButtonsOpenScanFromTheirSource() {
        let coordinator = AppCoordinator()

        coordinator.homeViewModel.galleryTapped()
        #expect(coordinator.router.fullScreenCover == .scan(.gallery))

        coordinator.router.dismiss()
        coordinator.homeViewModel.scanTapped()
        #expect(coordinator.router.fullScreenCover == .scan(.camera))
    }

    @Test func closingScanDismissesTheCover() {
        let coordinator = AppCoordinator()
        coordinator.select(.scan)

        coordinator.send(ScanPlaceholderEvent.closeRequested)

        #expect(coordinator.router.fullScreenCover == nil)
    }

    @Test func unrelatedEventsAreNotHandled() {
        let coordinator = AppCoordinator()

        #expect(coordinator.handle(UnrelatedEvent()) == false)
    }
}
