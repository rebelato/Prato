import SwiftUI
import UIKit

/// A saved meal in a list: photo (or a placeholder), title and a detail line.
///
/// Used on Hoje and Histórico. Takes plain text so the design system stays free of the domain.
public struct MealRowView: View {

    private let title: String
    private let detail: String
    private let photo: Data?

    public init(title: String, detail: String, photo: Data?) {
        self.title = title
        self.detail = detail
        self.photo = photo
    }

    public var body: some View {
        HStack(spacing: 14) {
            thumbnail
                .frame(width: 52, height: 52)
                .clipShape(.rect(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PratoFont.bodyEmphasized)
                    .foregroundStyle(PratoColor.textPrimary)
                Text(detail)
                    .font(PratoFont.caption.monospacedDigit())
                    .foregroundStyle(PratoColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let photo, let image = UIImage(data: photo) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            PratoColor.softSurface
                .overlay {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(PratoColor.accent)
                }
        }
    }
}

/// Calories for the user's locale ("1.194 kcal" in pt-BR, "1,194 kcal" in en).
public enum Kcal {
    public static func format(_ kcal: Int) -> String {
        "\(kcal.formatted(.number)) \(DesignL10n.kcal)"
    }
}
