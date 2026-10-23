import SwiftUI

/// Horizontal snapping carousel of amounts; the centred one is selected, neighbours peek in grey.
struct AmountPicker: View {
    let amountsML: [Double]
    @Binding var selectedML: Double
    var unit: VolumeUnit

    /// Mirrors the centred item while scrolling. Starts nil: on iOS 17 an initial value is not
    /// applied before first layout, so the initial centring is done with `ScrollViewReader`.
    @State private var scrolledID: Double?
    /// False until the selection has been scrolled to the centre, so the ScrollView's resting
    /// position (first item) can never overwrite `selectedML`.
    @State private var isPositioned = false
    private let itemWidth: CGFloat = 170

    init(amountsML: [Double], selectedML: Binding<Double>, unit: VolumeUnit) {
        self.amountsML = amountsML
        self._selectedML = selectedML
        self.unit = unit
    }

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(amountsML, id: \.self) { ml in
                            Text(unit.format(ml))
                                .font(Theme.rounded(36))
                                .foregroundStyle(ml == selectedML ? Theme.ink : Theme.subtle.opacity(0.5))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .frame(width: itemWidth)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.snappy) { scrolledID = ml }
                                }
                                .id(ml)
                                .accessibilityAddTraits(ml == selectedML ? .isSelected : [])
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledID, anchor: .center)
                .safeAreaPadding(.horizontal, max(0, (geo.size.width - itemWidth) / 2))
                .task(id: geo.size.width) { @MainActor in
                    guard geo.size.width > 0 else { return }
                    // Let the layout with the final safe-area padding land before scrolling.
                    await Task.yield()
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        proxy.scrollTo(selectedML, anchor: .center)
                    }
                    scrolledID = selectedML
                    isPositioned = true
                }
            }
        }
        .frame(height: 56)
        .sensoryFeedback(.selection, trigger: selectedML)
        .onChange(of: scrolledID) { _, new in
            guard isPositioned, let new, new != selectedML else { return }
            selectedML = new
        }
        .onChange(of: selectedML) { _, new in
            if scrolledID != new { withAnimation(.snappy) { scrolledID = new } }
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
