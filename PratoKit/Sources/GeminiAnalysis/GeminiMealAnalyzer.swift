import Foundation
@preconcurrency import FirebaseAILogic
import FoodRecognition
import MealKit

/// Identifies the foods in a photo with Gemini through Firebase AI Logic.
///
/// The model only recognizes foods and suggests portions. Nutrients always come from the local
/// catalog, computed in Swift; editing a weight never calls the model again.
///
/// Nothing about the photo or the answer is logged.
public struct GeminiMealAnalyzer: MealAnalyzing {

    public struct Configuration: Sendable {
        /// The Gemini model. Change it here or with the `PratoGeminiModel` key in Info.plist.
        public var modelName: String
        /// Ask App Check for single-use tokens. Turn on together with replay protection in the console.
        public var useLimitedUseAppCheckTokens: Bool

        public init(modelName: String = Configuration.defaultModelName, useLimitedUseAppCheckTokens: Bool = false) {
            self.modelName = modelName
            self.useLimitedUseAppCheckTokens = useLimitedUseAppCheckTokens
        }

        /// Stable, multimodal and with structured output on the Gemini Developer API, without
        /// requiring the Blaze plan; not marked "short-term availability" (October 2026).
        public static let defaultModelName = "gemini-3.5-flash"

        /// The default, unless the app's Info.plist sets `PratoGeminiModel`.
        public static func fromInfoPlist(_ bundle: Bundle = .main) -> Configuration {
            let override = (bundle.object(forInfoDictionaryKey: "PratoGeminiModel") as? String)?
                .trimmingCharacters(in: .whitespaces)
            guard let override, !override.isEmpty else { return Configuration() }
            return Configuration(modelName: override)
        }
    }

    private let configuration: Configuration
    private let matcher: CatalogMatcher

    /// Call only after `FirebaseBootstrap.configure()` returned true.
    public init(configuration: Configuration = .fromInfoPlist(), catalog: FoodCatalog) {
        self.configuration = configuration
        self.matcher = CatalogMatcher(catalog: catalog)
    }

    public var sendsPhotoToCloud: Bool { true }

    public func analyze(photo: Data) async throws -> MealAnalysis {
        let ai = FirebaseAI.firebaseAI(
            backend: .googleAI(),
            useLimitedUseAppCheckTokens: configuration.useLimitedUseAppCheckTokens
        )
        let model = ai.generativeModel(
            modelName: configuration.modelName,
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: RecognitionSchema.schema
            )
        )

        let response = try await model.generateContent(
            InlineDataPart(data: photo, mimeType: "image/jpeg"),
            RecognitionPrompt.text
        )
        try Task.checkCancellation()

        guard let text = response.text else {
            throw MealAnalysisError.unusableResponse
        }
        let foods = try RecognitionValidator.validate(RecognitionResponse.decode(text))
        return matcher.analysis(for: foods)
    }
}
