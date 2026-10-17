import Coordinator
import DesignSystem
import SwiftUI

/// The whole scan flow in its own navigation stack, driven by a ``ScanCoordinator``.
public struct ScanFlowView: View {

    private let coordinator: ScanCoordinator

    public init(coordinator: ScanCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        RouterStack(router: coordinator.router) {
            CaptureView(viewModel: coordinator.captureViewModel)
        } destination: { route in
            destination(for: route)
        }
        .tint(PratoColor.accent)
    }

    @ViewBuilder
    private func destination(for route: ScanRoute) -> some View {
        switch route {
        case .confirm:
            PhotoConfirmView(photo: coordinator.photo) { coordinator.send($0) }
        case .analyzing:
            if let viewModel = coordinator.analyzingViewModel {
                AnalyzingView(viewModel: viewModel)
            }
        case .review:
            if let viewModel = coordinator.reviewViewModel {
                ReviewView(viewModel: viewModel)
            }
        case .saved:
            if let draft = coordinator.savedDraft {
                SavedView(draft: draft) { coordinator.send($0) }
            }
        }
    }
}
