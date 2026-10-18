import Foundation
import MealKit
import Observation

/// Runs the analysis of the photo and reports what it found.
@MainActor
@Observable
public final class AnalyzingViewModel {

    public enum State: Equatable, Sendable {
        case analyzing
        /// The photo shows no food: retaking it is the useful next step.
        case noFood
        /// Network, service or answer problem: trying again may work.
        case failed
    }

    public private(set) var state: State = .analyzing
    public let photo: Data

    private let analyzer: any MealAnalyzing
    private let onEvent: @MainActor (AnalyzingEvent) -> Void
    private var isRunning = false

    init(photo: Data, analyzer: any MealAnalyzing, onEvent: @escaping @MainActor (AnalyzingEvent) -> Void) {
        self.photo = photo
        self.analyzer = analyzer
        self.onEvent = onEvent
    }

    /// Starts the analysis. A second call while one is running does nothing, so the photo is
    /// never sent twice. Leaving the screen cancels it, and a cancelled analysis reports nothing.
    public func analyze() async {
        guard !isRunning else { return }
        isRunning = true
        defer { isRunning = false }

        state = .analyzing
        do {
            let analysis = try await analyzer.analyze(photo: photo)
            try Task.checkCancellation()
            onEvent(.finished(analysis))
        } catch is CancellationError {
            return
        } catch MealAnalysisError.noFoodFound {
            state = .noFood
        } catch {
            state = .failed
        }
    }

    public func retakeTapped() {
        onEvent(.retakeRequested)
    }

    public func continueWithoutAnalysisTapped() {
        onEvent(.continueWithoutAnalysis)
    }
}
