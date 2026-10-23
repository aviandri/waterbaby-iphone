import SwiftUI

/// One-shot confetti burst falling from the top of the screen. Insert it to play; it fades out
/// after `duration` and ignores touches, so the host just removes it afterwards.
struct ConfettiView: View {
    static let duration: TimeInterval = 3.2

    private struct Piece {
        var x: Double          // start position, fraction of width
        var drift: Double      // horizontal speed, points per second
        var fallSpeed: Double  // initial downward speed, points per second
        var spin: Double       // radians per second
        var flutter: Double    // flip speed for the 3D-ish wobble
        var size: CGSize
        var color: Color
    }

    @State private var start = Date.now
    @State private var pieces: [Piece]

    init(count: Int = 110) {
        let colors = MilkType.allCases.map(\.color) + [Theme.accent, Theme.capybaraBrown, Theme.milkSky]
        _pieces = State(initialValue: (0..<count).map { _ in
            Piece(
                x: .random(in: 0...1),
                drift: .random(in: -60...60),
                fallSpeed: .random(in: 40...220),
                spin: .random(in: -6...6),
                flutter: .random(in: 4...10),
                size: CGSize(width: .random(in: 6...10), height: .random(in: 10...16)),
                color: colors.randomElement() ?? Theme.accent
            )
        })
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(start)
                let gravity = 260.0
                let opacity = t < Self.duration - 0.8 ? 1 : max(0, (Self.duration - t) / 0.8)
                context.opacity = opacity

                for piece in pieces {
                    let x = piece.x * size.width + piece.drift * t
                    let y = -20 + piece.fallSpeed * t + 0.5 * gravity * t * t
                    guard y < size.height + 20 else { continue }

                    var pieceContext = context
                    pieceContext.translateBy(x: x, y: y)
                    pieceContext.rotate(by: .radians(piece.spin * t))
                    pieceContext.scaleBy(x: cos(piece.flutter * t), y: 1)
                    let rect = CGRect(
                        x: -piece.size.width / 2, y: -piece.size.height / 2,
                        width: piece.size.width, height: piece.size.height
                    )
                    pieceContext.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(piece.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    ConfettiView()
}
