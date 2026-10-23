import SwiftUI

/// Bottom row of the home screen: one tappable icon per milk type with a "+" badge and caps label.
/// All four types share the width equally, so nothing scrolls or clips, down to a 375pt iPhone SE.
struct MilkTypeCarousel: View {
    let onSelect: (MilkType) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(MilkType.allCases) { type in
                Button {
                    onSelect(type)
                } label: {
                    VStack(spacing: 14) {
                        MilkTypeIcon(type: type, size: 60, showsAddBadge: true)
                        Text(type.displayName)
                            .font(Theme.capsLabel)
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.subtle)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(CarouselItemStyle())
                .accessibilityLabel("Log \(type.displayName)")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private struct CarouselItemStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview("iPhone 15 Pro width") {
    MilkTypeCarousel { _ in }
        .frame(width: 393)
}

#Preview("iPhone SE width") {
    MilkTypeCarousel { _ in }
        .frame(width: 375)
}
