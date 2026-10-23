import SwiftUI

/// Horizontal snapping carousel of amounts; the centred one is selected, neighbours peek in grey.
///
/// The selection follows the scroll live (Waterllama-style): each item reports its centre through
/// a preference, and whichever is nearest the middle is committed to `selectedML` as it passes, so
/// a swipe has already selected its value by the time it stops. `.scrollPosition(id:)` isn't used:
/// on iOS 17 it stops tracking user scrolls after a programmatic `scrollTo`.
struct AmountPicker: View {
    let amountsML: [Double]
    @Binding var selectedML: Double
    var unit: VolumeUnit

    /// False until the selection has first been scrolled to the centre, so the ScrollView's
    /// resting position (first item centred) is never committed as the selection.
    @State private var isPositioned = false
    /// Set while the picker scrolls itself to this amount; items passed on the way aren't committed.
    @State private var scrollTarget: Double?
    @State private var scrollTargetDeadline = Date.distantPast
    /// The value the user's own scrolling just committed, so `onChange(of: selectedML)` can tell it
    /// apart from outside changes (a tap, the bottle drag) that need a programmatic scroll.
    @State private var userCommittedML: Double?

    private static let coordinateSpace = "amountPicker"
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
                            item(ml)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, max(0, (geo.size.width - itemWidth) / 2))
                .accessibilityIdentifier("amountPicker")
                .onPreferenceChange(ItemCentersKey.self) { centers in
                    commitNearest(to: geo.size.width / 2, in: centers)
                }
                .onChange(of: selectedML) { _, new in
                    if new == userCommittedML {
                        userCommittedML = nil
                        return
                    }
                    scroll(proxy, to: new, animated: true)
                }
                .task(id: geo.size.width) { @MainActor in
                    guard geo.size.width > 0 else { return }
                    // Let the layout with the final safe-area padding land before scrolling.
                    await Task.yield()
                    scroll(proxy, to: selectedML, animated: false)
                    isPositioned = true
                }
            }
        }
        .coordinateSpace(.named(Self.coordinateSpace))
        .frame(height: 56)
        .sensoryFeedback(.selection, trigger: selectedML)
    }

    private func item(_ ml: Double) -> some View {
        Text(unit.format(ml))
            .font(Theme.rounded(36))
            .foregroundStyle(ml == selectedML ? Theme.ink : Theme.subtle.opacity(0.5))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(width: itemWidth)
            .contentShape(Rectangle())
            .background {
                GeometryReader { itemGeo in
                    Color.clear.preference(
                        key: ItemCentersKey.self,
                        value: [ml: itemGeo.frame(in: .named(Self.coordinateSpace)).midX]
                    )
                }
            }
            .onTapGesture { selectedML = ml }
            .id(ml)
            .accessibilityAddTraits(ml == selectedML ? .isSelected : [])
    }

    private func scroll(_ proxy: ScrollViewProxy, to ml: Double, animated: Bool) {
        scrollTarget = ml
        scrollTargetDeadline = .now.addingTimeInterval(animated ? 0.6 : 1)
        if animated {
            withAnimation(.snappy) { proxy.scrollTo(ml, anchor: .center) }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { proxy.scrollTo(ml, anchor: .center) }
        }
    }

    /// Selects the item nearest the middle, unless the picker is still scrolling itself somewhere.
    private func commitNearest(to center: CGFloat, in centers: [Double: CGFloat]) {
        guard isPositioned,
              let nearest = centers.min(by: { abs($0.value - center) < abs($1.value - center) })?.key
        else { return }
        if let target = scrollTarget {
            guard nearest == target || Date.now > scrollTargetDeadline else { return }
            scrollTarget = nil
            if nearest == target { return }
        }
        guard nearest != selectedML else { return }
        userCommittedML = nearest
        selectedML = nearest
    }
}

/// Each picker item's horizontal centre in the picker's coordinate space, keyed by amount.
private struct ItemCentersKey: PreferenceKey {
    static let defaultValue: [Double: CGFloat] = [:]

    static func reduce(value: inout [Double: CGFloat], nextValue: () -> [Double: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

private struct AmountPickerPreview: View {
    @State private var selected: Double = 90

    var body: some View {
        VStack {
            AmountPicker(amountsML: MilkType.breastMilk.presetsML, selectedML: $selected, unit: .ml)
            Text("Selected \(Int(selected))ml")
            Button("Select 150ml from outside") { selected = 150 }
        }
    }
}

#Preview {
    AmountPickerPreview()
}
