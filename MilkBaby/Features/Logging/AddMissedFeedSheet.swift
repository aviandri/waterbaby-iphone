import SwiftUI
import SwiftData

/// "Add missed feed" for a given day: pick the type, the time (within that day) and the amount.
struct AddMissedFeedSheet: View {
    let day: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings

    @State private var type: MilkType = .breastMilk
    @State private var time: Date
    @State private var selectedML: Double = MilkType.breastMilk.defaultAmountML
    @State private var showCustomAmount = false

    init(day: Date) {
        self.day = day
        let calendar = Calendar.current
        let initial = calendar.isDateInToday(day)
            ? Date.now
            : calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
        self._time = State(initialValue: initial)
    }

    /// Times allowed for this day, never in the future.
    private var timeRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-60) ?? start
        return start...max(start, min(endOfDay, .now))
    }

    private var amounts: [Double] {
        Set(type.presetsML + [selectedML]).sorted()
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Add missed feed")
                    .font(Theme.rounded(24))
                    .foregroundStyle(Theme.ink)
                Spacer()
                CloseButton { dismiss() }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MilkType.allCases) { option in
                        typeChip(option)
                    }
                }
            }
            .scrollClipDisabled()

            DatePicker(selection: $time, in: timeRange, displayedComponents: .hourAndMinute) {
                Text("Time")
                    .font(Theme.rounded(17, .bold))
                    .foregroundStyle(Theme.ink)
            }

            VStack(spacing: 8) {
                AmountPicker(amountsML: amounts, selectedML: $selectedML, unit: settings.unit)
                    .id(type)
                Button("Custom amount") { showCustomAmount = true }
                    .font(Theme.rounded(14, .bold))
                    .foregroundStyle(Theme.subtle)
            }

            Button {
                save(selectedML)
            } label: {
                Text("+ \(type.displayName)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(PillButtonStyle(background: type.color, foreground: Theme.ink))
        }
        .padding(20)
        .presentationDetents([.height(470)])
        .presentationCornerRadius(32)
        .onChange(of: type) { _, newType in
            selectedML = newType.defaultAmountML
        }
        .sheet(isPresented: $showCustomAmount) {
            CustomAmountSheet(type: type, unit: settings.unit) { ml in
                showCustomAmount = false
                save(ml)
            }
        }
    }

    private func typeChip(_ option: MilkType) -> some View {
        let isSelected = option == type
        return Button {
            withAnimation(.snappy) { type = option }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.symbolName)
                Text(option.displayName)
                    .textCase(.uppercase)
            }
            .font(Theme.capsLabel)
            .foregroundStyle(Theme.ink.opacity(isSelected ? 1 : 0.6))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(option.color.opacity(isSelected ? 1 : 0.3), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func save(_ ml: Double) {
        guard ml > 0 else { return }
        let clamped = min(max(time, timeRange.lowerBound), timeRange.upperBound)
        modelContext.insert(FeedEntry(date: clamped, amountML: ml, type: type))
        FeedHaptics.success()
        dismiss()
    }
}

#Preview {
    Color.white
        .sheet(isPresented: .constant(true)) {
            AddMissedFeedSheet(day: .now)
        }
        .modelContainer(FeedPreviewData.container())
        .environment(AppSettings())
}
