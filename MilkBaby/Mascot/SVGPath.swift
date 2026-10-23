import SwiftUI

/// Absolute SVG path data (`M`, `L`, `H`, `V`, `C`, `Q`, `Z`) in a fixed view box.
/// The mascot artwork uses it so the Swift shapes share their exact coordinates with the
/// SVG masters in `docs/brand`: paste a `d` attribute from there and it draws the same.
struct SVGPath: Sendable {
    private enum Command: Sendable {
        case move(CGPoint)
        case line(CGPoint)
        case quad(to: CGPoint, control: CGPoint)
        case cubic(to: CGPoint, control1: CGPoint, control2: CGPoint)
        case close
    }

    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    private let commands: [Command]

    init(_ data: String) {
        commands = Self.parse(data)
    }

    /// The path in view-box coordinates.
    var path: Path {
        var path = Path()
        for command in commands {
            switch command {
            case .move(let point): path.move(to: point)
            case .line(let point): path.addLine(to: point)
            case .quad(let point, let control): path.addQuadCurve(to: point, control: control)
            case .cubic(let point, let control1, let control2):
                path.addCurve(to: point, control1: control1, control2: control2)
            case .close: path.closeSubpath()
            }
        }
        return path
    }

    /// The path stretched from a `viewBox`-sized coordinate space to fill `rect`.
    func path(in rect: CGRect, viewBox: CGSize) -> Path {
        let transform = CGAffineTransform(translationX: rect.minX, y: rect.minY)
            .scaledBy(x: rect.width / viewBox.width, y: rect.height / viewBox.height)
        return path.applying(transform)
    }

    private static func parse(_ data: String) -> [Command] {
        let tokens = tokenize(data)
        var commands: [Command] = []
        var index = 0
        var command: Character = "M"
        var current = CGPoint.zero

        func number() -> CGFloat {
            guard index < tokens.count, case .number(let value) = tokens[index] else { return 0 }
            index += 1
            return value
        }

        func point() -> CGPoint {
            let x = number()
            return CGPoint(x: x, y: number())
        }

        while index < tokens.count {
            if case .command(let letter) = tokens[index] {
                command = letter
                index += 1
            }
            switch command {
            case "M":
                current = point()
                commands.append(.move(current))
                command = "L" // extra coordinate pairs after M are implicit line-tos
            case "L":
                current = point()
                commands.append(.line(current))
            case "H":
                current.x = number()
                commands.append(.line(current))
            case "V":
                current.y = number()
                commands.append(.line(current))
            case "C":
                let control1 = point()
                let control2 = point()
                current = point()
                commands.append(.cubic(to: current, control1: control1, control2: control2))
            case "Q":
                let control = point()
                current = point()
                commands.append(.quad(to: current, control: control))
            case "Z":
                commands.append(.close)
                if index < tokens.count, case .number = tokens[index] { index += 1 }
            default:
                // Unsupported command (relative or arc): skip its arguments.
                if index < tokens.count, case .number = tokens[index] { index += 1 }
            }
        }
        return commands
    }

    private static func tokenize(_ data: String) -> [Token] {
        var tokens: [Token] = []
        var buffer = ""

        func flush() {
            if let value = Double(buffer) { tokens.append(.number(CGFloat(value))) }
            buffer = ""
        }

        for character in data {
            if character.isLetter {
                flush()
                tokens.append(.command(character))
            } else if character == "-" {
                flush()
                buffer.append(character)
            } else if character.isNumber || character == "." {
                buffer.append(character)
            } else {
                flush()
            }
        }
        flush()
        return tokens
    }
}

extension Path {
    /// The path rotated about `center`, like SVG's `rotate(angle cx cy)`.
    func rotated(by angle: Angle, around center: CGPoint) -> Path {
        applying(
            CGAffineTransform(translationX: center.x, y: center.y)
                .rotated(by: angle.radians)
                .translatedBy(x: -center.x, y: -center.y)
        )
    }
}
