import MealKit

/// The instructions sent with each photo. Kept here, next to the validation, so changes to
/// what the model is asked and what the app accepts are reviewed together.
public enum RecognitionPrompt {

    public static var text: String {
        let preparations = Preparation.allCases.map(\.rawValue).joined(separator: ", ")
        return """
        Você analisa fotos de refeições para um diário alimentar no Brasil.
        Identifique separadamente cada alimento visível no prato.

        Regras:
        - Se a imagem não mostrar comida, responda \(RecognitionResponse.Field.containsFood) = false e uma lista vazia.
        - \(RecognitionResponse.Field.name): o nome do alimento em português do Brasil, como uma pessoa diria \
        (ex.: "arroz branco", "feijão carioca", "batata frita").
        - \(RecognitionResponse.Field.searchTerm): um termo curto e genérico, em minúsculas e sem acentos, \
        para buscar o alimento numa tabela nutricional (ex.: "arroz branco", "feijao", "batata").
        - \(RecognitionResponse.Field.preparation): o preparo provável, só quando for visível: \(preparations). \
        Omita se não der para saber.
        - \(RecognitionResponse.Field.estimatedGrams): o peso aproximado da porção pronta para consumo, em gramas, \
        só se der para estimar pela foto. É uma estimativa, não uma medição. Omita se não souber.
        - \(RecognitionResponse.Field.alternatives): até 3 outros alimentos plausíveis, só quando houver \
        ambiguidade real (ex.: purê de batata ou de mandioquinha).
        - \(RecognitionResponse.Field.uncertainty): uma frase curta quando algo dificultar a identificação \
        (molho cobrindo, foto escura, alimento cortado na borda).
        - Molhos, óleos e acompanhamentos visíveis são itens separados.
        - Não liste alimentos que não estejam visíveis.
        - Não informe calorias, macronutrientes nem percentuais de confiança.
        """
    }
}
