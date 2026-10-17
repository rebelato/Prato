import SwiftUI
import DesignSystem

/// Hoje: the entry to a scan and the meals logged today.
public struct HomeView: View {

    private let viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                logo
                header
                    .padding(.top, 32)
                scanCard
                    .padding(.top, 32)
                galleryButton
                    .padding(.top, 16)
                today
                    .padding(.top, 40)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(PratoColor.background)
    }

    private var logo: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf")
                .font(.title2.weight(.semibold))
                .foregroundStyle(PratoColor.accent)
            Text(verbatim: "prato")
                .font(.system(.title, weight: .bold))
                .foregroundStyle(PratoColor.textPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Prato"))
        .accessibilityAddTraits(.isHeader)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Home.eyebrow)
                .font(PratoFont.eyebrow)
                .textCase(.uppercase)
                .tracking(0.6)
                .foregroundStyle(PratoColor.textSecondary)
            Text(L10n.Home.title)
                .font(PratoFont.hero)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(L10n.Home.subtitle)
                .font(PratoFont.body)
                .foregroundStyle(PratoColor.textSecondary)
        }
    }

    private var scanCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.ScanCard.title)
                .font(PratoFont.sectionTitle)
                .foregroundStyle(PratoColor.textPrimary)
            Text(L10n.ScanCard.subtitle)
                .font(PratoFont.secondary)
                .foregroundStyle(PratoColor.textSecondary)
            PlateIllustration()
                .frame(maxWidth: 220)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            Button {
                viewModel.scanTapped()
            } label: {
                Label(L10n.ScanCard.scanButton, systemImage: "viewfinder")
            }
            .buttonStyle(.pratoPrimary)
        }
        .padding(24)
        .background(PratoColor.softSurface, in: .rect(cornerRadius: 28))
    }

    private var galleryButton: some View {
        Button {
            viewModel.galleryTapped()
        } label: {
            Label(L10n.ScanCard.galleryButton, systemImage: "photo")
        }
        .buttonStyle(.pratoSecondary)
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Today.title)
                .font(PratoFont.sectionTitle)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Divider()
                .overlay(PratoColor.border)
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundStyle(PratoColor.textSecondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Today.emptyTitle)
                        .font(PratoFont.bodyEmphasized)
                        .foregroundStyle(PratoColor.textPrimary)
                    Text(L10n.Today.emptySubtitle)
                        .font(PratoFont.secondary)
                        .foregroundStyle(PratoColor.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview("Claro") {
    HomeView(viewModel: HomeViewModel { _ in })
}

#Preview("Escuro") {
    HomeView(viewModel: HomeViewModel { _ in })
        .preferredColorScheme(.dark)
}
