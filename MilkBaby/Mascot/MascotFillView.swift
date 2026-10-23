import SwiftUI

/// The home-screen capybara: an empty silhouette in `Theme.silhouetteEmpty` that fills bottom-up with
/// one coloured band per segment (in array order), like Waterllama's per-drink layers. The total is
/// clamped to 100%, band heights spring to new values, and the band edges ripple gently.
struct MascotFillView: View {
    var segments: [FillSegment]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Seconds for the surface wave to travel one full period.
    private static let wavePeriod = 4.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Self.wavePeriod) / Self.wavePeriod
            ZStack {
                Theme.silhouetteEmpty
                // Highest band first so each lower band paints over the part below its neighbour's edge.
                ForEach(Array(bands.reversed())) { band in
                    FillBand(level: band.level, phase: phase)
                        .fill(band.color)
                        .transition(.opacity)
                }
            }
            .clipShape(CapybaraSilhouette())
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: segments)
        }
        .aspectRatio(CapybaraSilhouette.aspect, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Capybara \(Int((total * 100).rounded()))% full")
    }

    private struct Band: Identifiable {
        let id: String
        let color: Color
        /// Cumulative fill (0...1) at this band's top edge.
        let level: Double
    }

    private var bands: [Band] {
        var level = 0.0
        return segments.map { segment in
            level = min(1, level + max(0, segment.fraction))
            return Band(id: segment.id, color: segment.color, level: level)
        }
    }

    private var total: Double {
        min(1, segments.reduce(0) { $0 + max(0, $1.fraction) })
    }
}

/// Everything below a gently waving line at `level` (0 = feet, 1 = ear tip) of the capybara.
private struct FillBand: Shape {
    var level: Double
    var phase: Double

    var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard level > 0 else { return Path() }
        let amplitude = rect.height * 0.012
        let extent = CapybaraSilhouette.verticalExtent
        let bottom = rect.minY + rect.height * extent.upperBound
        // At 100% the wave troughs sit above the ear tip, so a full capybara has no gap at the top.
        let top = rect.minY + rect.height * extent.lowerBound - amplitude
        let surface = bottom - (bottom - top) * level
        let steps = 32

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        for step in 0...steps {
            let progress = Double(step) / Double(steps)
            let angle = (progress * 2 + phase) * 2 * .pi
            path.addLine(to: CGPoint(x: rect.minX + rect.width * progress, y: surface + amplitude * sin(angle)))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("Layered") {
    MascotFillView(segments: [
        FillSegment(id: MilkType.breastMilk.rawValue, color: MilkType.breastMilk.color, fraction: 0.25),
        FillSegment(id: MilkType.formula.rawValue, color: MilkType.formula.color, fraction: 0.3),
        FillSegment(id: MilkType.wholeMilk.rawValue, color: MilkType.wholeMilk.color, fraction: 0.15),
    ])
    .padding()
}

#Preview("Interactive") {
    MascotFillDemo()
}

/// Preview harness: tap a milk type to add 10% of the goal in that colour.
private struct MascotFillDemo: View {
    @State private var fractions: [MilkType: Double] = [:]

    var body: some View {
        VStack(spacing: 24) {
            MascotFillView(segments: MilkType.allCases.compactMap { type in
                fractions[type].map { FillSegment(id: type.rawValue, color: type.color, fraction: $0) }
            })
            HStack {
                ForEach(MilkType.allCases) { type in
                    Button { fractions[type, default: 0] += 0.1 } label: {
                        Image(systemName: type.symbolName)
                            .frame(width: 44, height: 44)
                            .background(type.color, in: Circle())
                    }
                }
                Button("Reset") { fractions = [:] }
            }
            .foregroundStyle(Theme.ink)
        }
        .padding()
    }
}
