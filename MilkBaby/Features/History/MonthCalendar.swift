import SwiftUI

/// Month grid starting on `calendar.firstWeekday`. Goal-met days are filled peach (runs of them join
/// into one pill), partial days get a dot, today is outlined, the selected day is a dark circle.
/// Page months with the chevrons or a horizontal swipe; future months and days are disabled.
struct MonthCalendar: View {
    /// First day of the month being shown.
    @Binding var month: Date
    @Binding var selectedDay: Date
    let calendar: Calendar
    let status: (Date) -> DayStatus

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        let days = daysInGrid
        let statuses = days.map { $0.map(status) }

        VStack(spacing: 16) {
            header

            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(Theme.capsLabel)
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    if let day, let dayStatus = statuses[index] {
                        let column = index % 7
                        Button {
                            withAnimation(.snappy) { selectedDay = calendar.startOfDay(for: day) }
                        } label: {
                            DayCell(
                                number: calendar.component(.day, from: day),
                                status: dayStatus,
                                isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
                                isToday: calendar.isDateInToday(day),
                                joinsLeading: column > 0 && statuses[index - 1] == .goalMet,
                                joinsTrailing: column < 6 && index + 1 < statuses.count && statuses[index + 1] == .goalMet
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(dayStatus == .future)
                        .accessibilityLabel(accessibilityLabel(for: day, status: dayStatus))
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -50 { page(by: 1) }
                if value.translation.width > 50 { page(by: -1) }
            }
        )
    }

    private var header: some View {
        HStack {
            Button { page(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous month")
            Spacer()
            Text(monthTitle)
                .font(Theme.rounded(26))
                .foregroundStyle(Theme.ink)
                .contentTransition(.numericText())
            Spacer()
            Button { page(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!canGoForward)
            .accessibilityLabel("Next month")
        }
        .font(.system(size: 17, weight: .bold))
        .foregroundStyle(Theme.subtle)
        .padding(.horizontal, 8)
    }

    private var monthTitle: String {
        let sameYear = calendar.isDate(month, equalTo: .now, toGranularity: .year)
        return sameYear
            ? month.formatted(.dateTime.month(.wide))
            : month.formatted(.dateTime.month(.wide).year())
    }

    /// Weekday initials rotated so the week starts on `calendar.firstWeekday`.
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    /// Leading blanks (nil) followed by every day of the month.
    private var daysInGrid: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let leading = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        let days = range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
        return Array(repeating: nil, count: leading) + days
    }

    private var canGoForward: Bool {
        guard let thisMonth = calendar.dateInterval(of: .month, for: .now)?.start else { return false }
        return month < thisMonth
    }

    private func page(by months: Int) {
        guard months < 0 || canGoForward,
              let target = calendar.date(byAdding: .month, value: months, to: month) else { return }
        withAnimation(.snappy) { month = target }
    }

    private func accessibilityLabel(for day: Date, status: DayStatus) -> String {
        let date = day.formatted(date: .long, time: .omitted)
        switch status {
        case .goalMet: return "\(date), goal met"
        case .partial: return "\(date), partly fed"
        case .empty: return "\(date), no feeds"
        case .future: return date
        }
    }
}

private struct DayCell: View {
    let number: Int
    let status: DayStatus
    let isSelected: Bool
    let isToday: Bool
    let joinsLeading: Bool
    let joinsTrailing: Bool

    var body: some View {
        ZStack {
            if status == .goalMet {
                UnevenRoundedRectangle(
                    topLeadingRadius: joinsLeading ? 0 : 20,
                    bottomLeadingRadius: joinsLeading ? 0 : 20,
                    bottomTrailingRadius: joinsTrailing ? 0 : 20,
                    topTrailingRadius: joinsTrailing ? 0 : 20,
                    style: .continuous
                )
                .fill(Theme.accent)
            }
            if isSelected {
                Circle().fill(Theme.ink).padding(2)
            } else if isToday {
                Circle().strokeBorder(Theme.ink, lineWidth: 2).padding(2)
            }

            Text("\(number)")
                .font(Theme.rounded(16, .bold))
                .foregroundStyle(textColor)

            if status == .partial && !isSelected {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 5, height: 5)
                    .offset(y: 13)
            }
        }
        .frame(height: 40)
        .contentShape(Rectangle())
    }

    private var textColor: Color {
        if isSelected || status == .goalMet { return .white }
        switch status {
        case .future: return Theme.subtle.opacity(0.45)
        case .empty: return Theme.subtle
        case .partial, .goalMet: return Theme.ink
        }
    }
}

#Preview {
    MonthCalendar(
        month: .constant(Calendar.current.dateInterval(of: .month, for: .now)!.start),
        selectedDay: .constant(.now),
        calendar: Calendar.current,
        status: { day in
            let n = Calendar.current.component(.day, from: day)
            if day > .now { return .future }
            return n % 5 == 0 ? .empty : n % 3 == 0 ? .partial : .goalMet
        }
    )
    .padding()
}
