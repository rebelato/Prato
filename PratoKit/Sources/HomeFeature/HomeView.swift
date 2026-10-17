import DesignSystem
import MealKit
import SwiftUI
import UIKit

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
        .task { await viewModel.load() }
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
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Today.title)
                    .font(PratoFont.sectionTitle)
                    .foregroundStyle(PratoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if !viewModel.todayMeals.isEmpty {
                    Text(verbatim: "\(L10n.Today.mealCount(viewModel.todayMeals.count)) · \(Kcal.format(viewModel.todayTotals.kcal))")
                        .font(PratoFont.secondary)
                        .foregroundStyle(PratoColor.textSecondary)
                }
            }
            Divider()
                .overlay(PratoColor.border)

            if viewModel.todayMeals.isEmpty {
                if viewModel.hasLoaded {
                    emptyToday
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.todayMeals) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
        }
    }

    private var emptyToday: some View {
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

/// One saved meal on Hoje: photo, type, time and calories.
private struct MealRow: View {

    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
                .frame(width: 52, height: 52)
                .clipShape(.rect(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.mealKind(meal.kind))
                    .font(PratoFont.bodyEmphasized)
                    .foregroundStyle(PratoColor.textPrimary)
                Text(verbatim: "\(meal.date.formatted(date: .omitted, time: .shortened)) · \(Kcal.format(meal.totals.kcal))")
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
        if let photo = meal.photo, let image = UIImage(data: photo) {
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
private enum Kcal {
    static func format(_ kcal: Int) -> String {
        "\(kcal.formatted(.number)) kcal"
    }
}

#Preview("Claro") {
    HomeView(viewModel: HomeViewModel(store: InMemoryMealStore()) { _ in })
}

#Preview("Com refeições") {
    let rice = FoodCatalog.development.foods[0]
    let store = InMemoryMealStore(meals: [
        Meal(kind: .breakfast, date: .now.addingTimeInterval(-4 * 3600), portions: [FoodPortion(food: rice, grams: 80)], photo: nil),
        Meal(kind: .lunch, date: .now, portions: [FoodPortion(food: rice, grams: 150)], photo: nil)
    ])
    return HomeView(viewModel: HomeViewModel(store: store) { _ in })
}

#Preview("Escuro") {
    HomeView(viewModel: HomeViewModel(store: InMemoryMealStore()) { _ in })
        .preferredColorScheme(.dark)
}
