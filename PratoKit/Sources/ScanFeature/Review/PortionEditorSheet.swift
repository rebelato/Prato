import DesignSystem
import MealKit
import SwiftUI

/// "Ajustar alimento" / "Adicionar alimento": choose the food and its weight.
struct PortionEditorSheet: View {

    @State private var editor: PortionEditor
    @FocusState private var isWeightFocused: Bool

    private let catalog: FoodCatalog
    private let onApply: @MainActor (PortionEditor) -> Void
    private let onRemove: (@MainActor () -> Void)?
    private let onCancel: @MainActor () -> Void

    init(
        editor: PortionEditor,
        catalog: FoodCatalog,
        onApply: @escaping @MainActor (PortionEditor) -> Void,
        onRemove: (@MainActor () -> Void)?,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self._editor = State(initialValue: editor)
        self.catalog = catalog
        self.onApply = onApply
        self.onRemove = onRemove
        self.onCancel = onCancel
    }

    private var isAdding: Bool { editor.mode == .add }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(isAdding ? L10n.Editor.addTitle : L10n.Editor.adjustTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(PratoColor.background, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L10n.Editor.cancel) { onCancel() }
                    }
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(L10n.Common.done) { isWeightFocused = false }
                    }
                }
        }
        .tint(PratoColor.accent)
        .presentationDetents([.fraction(0.8), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(PratoColor.background)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let recognizedName = editor.recognizedName {
                    Text(L10n.Editor.recognizedAs(recognizedName))
                        .font(PratoFont.secondary)
                        .foregroundStyle(PratoColor.textSecondary)
                        .padding(.bottom, 16)
                }
                fieldLabel(L10n.Editor.food)
                foodPicker
                    .padding(.top, 8)

                fieldLabel(L10n.Editor.weight)
                    .padding(.top, 20)
                weightField
                    .padding(.top, 8)
                stepButtons
                    .padding(.top, 12)

                Text(L10n.Editor.hint)
                    .font(PratoFont.caption)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.top, 16)
                Text(L10n.Editor.estimate(editor.totals.kcal))
                    .font(PratoFont.bodyEmphasized.monospacedDigit())
                    .foregroundStyle(PratoColor.textPrimary)
                    .padding(.top, 4)

                Button(isAdding ? L10n.Editor.add : L10n.Editor.apply) { onApply(editor) }
                    .buttonStyle(.pratoPrimary)
                    .disabled(!editor.canApply)
                    .opacity(editor.canApply ? 1 : 0.4)
                    .padding(.top, 24)

                if let onRemove {
                    Button(L10n.Editor.remove, role: .destructive) { onRemove() }
                        .font(PratoFont.button)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background(PratoColor.background)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(PratoFont.secondary.weight(.medium))
            .foregroundStyle(PratoColor.textSecondary)
    }

    private var foodPicker: some View {
        Menu {
            Picker(selection: $editor.food) {
                ForEach(catalog.foods) { food in
                    Text(food.name()).tag(food)
                }
            } label: {
                EmptyView()
            }
        } label: {
            HStack {
                Text(editor.food.name())
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
        .accessibilityLabel(L10n.Editor.food)
        .accessibilityValue(editor.food.name())
    }

    /// Typing updates the estimate live; non-digits are ignored.
    private var gramsText: Binding<String> {
        Binding(
            get: { editor.grams == 0 ? "" : String(editor.grams) },
            set: { editor.grams = Int($0.filter(\.isNumber).prefix(5)) ?? 0 }
        )
    }

    private var weightField: some View {
        HStack {
            TextField("0", text: gramsText)
                .keyboardType(.numberPad)
                .focused($isWeightFocused)
                .font(.title2.monospacedDigit())
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityLabel(L10n.Editor.weight)
            Text(verbatim: "g")
                .font(.title3)
                .foregroundStyle(PratoColor.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 56)
        .background(PratoColor.surface, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isWeightFocused ? PratoColor.accent : PratoColor.border, lineWidth: 1)
        }
    }

    private var stepButtons: some View {
        HStack(spacing: 10) {
            ForEach([-50, -25, 25, 50], id: \.self) { delta in
                Button {
                    editor.adjustGrams(by: delta)
                } label: {
                    Text(verbatim: "\(delta > 0 ? "+" : "−")\(Grams.format(abs(delta)))")
                        .font(PratoFont.body.monospacedDigit())
                        .foregroundStyle(PratoColor.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(PratoColor.surface, in: .rect(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(PratoColor.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.Editor.step(delta))
            }
        }
    }
}

#Preview {
    Color.clear.sheet(isPresented: .constant(true)) {
        PortionEditorSheet(
            editor: PortionEditor(mode: .edit(UUID()), food: FoodCatalog.development.foods[1], grams: 150),
            catalog: .development,
            onApply: { _ in },
            onRemove: {},
            onCancel: {}
        )
    }
}
