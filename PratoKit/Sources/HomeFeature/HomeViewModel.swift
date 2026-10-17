import Observation

/// State and actions of Hoje.
///
/// It never navigates: taps become ``HomeEvent``s sent through `onEvent`,
/// and the coordinator decides what to show.
@MainActor
@Observable
public final class HomeViewModel {

    @ObservationIgnored private let onEvent: @MainActor (HomeEvent) -> Void

    public init(onEvent: @escaping @MainActor (HomeEvent) -> Void) {
        self.onEvent = onEvent
    }

    public func scanTapped() {
        onEvent(.scanRequested(.camera))
    }

    public func galleryTapped() {
        onEvent(.scanRequested(.gallery))
    }
}
