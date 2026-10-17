import SwiftUI
import UIKit

/// Colors of the Prato mocks, each with its light and dark value.
public enum PratoColor {

    // MARK: Surfaces

    public static let background = Color(light: 0xF4F5F0, dark: 0x121814)
    public static let surface = Color(light: 0xFFFFFF, dark: 0x1B231E)
    /// The soft green of cards such as "O que tem no prato?".
    public static let softSurface = Color(light: 0xE6EBDE, dark: 0x1E2A22)
    public static let border = Color(light: 0xDCE1D6, dark: 0x2C3830)

    // MARK: Text

    public static let textPrimary = Color(light: 0x1C2E24, dark: 0xE8EDE7)
    public static let textSecondary = Color(light: 0x56645A, dark: 0xA3B0A6)

    // MARK: Actions

    /// Links, icons and the selected tab.
    public static let accent = Color(light: 0x285E42, dark: 0x7CC79A)
    public static let primaryButton = Color(light: 0x285E42, dark: 0x2F7A52)
    public static let onPrimaryButton = Color(light: 0xFFFFFF, dark: 0xFFFFFF)

    // MARK: Macros

    public static let protein = Color(light: 0x285E42, dark: 0x5DB585)
    public static let carbs = Color(light: 0xC08A45, dark: 0xD29A55)
    public static let fat = Color(light: 0x7C7CB8, dark: 0x9A9AD6)

    // MARK: Plate illustration

    static let plateRim = Color(light: 0xEFEDE4, dark: 0xE4E1D7)
    static let plate = Color(light: 0xFEFDF9, dark: 0xFAF8F2)
}

extension Color {

    /// A color that follows the system appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// A fixed color, the same in both appearances.
    init(rgb: UInt32) {
        self.init(uiColor: UIColor(rgb: rgb))
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
