import DesignSystem
import MealKit
import SwiftUI

/// "Escolher alimento": the whole catalog with search, foods like the recognized one first.
struct FoodPickerView: View {

    let catalog: FoodCatalog
    /// Recognized name and alternatives, used to list similar foods first.
    let hints: [String]
    let selection: Food?
    let onSelect: @MainActor (Food) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private var similar: [Food] {
        query.isEmpty ? catalog.similar(to: hints) : []
    }

    private var results: [Food] {
        catalog.search(query)
    }

    var body: some View {
        List {
            if !similar.isEmpty {
                Section(L10n.Picker.similar) {
                    ForEach(similar) { row(for: $0) }
                }
            }
            if query.isEmpty {
                Section(L10n.Picker.all) {
                    ForEach(results) { row(for: $0) }
                }
            } else {
                Section {
                    ForEach(results) { row(for: $0) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(PratoColor.background)
        .overlay {
            if results.isEmpty {
                ContentUnavailableView(
                    L10n.Picker.emptyTitle,
                    systemImage: "magnifyingglass",
                    description: Text(L10n.Picker.emptyHint)
                )
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: L10n.Picker.searchPrompt)
        .navigationTitle(L10n.Picker.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(for food: Food) -> some View {
        Button {
            onSelect(food)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.name())
                        .font(PratoFont.body)
                        .foregroundStyle(PratoColor.textPrimary)
                    Text(L10n.Picker.per100g(Kcal.format(Int(food.per100g.kcal.rounded()))))
                        .font(PratoFont.caption)
                        .foregroundStyle(PratoColor.textSecondary)
                }
                Spacer()
                if food.id == selection?.id {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(PratoColor.accent)
                }
            }
            .frame(minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .listRowBackground(PratoColor.surface)
        .accessibilityAddTraits(food.id == selection?.id ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        FoodPickerView(catalog: .development, hints: ["Iscas de carne bovina", "Carne de panela"], selection: nil) { _ in }
    }
}
