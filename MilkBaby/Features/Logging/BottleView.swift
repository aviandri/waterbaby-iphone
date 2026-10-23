import SwiftUI

/// Baby bottle outline: rounded teat, collar ring and a tall rounded body, in unit space.
struct BottleShape: Shape {
    /// Top of the body as a fraction of the height; milk only fills below this line.
    static let bodyTop: CGFloat = 0.22

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        let teat = CGRect(x: rect.minX + w * 0.37, y: rect.minY, width: w * 0.26, height: h * 0.16)
        path.addRoundedRect(in: teat, cornerSize: CGSize(width: w * 0.13, height: w * 0.13), style: .continuous)

        let collar = CGRect(x: rect.minX + w * 0.24, y: rect.minY + h * 0.12, width: w * 0.52, height: h * 0.12)
        path.addRoundedRect(in: collar, cornerSize: CGSize(width: w * 0.05, height: w * 0.05), style: .continuous)

        let body = CGRect(x: rect.minX, y: rect.minY + h * Self.bodyTop, width: w, height: h * (1 - Self.bodyTop))
        path.addRoundedRect(in: body, cornerSize: CGSize(width: w * 0.24, height: w * 0.24), style: .continuous)
        return path
    }
}

/// Bottle that fills from the bottom to `fraction` of its body (Waterllama's add-drink bottle).
struct BottleView: View {
    var fraction: Double
    var color: Color

    var body: some View {
        GeometryReader { geo in
            let bodyHeight = geo.size.height * (1 - BottleShape.bodyTop)
            ZStack(alignment: .bottom) {
                Rectangle().fill(Theme.silhouetteEmpty)
                Rectangle()
                    .fill(color)
                    .frame(height: bodyHeight * min(max(fraction, 0), 1))
                ticks(bodyHeight: bodyHeight)
            }
            .clipShape(BottleShape())
        }
        .aspectRatio(0.62, contentMode: .fit)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: fraction)
        .accessibilityHidden(true)
    }

    /// Measuring marks on the left side of the bottle body.
    private func ticks(bodyHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(1..<5) { index in
                Spacer(minLength: 0)
                Capsule()
                    .fill(.white.opacity(0.8))
                    .frame(width: index.isMultiple(of: 2) ? 28 : 16, height: 4)
            }
            Spacer(minLength: 0)
        }
        .frame(height: bodyHeight * 0.8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 18)
        .padding(.bottom, bodyHeight * 0.1)
    }
}

#Preview {
    HStack(spacing: 24) {
        BottleView(fraction: 0.25, color: Theme.milkCream)
        BottleView(fraction: 0.7, color: Theme.milkButter)
    }
    .padding(40)
}
