import SwiftUI

/// "Custom amount" sheet: big typed value, the tinted "+ TYPE" pill and an in-app keypad.
struct CustomAmountSheet: View {
    let type: MilkType
    let unit: VolumeUnit
    /// Called with the entered amount converted to millilitres.
    let onAdd: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    private var value: Double { Double(text) ?? 0 }
    private var maxValue: Double { unit == .ml ? 2000 : 64 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                CloseButton { dismiss() }
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(text.isEmpty ? "0" : text)
                    .foregroundStyle(text.isEmpty ? Theme.subtle : Theme.ink)
                    .contentTransition(.numericText())
                Text(unit.rawValue)
                    .foregroundStyle(Theme.ink)
            }
            .font(Theme.rounded(52))
            .animation(.snappy, value: text)

            Text("Custom amount")
                .font(Theme.rounded(15, .bold))
                .foregroundStyle(Theme.subtle)
                .padding(.top, 4)

            Button {
                onAdd(unit.toML(value))
            } label: {
                Text("+ \(type.displayName)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(PillButtonStyle(background: type.color, foreground: Theme.ink))
            .disabled(value <= 0)
            .opacity(value > 0 ? 1 : 0.5)
            .accessibilityIdentifier("customAmountAddButton")
            .padding(.top, 24)
            .padding(.bottom, 24)

            AmountKeypad(allowsDecimal: unit == .oz, onKey: handle)
        }
        .padding(20)
        .presentationDetents([.height(580)])
        .presentationCornerRadius(32)
    }

    private func handle(_ key: AmountKeypad.Key) {
        var next = text
        switch key {
        case .digit(let digit):
            if next == "0" { next = "" }
            if let dot = next.firstIndex(of: "."), next.distance(from: dot, to: next.endIndex) > 1 { return }
            next.append(String(digit))
        case .decimal:
            guard !next.contains(".") else { return }
            next = next.isEmpty ? "0." : next + "."
        case .delete:
            if !next.isEmpty { next.removeLast() }
        }
        guard (Double(next) ?? 0) <= maxValue else { return }
        text = next
    }
}

/// 3×4 number pad matching the iOS keypad layout, drawn in the app's rounded style.
struct AmountKeypad: View {
    enum Key: Hashable {
        case digit(Int)
        case decimal
        case delete
    }

    var allowsDecimal: Bool
    let onKey: (Key) -> Void

    private var rows: [[Key?]] {
        [
            [.digit(1), .digit(2), .digit(3)],
            [.digit(4), .digit(5), .digit(6)],
            [.digit(7), .digit(8), .digit(9)],
            [allowsDecimal ? .decimal : nil, .digit(0), .delete],
        ]
    }

    var body: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(rows.indices, id: \.self) { row in
                GridRow {
                    ForEach(rows[row].indices, id: \.self) { column in
                        if let key = rows[row][column] {
                            keyButton(key)
                        } else {
                            Color.clear.frame(height: 52)
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
    }

    @State private var tapCount = 0

    private func keyButton(_ key: Key) -> some View {
        Button {
            tapCount += 1
            onKey(key)
        } label: {
            Group {
                switch key {
                case .digit(let digit): Text("\(digit)")
                case .decimal: Text(".")
                case .delete: Image(systemName: "delete.left")
                }
            }
            .font(Theme.rounded(26, .semibold))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Theme.silhouetteEmpty, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: key))
    }

    private func accessibilityLabel(for key: Key) -> String {
        switch key {
        case .digit(let digit): "\(digit)"
        case .decimal: "Decimal point"
        case .delete: "Delete"
        }
    }
}

#Preview {
    Color.gray.opacity(0.3)
        .sheet(isPresented: .constant(true)) {
            CustomAmountSheet(type: .formula, unit: .ml) { _ in }
        }
}
