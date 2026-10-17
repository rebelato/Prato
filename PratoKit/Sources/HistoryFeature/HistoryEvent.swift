import Coordinator

/// What the user did on Histórico that someone else must act on.
public enum HistoryEvent: Event, Equatable {
    /// "Escanear refeição" on an empty week.
    case scanRequested
}
