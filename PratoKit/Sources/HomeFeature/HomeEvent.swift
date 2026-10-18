import Coordinator
import MealKit

/// What the user did on Hoje that someone else must act on.
public enum HomeEvent: Event, Equatable {
    /// "Escanear refeição" (camera) or "Escolher da galeria" (gallery).
    case scanRequested(ScanSource)
}
