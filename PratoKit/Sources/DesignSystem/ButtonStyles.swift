import SwiftUI

/// Full-width green button, the main action of a screen ("Escanear refeição", "Salvar refeição").
public struct PratoPrimaryButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PratoFont.button)
            .foregroundStyle(PratoColor.onPrimaryButton)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 16)
            .background(PratoColor.primaryButton, in: .rect(cornerRadius: 18))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Full-width outlined button for the second action ("Escolher da galeria").
public struct PratoSecondaryButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PratoFont.body)
            .foregroundStyle(PratoColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 16)
            .background(PratoColor.surface.opacity(configuration.isPressed ? 0.6 : 0), in: .rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(PratoColor.border, lineWidth: 1)
            }
    }
}

extension ButtonStyle where Self == PratoPrimaryButtonStyle {
    public static var pratoPrimary: PratoPrimaryButtonStyle { PratoPrimaryButtonStyle() }
}

extension ButtonStyle where Self == PratoSecondaryButtonStyle {
    public static var pratoSecondary: PratoSecondaryButtonStyle { PratoSecondaryButtonStyle() }
}
