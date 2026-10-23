import SwiftUI

/// Shared look: white background, rounded heavy type, soft pastel milk colours, pill buttons.
enum Theme {
    // Brand
    static let capybaraBrown = Color(red: 0.69, green: 0.49, blue: 0.33)   // #B07D54
    static let capybaraDark = Color(red: 0.42, green: 0.28, blue: 0.18)    // #6B472E
    static let ink = Color(red: 0.16, green: 0.20, blue: 0.27)             // #293445, Waterllama-style navy text
    static let accent = Color(red: 0.96, green: 0.62, blue: 0.45)          // #F59E73, warm peach CTA
    static let subtle = Color(red: 0.62, green: 0.64, blue: 0.68)          // grey captions
    static let silhouetteEmpty = Color(red: 0.94, green: 0.94, blue: 0.95) // #EFEFF2 unfilled mascot
    static let danger = Color(red: 0.93, green: 0.36, blue: 0.45)

    // Milk types
    static let milkCream = Color(red: 0.99, green: 0.89, blue: 0.72)       // #FDE3B8
    static let milkPeach = Color(red: 0.98, green: 0.76, blue: 0.62)       // #FAC29E
    static let milkButter = Color(red: 0.99, green: 0.84, blue: 0.43)      // #FDD66E
    static let milkSky = Color(red: 0.58, green: 0.81, blue: 0.93)         // #94CFED

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// All-caps small label used under icons and on buttons ("BREAST MILK", "ADD MISSED FEED").
    static let capsLabel = Font.system(size: 13, weight: .heavy, design: .rounded)
}

/// Large filled pill, e.g. "GET STARTED" (dark) or "+ FORMULA" (tinted).
struct PillButtonStyle: ButtonStyle {
    var background: Color = Theme.ink
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.rounded(18))
            .textCase(.uppercase)
            .foregroundStyle(foreground)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(background, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

/// Soft tinted capsule, e.g. "ADD MISSED FEED".
struct SoftPillButtonStyle: ButtonStyle {
    var tint: Color = Theme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.capsLabel)
            .textCase(.uppercase)
            .foregroundStyle(tint)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(tint.opacity(0.15), in: Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Grey circular "×" close button used at the top-right of every sheet.
struct CloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.gray.opacity(0.35), in: Circle())
        }
        .accessibilityLabel("Close")
    }
}
