import Coordinator

/// Where the photo of a meal will come from.
public enum ScanSource: Hashable, Sendable {
    case camera
    case gallery
}

/// What the user did on Hoje that someone else must act on.
public enum HomeEvent: Event, Equatable {
    /// "Escanear refeição" (camera) or "Escolher da galeria" (gallery).
    case scanRequested(ScanSource)
}
