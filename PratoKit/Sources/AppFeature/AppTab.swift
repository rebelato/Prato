/// The tabs of the app's tab bar.
public enum AppTab: Hashable, Sendable {
    case today
    /// Not a screen: selecting it opens the scan flow over the current tab.
    case scan
    case history
}
