@preconcurrency import FirebaseAILogic
import FoodRecognition
import MealKit

/// The response schema sent to Gemini. Mirrors `RecognitionResponse`; field names come from
/// `RecognitionResponse.Field` so the two can't drift.
///
/// Firebase AI Logic supports a subset of OpenAPI (enum, items, maxItems, nullable, properties,
/// required); other keywords are ignored by the model, so limits are enforced again by
/// `RecognitionValidator`. No confidence score is requested on purpose: it wouldn't be calibrated.
enum RecognitionSchema {

    typealias Field = RecognitionResponse.Field

    static var schema: Schema {
        Schema.object(
            properties: [
                Field.containsFood: .boolean(description: "Se a imagem mostra comida."),
                Field.items: .array(
                    items: item,
                    description: "Cada alimento visível, separadamente. Vazio se não houver comida.",
                    maxItems: RecognitionValidator.maxItems
                )
            ],
            propertyOrdering: [Field.containsFood, Field.items]
        )
    }

    private static var item: Schema {
        Schema.object(
            properties: [
                Field.name: .string(description: "Nome do alimento em português do Brasil."),
                Field.searchTerm: .string(description: "Termo curto e genérico, minúsculo e sem acentos, para busca."),
                Field.preparation: .enumeration(
                    values: Preparation.allCases.map(\.rawValue),
                    description: "Preparo provável, só se visível."
                ),
                Field.estimatedGrams: .integer(
                    description: "Peso aproximado da porção pronta, em gramas. Estimativa.",
                    minimum: RecognitionValidator.gramsRange.lowerBound,
                    maximum: RecognitionValidator.gramsRange.upperBound
                ),
                Field.alternatives: .array(
                    items: .string(),
                    description: "Outros alimentos plausíveis quando houver ambiguidade.",
                    maxItems: RecognitionValidator.maxAlternatives
                ),
                Field.uncertainty: .string(description: "O que dificultou a identificação, se algo.")
            ],
            optionalProperties: [Field.preparation, Field.estimatedGrams, Field.alternatives, Field.uncertainty],
            propertyOrdering: [
                Field.name, Field.searchTerm, Field.preparation,
                Field.estimatedGrams, Field.alternatives, Field.uncertainty
            ]
        )
    }
}
