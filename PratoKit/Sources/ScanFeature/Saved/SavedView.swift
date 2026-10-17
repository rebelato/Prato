import DesignSystem
import MealKit
import SwiftUI

/// "Almoço salvo.": confirms the meal and shows what was logged.
///
/// There is no way back to the review from here, so the meal cannot be saved twice;
/// the only exit is "Voltar para hoje".
struct SavedView: View {

    let draft: MealDraft
    let onEvent: @MainActor (SavedEvent) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(PratoColor.accent)
                    .frame(width: 72, height: 72)
                    .background(PratoColor.softSurface, in: .circle)
                    .accessibilityHidden(true)

                Text(L10n.Saved.eyebrow)
                    .font(PratoFont.eyebrow)
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.top, 24)

                ScreenHeader(
                    title: L10n.Saved.title(draft.kind),
                    subtitle: L10n.Saved.loggedAt(draft.date.formatted(date: .omitted, time: .shortened))
                )
                .padding(.top, 8)

                MacroSummaryCard(
                    kcal: draft.totals.kcal,
                    protein: draft.totals.protein,
                    carbs: draft.totals.carbs,
                    fat: draft.totals.fat,
                    totalGrams: draft.portions.totalGrams
                )
                .padding(.top, 24)

                VStack(spacing: 0) {
                    ForEach(draft.portions) { portion in
                        PortionRow(portion: portion)
                        Divider()
                            .overlay(PratoColor.border)
                    }
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(L10n.Saved.done) { onEvent(.doneTapped) }
                .buttonStyle(.pratoPrimary)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(PratoColor.background)
        }
        .background(PratoColor.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    let catalog = FoodCatalog.development
    let portions = MockMealAnalyzer().result.compactMap { suggestion in
        catalog.food(id: suggestion.foodID).map { FoodPortion(food: $0, grams: suggestion.grams) }
    }
    return NavigationStack {
        SavedView(draft: MealDraft(kind: .lunch, portions: portions, photo: nil, date: .now)) { _ in }
    }
}
