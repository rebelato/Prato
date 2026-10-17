import Coordinator
import HomeFeature

/// What the app presents over the tab bar.
public enum AppRoute: Hashable, Sendable {
    /// The scan flow, shown as a full-screen cover.
    case scan(ScanSource)
}

/// Events from the temporary scan screen. Replaced when the real scan flow lands.
enum ScanPlaceholderEvent: Event {
    case closeRequested
}
