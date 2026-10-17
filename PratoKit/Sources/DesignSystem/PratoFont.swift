import SwiftUI

/// Type scale of the mocks, built on text styles so it follows Dynamic Type.
public enum PratoFont {
    /// Hero line on Hoje ("Uma foto. Seu prato, mais claro.").
    public static let hero = Font.system(.largeTitle, weight: .bold)
    /// Screen titles ("Vamos conferir?", "Histórico").
    public static let screenTitle = Font.system(.title, weight: .bold)
    /// Section titles ("Hoje") and card titles.
    public static let sectionTitle = Font.system(.title2, weight: .bold)
    public static let body = Font.body
    public static let bodyEmphasized = Font.system(.body, weight: .semibold)
    public static let secondary = Font.callout
    public static let caption = Font.footnote
    /// Small uppercase labels ("SEU DIÁRIO ALIMENTAR"). Pair with `.textCase(.uppercase)` and `.tracking(0.6)`.
    public static let eyebrow = Font.system(.caption, weight: .bold)
    public static let button = Font.headline
}
