import ScanFeature

/// What the app presents over the tab bar.
public enum AppRoute: Hashable, Sendable {
    /// The scan flow, shown as a full-screen cover. Carries its coordinator so the flow
    /// stays on screen through the dismiss animation.
    case scan(ScanCoordinator)
}
