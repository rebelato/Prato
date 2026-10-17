import Foundation

/// Texts of Histórico, read from this module's `Localizable.xcstrings`.
enum L10n {
    static var title: String {
        String(localized: "history.title", defaultValue: "Histórico", bundle: .module, comment: "Title of the history screen")
    }
    static var subtitle: String {
        String(localized: "history.subtitle", defaultValue: "Sua semana à mesa, dia a dia.", bundle: .module, comment: "Text under the history title")
    }
    static var previousWeek: String {
        String(localized: "history.previousWeek", defaultValue: "Semana anterior", bundle: .module, comment: "Accessibility label of the previous week button")
    }
    static var nextWeek: String {
        String(localized: "history.nextWeek", defaultValue: "Próxima semana", bundle: .module, comment: "Accessibility label of the next week button")
    }
    static var weekTotal: String {
        String(localized: "history.weekTotal", defaultValue: "Total da semana", bundle: .module, comment: "Label at the top of the week's calorie card")
    }
    static func loggedDays(_ count: Int) -> String {
        String(localized: "history.loggedDays", defaultValue: "\(count) dias registrados", bundle: .module, comment: "How many days of the week have meals; plural by the number")
    }
    static func average(_ kcal: String) -> String {
        String(localized: "history.average", defaultValue: "Média: \(kcal)/dia", bundle: .module, comment: "Average calories per logged day; the argument is a value such as 1.623 kcal")
    }
    static func mealCount(_ count: Int) -> String {
        String(localized: "history.mealCount", defaultValue: "\(count) refeições", bundle: .module, comment: "How many meals on a day; plural by the number")
    }
    static var dayEmpty: String {
        String(localized: "history.day.empty", defaultValue: "Nenhuma refeição neste dia.", bundle: .module, comment: "The selected day has no meals")
    }
    static var emptyTitle: String {
        String(localized: "history.empty.title", defaultValue: "Nenhuma refeição nesta semana", bundle: .module, comment: "The week on screen has no meals")
    }
    static var emptyMessage: String {
        String(localized: "history.empty.message", defaultValue: "Registre uma refeição para vê-la aqui.", bundle: .module, comment: "How to fill the empty week")
    }
    static var scan: String {
        String(localized: "history.scan", defaultValue: "Escanear refeição", bundle: .module, comment: "Opens the camera to log a meal")
    }
    static var pickDay: String {
        String(localized: "history.pickDay", defaultValue: "Escolher dia", bundle: .module, comment: "Title of the calendar sheet that jumps to a day")
    }
    static var pickDayHint: String {
        String(localized: "history.pickDay.hint", defaultValue: "Abre o calendário para escolher um dia.", bundle: .module, comment: "Accessibility hint of the week label, which opens the calendar")
    }
    static var pickDayToday: String {
        String(localized: "history.pickDay.today", defaultValue: "Hoje", bundle: .module, comment: "Calendar sheet button that jumps to today")
    }
    static var pickDayCancel: String {
        String(localized: "history.pickDay.cancel", defaultValue: "Cancelar", bundle: .module, comment: "Closes the calendar sheet without changes")
    }
}
