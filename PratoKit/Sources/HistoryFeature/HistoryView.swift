import DesignSystem
import MealKit
import SwiftUI

/// Histórico: one week of meals, with totals and the meals of the selected day.
public struct HistoryView: View {

    @Bindable private var viewModel: HistoryViewModel

    public init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.title)
                        .font(PratoFont.screenTitle)
                        .foregroundStyle(PratoColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }

                weekNavigator
                    .padding(.top, 22)
                dayStrip
                    .padding(.top, 16)

                if viewModel.hasLoaded {
                    if viewModel.weekMeals.isEmpty {
                        emptyWeek
                            .padding(.top, 16)
                    } else {
                        weekSummary
                            .padding(.top, 16)
                        selectedDay
                            .padding(.top, 28)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(PratoColor.background)
        .task { await viewModel.load() }
        .sheet(isPresented: $viewModel.isDayPickerPresented) {
            DayPickerSheet(
                selectedDay: viewModel.selectedDay,
                lastDay: viewModel.lastSelectableDay,
                onPick: { day in Task { await viewModel.dayPicked(day) } },
                onCancel: { viewModel.isDayPickerPresented = false }
            )
        }
    }

    // MARK: Week

    private var weekNavigator: some View {
        HStack {
            Button {
                Task { await viewModel.previousWeekTapped() }
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(L10n.previousWeek)

            Spacer()

            Button {
                viewModel.weekTitleTapped()
            } label: {
                HStack(spacing: 6) {
                    Text((viewModel.week.start..<viewModel.weekLastDay).formatted(.interval.day().month(.wide)))
                        .font(PratoFont.bodyEmphasized)
                        .foregroundStyle(PratoColor.textPrimary)
                }
                .frame(minHeight: 44)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint(L10n.pickDayHint)

            Spacer()

            Button {
                Task { await viewModel.nextWeekTapped() }
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 44)
            }
            .disabled(!viewModel.canShowNextWeek)
            .accessibilityLabel(L10n.nextWeek)
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(PratoColor.accent)
        .padding(.horizontal, 4)
        .frame(minHeight: 52)
        .background(PratoColor.surface, in: .rect(cornerRadius: 18))
    }

    private var dayStrip: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.days) { day in
                DayCell(day: day, isSelected: day.date == viewModel.selectedDay) {
                    viewModel.select(day)
                }
            }
        }
    }

    private var weekSummary: some View {
        VStack(spacing: 12) {
            MacroSummaryCard(
                title: L10n.weekTotal,
                kcal: viewModel.weekTotals.kcal,
                protein: viewModel.weekTotals.protein,
                carbs: viewModel.weekTotals.carbs,
                fat: viewModel.weekTotals.fat
            )
            HStack {
                Text(L10n.loggedDays(viewModel.loggedDayCount))
                Spacer()
                if let average = viewModel.averageKcalPerLoggedDay {
                    Text(L10n.average(Kcal.format(average)))
                }
            }
            .font(PratoFont.secondary)
            .foregroundStyle(PratoColor.textSecondary)
            .padding(.horizontal, 4)
        }
    }

    private var emptyWeek: some View {
        VStack(alignment: .leading, spacing: 10) {
            PratoImage.emptyWeek
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 6)
                .accessibilityHidden(true)
            Text(L10n.emptyTitle)
                .font(PratoFont.sectionTitle)
                .foregroundStyle(PratoColor.textPrimary)
            Text(L10n.emptyMessage)
                .font(PratoFont.body)
                .foregroundStyle(PratoColor.textSecondary)
            Button(L10n.scan) { viewModel.scanTapped() }
                .buttonStyle(.pratoPrimary)
                .padding(.top, 14)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PratoColor.surface, in: .rect(cornerRadius: 24))
    }

    // MARK: Selected day

    private var selectedDay: some View {
        let meals = viewModel.selectedDayMeals
        return VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.selectedDay.formatted(.dateTime.weekday(.wide).day().month(.wide)).capitalizedFirstLetter)
                .font(PratoFont.sectionTitle)
                .foregroundStyle(PratoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            if meals.isEmpty {
                Text(L10n.dayEmpty)
                    .font(PratoFont.secondary)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.top, 6)
            } else {
                Text(verbatim: "\(L10n.mealCount(meals.count)) · \(Kcal.format(meals.totals.kcal))")
                    .font(PratoFont.secondary)
                    .foregroundStyle(PratoColor.textSecondary)
                    .padding(.top, 6)

                VStack(spacing: 0) {
                    ForEach(meals) { meal in
                        MealRowView(
                            title: meal.kind.localizedName,
                            detail: "\(meal.date.formatted(date: .omitted, time: .shortened)) · \(Kcal.format(meal.totals.kcal))",
                            photo: meal.photo
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

/// A day in the week strip: weekday, number and a dot when meals were logged.
private struct DayCell: View {

    let day: HistoryDay
    let isSelected: Bool
    let action: @MainActor () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Text(weekday)
                    .font(.caption.weight(.medium))
                Text(day.date.formatted(.dateTime.day()))
                    .font(.title3.weight(.bold).monospacedDigit())
                Circle()
                    .fill(day.mealCount > 0 ? dotColor : .clear)
                    .frame(width: 5, height: 5)
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(isSelected ? PratoColor.primaryButton : .clear, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(day.isFuture)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var weekday: String {
        day.date.formatted(.dateTime.weekday(.abbreviated))
            .replacingOccurrences(of: ".", with: "")
            .uppercased()
    }

    private var textColor: Color {
        if isSelected { return PratoColor.onPrimaryButton }
        return day.isFuture ? PratoColor.textSecondary : PratoColor.textPrimary
    }

    private var dotColor: Color {
        isSelected ? PratoColor.onPrimaryButton : PratoColor.accent
    }

    private var accessibilityLabel: String {
        let date = day.date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        return day.mealCount > 0 ? "\(date), \(L10n.mealCount(day.mealCount))" : date
    }
}

/// "Escolher dia": a calendar up to today. Tapping a day picks it right away.
private struct DayPickerSheet: View {

    @State private var day: Date

    private let lastDay: Date
    private let onPick: @MainActor (Date) -> Void
    private let onCancel: @MainActor () -> Void

    init(
        selectedDay: Date,
        lastDay: Date,
        onPick: @escaping @MainActor (Date) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        self._day = State(initialValue: selectedDay)
        self.lastDay = lastDay
        self.onPick = onPick
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                DatePicker(L10n.pickDay, selection: $day, in: ...lastDay, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(.horizontal, 16)
            }
            .background(PratoColor.background)
            .navigationTitle(L10n.pickDay)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(PratoColor.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.pickDayCancel) { onCancel() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(L10n.pickDayToday) { onPick(lastDay) }
                }
            }
        }
        .tint(PratoColor.accent)
        .onChange(of: day) { _, newDay in onPick(newDay) }
        .presentationDetents([.fraction(0.65), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(PratoColor.background)
    }
}

private extension String {
    /// "sexta-feira, 16 de outubro" → "Sexta-feira, 16 de outubro". Leaves the rest untouched.
    var capitalizedFirstLetter: String {
        prefix(1).uppercased() + dropFirst()
    }
}

#Preview("Semana com refeições") {
    let rice = FoodCatalog.development.foods[0]
    let chicken = FoodCatalog.development.foods[1]
    let day: TimeInterval = 86_400
    let store = InMemoryMealStore(meals: [
        Meal(kind: .lunch, date: .now.addingTimeInterval(-2 * day), portions: [FoodPortion(food: rice, grams: 150)], photo: nil),
        Meal(kind: .breakfast, date: .now.addingTimeInterval(-3600), portions: [FoodPortion(food: rice, grams: 80)], photo: nil),
        Meal(kind: .lunch, date: .now, portions: [FoodPortion(food: chicken, grams: 150)], photo: nil)
    ])
    return HistoryView(viewModel: HistoryViewModel(store: store) { _ in })
}

#Preview("Vazio, escuro") {
    HistoryView(viewModel: HistoryViewModel(store: InMemoryMealStore()) { _ in })
        .preferredColorScheme(.dark)
}
