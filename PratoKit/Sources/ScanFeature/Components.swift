import DesignSystem
import MealKit
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

/// One food with its calories and weight. Tappable rows show a chevron and an edit hint.
struct PortionRow: View {

    let portion: FoodPortion
    var isTappable = false

    var body: some View {
        HStack(spacing: 14) {
            Text(String(portion.food.name().prefix(1)))
                .font(.title3.weight(.bold))
                .foregroundStyle(PratoColor.accent)
                .frame(width: 48, height: 48)
                .background(PratoColor.surface, in: .rect(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(portion.food.name())
                    .font(PratoFont.bodyEmphasized)
                    .foregroundStyle(PratoColor.textPrimary)
                Text(L10n.Review.itemKcal(portion.totals.kcal))
                    .font(PratoFont.caption)
                    .foregroundStyle(PratoColor.textSecondary)
            }

            Spacer(minLength: 8)

            Text(Grams.format(portion.grams))
                .font(PratoFont.body.monospacedDigit())
                .foregroundStyle(PratoColor.textPrimary)

            if isTappable {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PratoColor.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 14)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityHint(isTappable ? L10n.Review.itemHint : "")
    }
}
