import DesignSystem
import MealKit
import SwiftUI

/// "Vamos conferir?": correct the suggested foods, pick the meal type and save.
struct ReviewView: View {

    @Bindable var viewModel: ReviewViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: L10n.Review.title, subtitle: L10n.Review.subtitle)

                mealKindPicker
                    .padding(.top, 24)

                Text(viewModel.usesDemonstrationValues
                     ? "\(L10n.Review.disclaimer) \(L10n.Review.demonstrationValues)"
                     : L10n.Review.disclaimer)
                    .font(PratoFont.secondary)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PratoColor.softSurface, in: .rect(cornerRadius: 16))
                    .padding(.top, 20)

                if !viewModel.unmatched.isEmpty {
                    unmatchedSection
                        .padding(.top, 20)
                }

                items
                    .padding(.top, 12)

                Button {
                    viewModel.addFoodTapped()
                } label: {
                    Label(L10n.Review.addFood, systemImage: "plus")
                }
                .buttonStyle(.pratoText)
                .padding(.top, 8)

                MacroSummaryCard(
                    kcal: viewModel.totals.kcal,
                    protein: viewModel.totals.protein,
                    carbs: viewModel.totals.carbs,
                    fat: viewModel.totals.fat,
                    totalGrams: viewModel.totalGrams
                )
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.saveTapped() }
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(PratoColor.onPrimaryButton)
                } else {
                    Text(L10n.Review.save)
                }
            }
            .buttonStyle(.pratoPrimary)
            .disabled(!viewModel.canSave)
            .opacity(viewModel.canSave || viewModel.isSaving ? 1 : 0.4)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(PratoColor.background)
        }
        .scanScreenChrome()
        .alert(L10n.Review.saveFailed, isPresented: $viewModel.showsSaveError) {
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .sheet(item: $viewModel.editor) { editor in
            PortionEditorSheet(
                editor: editor,
                catalog: viewModel.catalog,
                onApply: { viewModel.apply($0) },
                onRemove: removeAction(for: editor),
                onCancel: { viewModel.cancelEditing() }
            )
        }
    }

    private func removeAction(for editor: PortionEditor) -> (@MainActor () -> Void)? {
        guard case .edit(let id) = editor.mode else { return nil }
        return { viewModel.remove(id) }
    }

    private var unmatchedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.Review.toConfirmTitle)
                .font(PratoFont.bodyEmphasized)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(L10n.Review.toConfirmSubtitle)
                .font(PratoFont.caption)
                .foregroundStyle(PratoColor.textSecondary)
                .padding(.top, 2)

            ForEach(viewModel.unmatched) { item in
                HStack(spacing: 12) {
                    Button {
                        viewModel.unmatchedTapped(item)
                    } label: {
                        UnmatchedRow(item: item, suggestion: item.suggestedFoodID.flatMap(viewModel.catalog.food(id:)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.dismissUnmatched(item.id)
                    } label: {
                        CloseIcon(size: 14)
                    }
                    .accessibilityLabel(L10n.Review.dismissUnmatched(item.name))
                }
                Divider()
                    .overlay(PratoColor.border)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(PratoColor.surface, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PratoColor.carbs.opacity(0.6), lineWidth: 1)
        }
    }

    private var mealKindPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Review.mealKind)
                .font(PratoFont.secondary.weight(.medium))
                .foregroundStyle(PratoColor.textSecondary)

            Menu {
                Picker(selection: $viewModel.mealKind) {
                    ForEach(MealKind.allCases, id: \.self) { kind in
                        Text(kind.localizedName).tag(kind)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack {
                    Text(viewModel.mealKind.localizedName)
                        .font(PratoFont.body)
                        .foregroundStyle(PratoColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(PratoColor.textSecondary)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
                .background(PratoColor.surface, in: .rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(PratoColor.border, lineWidth: 1)
                }
            }
            .accessibilityLabel(L10n.Review.mealKind)
            .accessibilityValue(viewModel.mealKind.localizedName)
        }
    }

    @ViewBuilder
    private var items: some View {
        if viewModel.portions.isEmpty {
            Text(L10n.Review.empty)
                .font(PratoFont.secondary)
                .foregroundStyle(PratoColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
        } else {
            VStack(spacing: 0) {
                ForEach(viewModel.portions) { portion in
                    Button {
                        viewModel.portionTapped(portion)
                    } label: {
                        PortionRow(portion: portion, isTappable: true)
                    }
                    .buttonStyle(.plain)
                    Divider()
                        .overlay(PratoColor.border)
                }
            }
        }
    }
}

/// A food the analysis couldn't match: its name, preparation and what the user should do.
private struct UnmatchedRow: View {

    let item: UnmatchedFood
    let suggestion: Food?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(PratoFont.body.weight(.medium))
                .foregroundStyle(PratoColor.textPrimary)
            Text(detail)
                .font(PratoFont.caption)
                .foregroundStyle(PratoColor.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .padding(.vertical, 8)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.Review.itemHint)
    }

    private var title: String {
        guard let preparation = item.preparation else { return item.name }
        return "\(item.name) (\(preparation))"
    }

    private var detail: String {
        if let suggestion {
            return L10n.Review.looksLike(suggestion.name())
        }
        if !item.alternatives.isEmpty {
            return L10n.Review.couldBe(item.alternatives.joined(separator: ", "))
        }
        return L10n.Review.notInCatalog
    }
}

#Preview {
    NavigationStack {
        ReviewView(viewModel: ReviewViewModel(
            suggestions: MockMealAnalyzer().result,
            unmatched: [
                UnmatchedFood(name: "Farofa", preparation: nil, estimatedGrams: 40, alternatives: []),
                UnmatchedFood(name: "Feijão preto", preparation: "cozido", estimatedGrams: 90, alternatives: [], suggestedFoodID: "beans-carioca-cooked")
            ],
            photo: nil,
            catalog: .development,
            store: InMemoryMealStore(),
            date: .now
        ) { _ in })
    }
}
