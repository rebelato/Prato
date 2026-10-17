import DesignSystem
import SwiftUI
import UIKit

/// Title and optional subtitle at the top of each scan screen.
struct ScreenHeader: View {

    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(PratoFont.screenTitle)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(PratoFont.body)
                    .foregroundStyle(PratoColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The photo of the plate in a rounded square; the drawn plate when there is no photo.
struct PhotoFrame: View {

    let photo: Data?

    var body: some View {
        PratoColor.softSurface
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let photo, let image = UIImage(data: photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    PlateIllustration()
                        .padding(48)
                }
            }
            .clipShape(.rect(cornerRadius: 28))
            .accessibilityHidden(true)
    }
}

/// A full-width text button in the accent color ("Tirar outra foto").
struct PratoTextButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PratoFont.button)
            .foregroundStyle(PratoColor.accent)
            .frame(maxWidth: .infinity, minHeight: 48)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == PratoTextButtonStyle {
    static var pratoText: PratoTextButtonStyle { PratoTextButtonStyle() }
}

extension View {
    /// Plain background and a bar that only shows the back button, for pushed scan screens.
    func scanScreenChrome() -> some View {
        self
            .background(PratoColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PratoColor.background, for: .navigationBar)
    }
}
