import SwiftUI
import UIKit

/// Colors of the Prato mocks, from this module's asset catalog; each follows the system appearance.
public enum PratoColor {

    // MARK: Surfaces

    public static let background = Color("PratoBackground", bundle: .module)
    public static let surface = Color("PratoSurface", bundle: .module)
    /// The soft green of cards such as "O que tem no prato?".
    public static let softSurface = Color("PratoSoftSurface", bundle: .module)
    public static let border = Color("PratoBorder", bundle: .module)

    // MARK: Text

    public static let textPrimary = Color("PratoTextPrimary", bundle: .module)
    public static let textSecondary = Color("PratoTextSecondary", bundle: .module)

    // MARK: Actions

    /// Links, icons and the selected tab.
    public static let accent = Color("PratoAccent", bundle: .module)
    public static let primaryButton = Color("PratoPrimaryButton", bundle: .module)
    public static let onPrimaryButton = Color("PratoOnPrimaryButton", bundle: .module)

    // MARK: Macros

    public static let protein = Color("PratoProtein", bundle: .module)
    public static let carbs = Color("PratoCarbs", bundle: .module)
    public static let fat = Color("PratoFat", bundle: .module)

    // MARK: Plate illustration

    static let plateRim = Color("PratoPlateRim", bundle: .module)
    static let plate = Color("PratoPlate", bundle: .module)
}

extension Color {

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
