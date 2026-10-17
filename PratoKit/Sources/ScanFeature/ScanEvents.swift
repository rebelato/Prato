import Coordinator
import Foundation
import MealKit

/// What the scan flow reports to whoever presented it.
public enum ScanEvent: Event {
    /// The user reviewed the meal and tapped "Salvar refeição". The flow stays open on
    /// the confirmation screen; the parent should store the meal now.
    case mealSaved(MealDraft)
    /// The user tapped "Voltar para hoje" after saving. The parent closes the flow.
    case finished
    /// The user closed the flow without saving.
    case cancelled
}

/// The screens of the flow pushed over the camera.
public enum ScanRoute: Hashable, Sendable {
    /// "Ficou tudo visível?"
    case confirm
    /// "Conhecendo seu prato…"
    case analyzing
    /// "Vamos conferir?"
    case review
    /// "Almoço salvo."
    case saved
}

enum CaptureEvent: Event {
    /// JPEG of the plate, from the camera, the library or the sample photo.
    case photoTaken(Data)
    /// "Sem foto": go straight to an empty review.
    case skipPhotoRequested
    case closeRequested
}

enum PhotoConfirmEvent: Event {
    case analyzeRequested
    case retakeRequested
}

enum AnalyzingEvent: Event {
    case finished([FoodSuggestion])
    /// The analysis failed and the user chose to add the foods by hand.
    case continueWithoutAnalysis
}

enum ReviewEvent: Event {
    case saveRequested(MealDraft)
}

enum SavedEvent: Event {
    case doneTapped
}
