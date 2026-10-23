import SwiftUI

/// Proportions of the baby bottle as fractions of its frame, shared by the part shapes, the milk
/// fill and the measuring marks so they all line up.
private enum Bottle {
    static let aspectRatio: CGFloat = 0.6
    static let collarTop: CGFloat = 0.15
    static let collarBottom: CGFloat = 0.27
    static let collarInset: CGFloat = 0.17
    /// The body is this much narrower on each side where it meets the collar.
    static let shoulderInset: CGFloat = 0.19
    /// Where the shoulders reach full width.
    static let shoulderBottom: CGFloat = 0.40
    /// Milk at 100% reaches this line, just below the collar.
    static let fillTop: CGFloat = 0.31
    /// Bottom corner radius, as a fraction of the width.
    static let cornerRadius: CGFloat = 0.2
}

/// Rounded teat: a dome on a short neck that flares out under the collar.
struct BottleTeatShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let neckHalf = w * 0.085
        let baseHalf = w * 0.15
        let neckY = rect.minY + h * 0.06
        let baseY = rect.minY + h * (Bottle.collarTop + 0.02)
        // A cubic with both controls at this height peaks at exactly rect.minY.
        let domeControlY = neckY - (neckY - rect.minY) / 0.75

        var path = Path()
        path.move(to: CGPoint(x: cx - baseHalf, y: baseY))
        path.addQuadCurve(to: CGPoint(x: cx - neckHalf, y: neckY), control: CGPoint(x: cx - neckHalf, y: baseY))
        path.addCurve(
            to: CGPoint(x: cx + neckHalf, y: neckY),
            control1: CGPoint(x: cx - w * 0.16, y: domeControlY),
            control2: CGPoint(x: cx + w * 0.16, y: domeControlY)
        )
        path.addQuadCurve(to: CGPoint(x: cx + baseHalf, y: baseY), control: CGPoint(x: cx + neckHalf, y: baseY))
        path.closeSubpath()
        return path
    }
}

/// Screw-on collar ring (the cap).
struct BottleCollarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let ring = CGRect(
            x: rect.minX + w * Bottle.collarInset,
            y: rect.minY + h * Bottle.collarTop,
            width: w * (1 - 2 * Bottle.collarInset),
            height: h * (Bottle.collarBottom - Bottle.collarTop)
        )
        return Path(roundedRect: ring, cornerRadius: w * 0.05, style: .continuous)
    }
}

/// Bottle body: narrower at the top, softly rounded shoulders, rounded bottom corners.
struct BottleBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let top = rect.minY + h * Bottle.collarBottom - 2 // tucked under the collar
        let shoulder = rect.minY + h * Bottle.shoulderBottom
        let inset = w * Bottle.shoulderInset
        let radius = w * Bottle.cornerRadius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + inset, y: top))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: top))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: shoulder), control: CGPoint(x: rect.maxX, y: top))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - radius), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: shoulder))
        path.addQuadCurve(to: CGPoint(x: rect.minX + inset, y: top), control: CGPoint(x: rect.minX, y: top))
        path.closeSubpath()
        return path
    }
}

/// Milk from the bottom of the frame up to `level` of the fillable height, with a gentle wave on
/// top. Animates its level so the spring moves the surface smoothly.
struct MilkFillShape: Shape {
    var level: Double

    var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clamped = min(max(level, 0), 1)
        guard clamped > 0 else { return Path() }
        let fillable = rect.height * (1 - Bottle.fillTop)
        let surface = rect.maxY - fillable * clamped
        // Flatten the wave when there's only a little milk.
        let amplitude = min(4, fillable * clamped / 6)
        let w = rect.width

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: surface))
        path.addCurve(
            to: CGPoint(x: rect.minX + w / 2, y: surface),
            control1: CGPoint(x: rect.minX + w * 0.17, y: surface - amplitude * 2),
            control2: CGPoint(x: rect.minX + w * 0.33, y: surface + amplitude * 2)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: surface),
            control1: CGPoint(x: rect.minX + w * 0.67, y: surface - amplitude * 2),
            control2: CGPoint(x: rect.minX + w * 0.83, y: surface + amplitude * 2)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Flat pastel baby bottle in the v2 capybara style that fills from the bottom to `fraction`.
/// Pass `capacityML` (what a full bottle holds) to get labelled measuring marks in `unit`;
/// without it the marks are unlabelled.
///
/// Pass `selection` and `steps` (plus `capacityML`) to make it interactive: dragging up or down
/// changes the amount by the distance dragged, snapped to the nearest step, and VoiceOver can
/// adjust it as an element identified as "bottle".
struct BottleView: View {
    var fraction: Double
    var color: Color
    var capacityML: Double?
    var unit: VolumeUnit
    var selection: Binding<Double>?
    var steps: [Double]

    /// The amount when the current drag began; the drag moves relative to it, so a touch or a tiny
    /// drag never jumps the value to wherever the finger landed.
    @State private var dragStartML: Double?

    private let lineWidth: CGFloat = 2.5

    init(
        fraction: Double,
        color: Color,
        capacityML: Double? = nil,
        unit: VolumeUnit = .ml,
        selection: Binding<Double>? = nil,
        steps: [Double] = []
    ) {
        self.fraction = fraction
        self.color = color
        self.capacityML = capacityML
        self.unit = unit
        self.selection = selection
        self.steps = steps.sorted()
    }

    private var isInteractive: Bool {
        selection != nil && !steps.isEmpty && (capacityML ?? 0) > 0
    }

    var body: some View {
        ZStack {
            BottleTeatShape()
                .fill(Theme.milkCream)
                .overlay(BottleTeatShape().stroke(Theme.outline, style: outlineStyle))

            ZStack {
                Color.white
                MilkFillShape(level: fraction)
                    .fill(color)
                marksAndShine
            }
            .clipShape(BottleBodyShape())
            .overlay(BottleBodyShape().stroke(Theme.outline, style: outlineStyle))

            BottleCollarShape()
                .fill(Theme.bottlePink)
                .overlay(BottleCollarShape().stroke(Theme.outline, style: outlineStyle))
        }
        .padding(lineWidth / 2)
        .aspectRatio(Bottle.aspectRatio, contentMode: .fit)
        .overlay {
            GeometryReader { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(dragGesture(height: geo.size.height))
            }
            .allowsHitTesting(isInteractive)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: fraction)
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(!isInteractive)
        .accessibilityLabel("Bottle")
        .accessibilityValue(selection.map { unit.format($0.wrappedValue) } ?? "")
        .accessibilityHint("Swipe up or down to change the amount")
        .accessibilityIdentifier("bottle")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: step(by: 1)
            case .decrement: step(by: -1)
            @unknown default: break
            }
        }
    }

    /// Vertical drag: moving the full height of the fill area spans the whole capacity.
    private func dragGesture(height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard let selection, let capacityML, capacityML > 0, height > 0 else { return }
                let start = dragStartML ?? selection.wrappedValue
                if dragStartML == nil { dragStartML = start }
                let fillableHeight = height * (1 - Bottle.fillTop)
                let ml = start - value.translation.height / fillableHeight * capacityML
                guard let nearest = steps.min(by: { abs($0 - ml) < abs($1 - ml) }) else { return }
                if nearest != selection.wrappedValue { selection.wrappedValue = nearest }
            }
            .onEnded { _ in dragStartML = nil }
    }

    /// Moves the selection to the next or previous step (VoiceOver swipe up/down).
    private func step(by offset: Int) {
        guard let selection, !steps.isEmpty else { return }
        let current = selection.wrappedValue
        let index = offset > 0
            ? steps.firstIndex(where: { $0 > current })
            : steps.lastIndex(where: { $0 < current })
        if let index { selection.wrappedValue = steps[index] }
    }

    private var outlineStyle: StrokeStyle {
        StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
    }

    /// Measuring marks as fractions of a full bottle, with labels when the capacity is known.
    private var marks: [(fraction: Double, label: String?)] {
        guard let capacityML, capacityML > 0 else {
            return [0.2, 0.4, 0.6, 0.8].map { ($0, nil) }
        }
        let capacity = unit.fromML(capacityML)
        let steps: [Double] = unit == .ml ? [30, 60, 120, 240] : [1, 2, 4, 8]
        let step = steps.first { capacity / $0 <= 8 } ?? steps[steps.count - 1]
        return stride(from: step, to: capacity * 0.97, by: step).map { value in
            (value / capacity, unit == .ml ? "\(Int(value))ml" : "\(Int(value))oz")
        }
    }

    /// Ticks with small labels on the left, and a soft highlight on the right.
    private var marksAndShine: some View {
        Canvas { context, size in
            let fillable = size.height * (1 - Bottle.fillTop)
            let tickX = size.width * 0.1
            let tickLength = size.width * 0.09
            let tickColor = Theme.outline.opacity(0.55)

            for mark in marks {
                let y = size.height - fillable * mark.fraction
                var tick = Path()
                tick.move(to: CGPoint(x: tickX, y: y))
                tick.addLine(to: CGPoint(x: tickX + tickLength, y: y))
                context.stroke(tick, with: .color(tickColor), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                if let label = mark.label {
                    let text = Text(label)
                        .font(Theme.rounded(11, .bold))
                        .foregroundColor(Theme.outline.opacity(0.8))
                    context.draw(text, at: CGPoint(x: tickX + tickLength + 5, y: y), anchor: .leading)
                }
            }

            let shine = CGRect(
                x: size.width * 0.8, y: size.height * 0.46,
                width: size.width * 0.05, height: size.height * 0.3
            )
            context.fill(
                Path(roundedRect: shine, cornerRadius: shine.width / 2),
                with: .color(.white.opacity(0.65))
            )
        }
    }
}

#Preview("Fill levels") {
    HStack(spacing: 16) {
        ForEach(Array(MilkType.allCases.enumerated()), id: \.element) { index, type in
            let capacity = (type.presetsML.max() ?? 240) * 1.25
            BottleView(
                fraction: [0.15, 0.4, 0.65, 0.95][index],
                color: type.color,
                capacityML: capacity
            )
        }
    }
    .padding(20)
}

private struct DraggableBottlePreview: View {
    @State private var selected: Double = 120
    private let steps: [Double] = MilkType.formula.presetsML

    var body: some View {
        VStack(spacing: 16) {
            BottleView(
                fraction: selected / 300,
                color: Theme.milkButter,
                capacityML: 300,
                selection: $selected,
                steps: steps
            )
            .frame(maxHeight: 380)
            AmountPicker(amountsML: steps, selectedML: $selected, unit: .ml)
        }
        .padding(.vertical, 40)
    }
}

#Preview("Drag to fill") {
    DraggableBottlePreview()
}

#Preview("Large, oz") {
    BottleView(fraction: 0.5, color: Theme.milkButter, capacityML: 300, unit: .oz)
        .frame(maxHeight: 380)
        .padding(40)
}
