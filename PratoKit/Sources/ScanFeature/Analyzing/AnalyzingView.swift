import DesignSystem
import MealKit
import SwiftUI

/// "Conhecendo seu prato…": waits for the analysis, or offers a way forward if it fails.
struct AnalyzingView: View {

    let viewModel: AnalyzingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScreenHeader(title: L10n.Analyzing.title)

                PhotoFrame(photo: viewModel.photo)
                    .padding(.top, 28)

                switch viewModel.state {
                case .analyzing:
                    analyzing
                        .padding(.top, 40)
                case .failed:
                    failed
                        .padding(.top, 32)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scanScreenChrome()
        .task { await viewModel.analyze() }
    }

    private var analyzing: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(PratoColor.accent)
            VStack(spacing: 6) {
                Text(L10n.Analyzing.status)
                    .font(PratoFont.bodyEmphasized)
                    .foregroundStyle(PratoColor.textPrimary)
                Text(L10n.Analyzing.hint)
                    .font(PratoFont.secondary)
                    .foregroundStyle(PratoColor.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var failed: some View {
        VStack(spacing: 8) {
            Text(L10n.Analyzing.failedTitle)
                .font(PratoFont.bodyEmphasized)
                .foregroundStyle(PratoColor.textPrimary)
            Text(L10n.Analyzing.failedMessage)
                .font(PratoFont.secondary)
                .foregroundStyle(PratoColor.textSecondary)
                .multilineTextAlignment(.center)

            Button(L10n.Analyzing.retry) {
                Task { await viewModel.analyze() }
            }
            .buttonStyle(.pratoPrimary)
            .padding(.top, 16)

            Button(L10n.Analyzing.manual) { viewModel.continueWithoutAnalysisTapped() }
                .buttonStyle(.pratoText)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AnalyzingView(viewModel: AnalyzingViewModel(photo: Data(), analyzer: MockMealAnalyzer(delay: .seconds(60))) { _ in })
    }
}
