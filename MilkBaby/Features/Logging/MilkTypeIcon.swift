import SwiftUI

/// Round tinted icon for a milk type, used in the home carousel, log rows and add sheets.
struct MilkTypeIcon: View {
    let type: MilkType
    var size: CGFloat = 64
    /// Shows the small "+" badge under the icon, as on Waterllama's drink carousel.
    var showsAddBadge = false

    var body: some View {
        Circle()
            .fill(type.color)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: type.symbolName)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(Theme.ink.opacity(0.75))
            }
            .overlay(alignment: .bottom) {
                if showsAddBadge {
                    Image(systemName: "plus")
                        .font(.system(size: size * 0.18, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: size * 0.32, height: size * 0.32)
                        .background(Theme.ink.opacity(0.55), in: Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .offset(y: size * 0.12)
                }
            }
            .accessibilityHidden(true)
    }
}

extension MilkType {
    /// Amount pre-selected the first time the add sheet opens for this type.
    var defaultAmountML: Double {
        presetsML[presetsML.count / 2]
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach(MilkType.allCases) { MilkTypeIcon(type: $0, showsAddBadge: true) }
    }
}
