import SwiftUI
import SwiftData

/// Add-feed sheet opened from the home carousel: a bottle that fills to the chosen amount,
/// a snapping amount picker, a custom-amount keypad and the tinted "+ TYPE" pill that saves.
struct AddFeedSheet: View {
    let type: MilkType
    /// When the feed happened. `nil` means now.
    var date: Date?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings

    @State private var selectedML: Double
    /// Presets plus the remembered amount. Fixed while the sheet is open: if a remembered custom
    /// amount dropped out of the list mid-scroll, every later item would shift under the centre.
    @State private var amounts: [Double]
    @State private var showCustomAmount = false

    init(type: MilkType, date: Date? = nil) {
        self.type = type
        self.date = date
        let remembered = UserDefaults.standard.double(forKey: Self.lastAmountKey(type))
        let initial = remembered > 0 ? remembered : type.defaultAmountML
        self._selectedML = State(initialValue: initial)
        self._amounts = State(initialValue: Set(type.presetsML + [initial]).sorted())
    }

    /// The bottle holds a bit more than the largest preset, so presets never look "full".
    private var bottleCapacityML: Double {
        max((type.presetsML.max() ?? 240) * 1.25, selectedML)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                CloseButton { dismiss() }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer(minLength: 12)

            BottleView(
                fraction: selectedML / bottleCapacityML,
                color: type.color,
                capacityML: bottleCapacityML,
                unit: settings.unit,
                selection: $selectedML,
                steps: amounts
            )
                .frame(maxHeight: 380)
                .padding(.horizontal, 64)

            Spacer(minLength: 24)

            AmountPicker(amountsML: amounts, selectedML: $selectedML, unit: settings.unit)

            HStack {
                MilkTypeIcon(type: type, size: 48)

                Spacer(minLength: 12)

                Button {
                    save(selectedML)
                } label: {
                    Text("+ \(type.displayName)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .buttonStyle(PillButtonStyle(background: type.color, foreground: Theme.ink))

                Spacer(minLength: 12)

                Button {
                    showCustomAmount = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Theme.ink.opacity(0.6))
                        .frame(width: 48, height: 48)
                        .background(type.color.opacity(0.35), in: Circle())
                }
                .accessibilityLabel("Custom amount")
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
        .background(Color.white.ignoresSafeArea())
        // Dragging down on the bottle lowers the amount; it must not pull the sheet down too.
        // The close button still dismisses.
        .interactiveDismissDisabled()
        .sheet(isPresented: $showCustomAmount) {
            CustomAmountSheet(type: type, unit: settings.unit) { ml in
                showCustomAmount = false
                save(ml)
            }
        }
    }

    private func save(_ ml: Double) {
        guard ml > 0 else { return }
        modelContext.insert(FeedEntry(date: date ?? .now, amountML: ml, type: type))
        UserDefaults.standard.set(ml, forKey: Self.lastAmountKey(type))
        // Restart the repeating reminder so it fires N hours after this feed (only for feeds logged now).
        if date == nil {
            let settings = settings
            Task { await ReminderScheduler.sync(with: settings) }
        }
        FeedHaptics.success()
        dismiss()
    }

    private static func lastAmountKey(_ type: MilkType) -> String {
        "lastFeedAmountML.\(type.rawValue)"
    }
}

#Preview {
    Color.white
        .sheet(isPresented: .constant(true)) {
            AddFeedSheet(type: .formula)
        }
        .modelContainer(FeedPreviewData.container())
        .environment(AppSettings())
}
