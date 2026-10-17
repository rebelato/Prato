import Testing
import MealKit
@testable import HomeFeature

@MainActor
struct HomeViewModelTests {

    @Test func scanButtonRequestsCameraScan() {
        var events: [HomeEvent] = []
        let viewModel = HomeViewModel { events.append($0) }

        viewModel.scanTapped()

        #expect(events == [.scanRequested(.camera)])
    }

    @Test func galleryButtonRequestsGalleryScan() {
        var events: [HomeEvent] = []
        let viewModel = HomeViewModel { events.append($0) }

        viewModel.galleryTapped()

        #expect(events == [.scanRequested(.gallery)])
    }
}
