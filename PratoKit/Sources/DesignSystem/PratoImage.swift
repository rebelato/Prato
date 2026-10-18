import SwiftUI
import UIKit

/// Images of the Prato mocks, from this module's `Images.xcassets`.
public enum PratoImage {

    /// The X that closes a screen or drops an item, in the accent green of each appearance.
    public static let close = Image("close", bundle: .module)

    /// The scan frame, in the accent green of each appearance. Inside a filled button or the
    /// tab bar, use it with `.renderingMode(.template)` or ``scanTabIcon`` so it takes their color.
    public static let scan = Image("scan", bundle: .module)

    /// The scan frame sized for the tab bar, which shows images at their own size and tints them.
    public static var scanTabIcon: Image {
        guard let image = UIImage(named: "scan", in: .module, compatibleWith: nil) else {
            return Image(systemName: "viewfinder")
        }
        let size = CGSize(width: 25, height: 25)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return Image(uiImage: resized.withRenderingMode(.alwaysTemplate))
    }

    /// An open diary with an empty plate: no meals logged today.
    public static let emptyDay = Image("emptyDay", bundle: .module)

    /// A week calendar with an empty plate: no meals logged this week.
    public static let emptyWeek = Image("emptyWeek", bundle: .module)
}

/// The close X at its usual size, centered in a 44 × 44 tap area.
public struct CloseIcon: View {

    private let size: CGFloat

    public init(size: CGFloat = 20) {
        self.size = size
    }

    public var body: some View {
        PratoImage.close
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .frame(width: 44, height: 44)
            .contentShape(.rect)
    }
}
