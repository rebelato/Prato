import SwiftUI

/// The white card with a meal's calories and macros ("Estimativa da refeição").
///
/// The bar is split by each macro's share of the calories (4 kcal/g for protein and
/// carbs, 9 kcal/g for fat), so its proportions mean something.
public struct MacroSummaryCard: View {

    private let title: String
    private let kcal: Int
    private let protein: Int
    private let carbs: Int
    private let fat: Int
    private let totalGrams: Int?

    /// - Parameters:
    ///   - title: Uppercase label at the top. Defaults to "Estimativa da refeição".
    ///   - totalGrams: Weight shown on the right of the title; `nil` hides it.
    public init(
        title: String? = nil,
        kcal: Int,
        protein: Int,
        carbs: Int,
        fat: Int,
        totalGrams: Int? = nil
    ) {
        self.title = title ?? DesignL10n.mealEstimate
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.totalGrams = totalGrams
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(PratoFont.eyebrow)
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(PratoColor.textSecondary)
                Spacer()
                if let totalGrams {
                    Text(Grams.format(totalGrams))
                        .font(PratoFont.caption)
                        .foregroundStyle(PratoColor.textSecondary)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(kcal, format: .number)
                    .font(.system(size: 48, weight: .bold).monospacedDigit())
                    .foregroundStyle(PratoColor.textPrimary)
                Text(DesignL10n.kcal)
                    .font(.title3)
                    .foregroundStyle(PratoColor.textSecondary)
            }
            .accessibilityElement(children: .combine)

            MacroBar(protein: protein, carbs: carbs, fat: fat)

            HStack(alignment: .top, spacing: 12) {
                macro(value: protein, label: DesignL10n.protein, color: PratoColor.protein)
                macro(value: carbs, label: DesignL10n.carbs, color: PratoColor.carbs)
                macro(value: fat, label: DesignL10n.fat, color: PratoColor.fat)
            }
        }
        .padding(22)
        .background(PratoColor.surface, in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(PratoColor.border.opacity(0.6), lineWidth: 1)
        }
    }

    private func macro(value: Int, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                Text(Grams.format(value))
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(PratoColor.textPrimary)
            }
            Text(label)
                .font(PratoFont.caption)
                .foregroundStyle(PratoColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// One bar split by each macro's share of the calories.
public struct MacroBar: View {

    private let shares: [(value: Double, color: Color)]

    public init(protein: Int, carbs: Int, fat: Int) {
        shares = [
            (Double(protein * 4), PratoColor.protein),
            (Double(carbs * 4), PratoColor.carbs),
            (Double(fat * 9), PratoColor.fat)
        ]
    }

    public var body: some View {
        GeometryReader { proxy in
            let total = shares.reduce(0) { $0 + $1.value }
            let visible = shares.filter { $0.value > 0 }
            let spacing: CGFloat = 3
            let available = max(proxy.size.width - spacing * CGFloat(max(visible.count - 1, 0)), 0)

            HStack(spacing: spacing) {
                if total > 0 {
                    ForEach(visible.indices, id: \.self) { index in
                        visible[index].color
                            .frame(width: available * visible[index].value / total)
                    }
                } else {
                    PratoColor.border
                }
            }
            .clipShape(.capsule)
        }
        .frame(height: 10)
        .accessibilityHidden(true)
    }
}

/// Formats whole grams for the user's locale ("120 g").
public enum Grams {
    public static func format(_ grams: Int) -> String {
        Measurement(value: Double(grams), unit: UnitMass.grams)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number))
    }
}

#Preview {
    VStack {
        MacroSummaryCard(kcal: 400, protein: 52, carbs: 37, fat: 4, totalGrams: 330)
        MacroSummaryCard(kcal: 0, protein: 0, carbs: 0, fat: 0)
    }
    .padding()
    .background(PratoColor.background)
}
