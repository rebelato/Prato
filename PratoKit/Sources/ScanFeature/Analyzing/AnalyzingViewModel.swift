import Foundation
import MealKit
import Observation

/// Runs the analysis of the photo and reports the suggestions.
@MainActor
@Observable
public final class AnalyzingViewModel {

    public enum State: Equatable, Sendable {
        case analyzing
        case failed
    }

    public private(set) var state: State = .analyzing
    public let photo: Data

    private let analyzer: any MealAnalyzing
    private let onEvent: @MainActor (AnalyzingEvent) -> Void

    init(photo: Data, analyzer: any MealAnalyzing, onEvent: @escaping @MainActor (AnalyzingEvent) -> Void) {
        self.photo = photo
        self.analyzer = analyzer
        self.onEvent = onEvent
    }

    /// Starts the analysis. Leaving the screen cancels it, and a cancelled analysis reports nothing.
    public func analyze() async {
        state = .analyzing
        do {
            let suggestions = try await analyzer.analyze(photo: photo)
            try Task.checkCancellation()
            onEvent(.finished(suggestions))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }

    public func continueWithoutAnalysisTapped() {
        onEvent(.continueWithoutAnalysis)
    }
}
