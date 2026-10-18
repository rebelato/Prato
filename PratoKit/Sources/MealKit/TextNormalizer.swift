import Foundation

/// Lowercase, accent-free, single-spaced text for comparing food names.
public enum TextNormalizer {

    public static func normalize(_ text: String) -> String {
        words(in: text).joined(separator: " ")
    }

    /// The normalized words of `text`, in order: "Iscas de carne!" → ["iscas", "de", "carne"].
    public static func words(in text: String) -> [String] {
        text
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
}
