import DesignSystem
import SwiftUI

/// "Ficou tudo visível?": the photo just taken, before it is analyzed.
struct PhotoConfirmView: View {

    let photo: Data?
    let onEvent: @MainActor (PhotoConfirmEvent) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScreenHeader(title: L10n.Confirm.title, subtitle: L10n.Confirm.subtitle)

                PhotoFrame(photo: photo)
                    .padding(.top, 28)

                Button(L10n.Confirm.analyze) { onEvent(.analyzeRequested) }
                    .buttonStyle(.pratoPrimary)
                    .padding(.top, 32)

                Button(L10n.Confirm.retake) { onEvent(.retakeRequested) }
                    .buttonStyle(.pratoText)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scanScreenChrome()
    }
}

#Preview {
    NavigationStack {
        PhotoConfirmView(photo: nil) { _ in }
    }
}
