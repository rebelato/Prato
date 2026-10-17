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

                Text(L10n.Review.disclaimer)
                    .font(PratoFont.secondary)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PratoColor.softSurface, in: .rect(cornerRadius: 16))
                    .padding(.top, 20)

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
            Button(L10n.Review.save) { viewModel.saveTapped() }
                .buttonStyle(.pratoPrimary)
                .disabled(!viewModel.canSave)
                .opacity(viewModel.canSave ? 1 : 0.4)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(PratoColor.background)
        }
        .scanScreenChrome()
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

    private var mealKindPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Review.mealKind)
                .font(PratoFont.secondary.weight(.medium))
                .foregroundStyle(PratoColor.textSecondary)

            Menu {
                Picker(selection: $viewModel.mealKind) {
                    ForEach(MealKind.allCases, id: \.self) { kind in
                        Text(L10n.mealKind(kind)).tag(kind)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack {
                    Text(L10n.mealKind(viewModel.mealKind))
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
            .accessibilityValue(L10n.mealKind(viewModel.mealKind))
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

#Preview {
    NavigationStack {
        ReviewView(viewModel: ReviewViewModel(
            suggestions: MockMealAnalyzer().result,
            photo: nil,
            catalog: .development,
            date: .now
        ) { _ in })
    }
}
