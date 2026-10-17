import DesignSystem
import HomeFeature
import SwiftUI

// Temporary screens so the tab bar works end to end.
// Each one is replaced by its feature module in a later PR.

/// Stands in for the scan flow (camera, review, save).
struct ScanPlaceholderView: View {

    let source: ScanSource
    let onClose: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(L10n.ScanPlaceholder.close) { onClose() }
                .font(PratoFont.bodyEmphasized)
                .foregroundStyle(PratoColor.accent)
                .frame(minHeight: 44)

            Text(L10n.ScanPlaceholder.title)
                .font(PratoFont.screenTitle)
                .foregroundStyle(PratoColor.textPrimary)
                .padding(.top, 16)
            Text(L10n.ScanPlaceholder.subtitle)
                .font(PratoFont.body)
                .foregroundStyle(PratoColor.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(PratoColor.background)
    }
}

/// Stands in for Histórico.
struct HistoryPlaceholderView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.HistoryPlaceholder.title)
                .font(PratoFont.screenTitle)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(L10n.HistoryPlaceholder.subtitle)
                .font(PratoFont.body)
                .foregroundStyle(PratoColor.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .background(PratoColor.background)
    }
}
