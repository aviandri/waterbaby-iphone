import SwiftUI

/// Bottom row of the home screen: one tappable icon per milk type with a "+" badge and caps label.
struct MilkTypeCarousel: View {
    let onSelect: (MilkType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) {
                ForEach(MilkType.allCases) { type in
                    Button {
                        onSelect(type)
                    } label: {
                        VStack(spacing: 14) {
                            MilkTypeIcon(type: type, size: 64, showsAddBadge: true)
                            Text(type.displayName)
                                .font(Theme.capsLabel)
                                .textCase(.uppercase)
                                .foregroundStyle(Theme.subtle)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .buttonStyle(CarouselItemStyle())
                    .accessibilityLabel("Log \(type.displayName)")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

private struct CarouselItemStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    MilkTypeCarousel { _ in }
}
