import SwiftUI

/// Horizontal snapping carousel of amounts; the centred one is selected, neighbours peek in grey.
struct AmountPicker: View {
    let amountsML: [Double]
    @Binding var selectedML: Double
    var unit: VolumeUnit

    @State private var scrolledID: Double?
    private let itemWidth: CGFloat = 170

    init(amountsML: [Double], selectedML: Binding<Double>, unit: VolumeUnit) {
        self.amountsML = amountsML
        self._selectedML = selectedML
        self.unit = unit
        self._scrolledID = State(initialValue: selectedML.wrappedValue)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(amountsML, id: \.self) { ml in
                        Text(unit.format(ml))
                            .font(Theme.rounded(36))
                            .foregroundStyle(ml == scrolledID ? Theme.ink : Theme.subtle.opacity(0.5))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(width: itemWidth)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.snappy) { scrolledID = ml }
                            }
                            .accessibilityAddTraits(ml == scrolledID ? .isSelected : [])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID, anchor: .center)
            .safeAreaPadding(.horizontal, max(0, (geo.size.width - itemWidth) / 2))
        }
        .frame(height: 56)
        .sensoryFeedback(.selection, trigger: scrolledID)
        .onChange(of: scrolledID) { _, new in
            if let new, new != selectedML { selectedML = new }
        }
        .onChange(of: selectedML) { _, new in
            if scrolledID != new { scrolledID = new }
        }
    }
}

private struct AmountPickerPreview: View {
    @State private var selected: Double = 90

    var body: some View {
        VStack {
            AmountPicker(amountsML: MilkType.breastMilk.presetsML, selectedML: $selected, unit: .ml)
            Text("Selected \(Int(selected))ml")
        }
    }
}

#Preview {
    AmountPickerPreview()
}
