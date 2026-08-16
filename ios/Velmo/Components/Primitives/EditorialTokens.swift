// 10x primitive: headspace/design-tokens v1
import SwiftUI

/// Velmo's single source of truth for color, type, spacing, and geometry.
@available(iOS 17.0, *)
enum AppTokens {
    static let background = Color(red: 250 / 255, green: 248 / 255, blue: 244 / 255)
    static let surface: Color = .white
    static let oatmeal = Color(red: 240 / 255, green: 233 / 255, blue: 222 / 255)
    static let ink = Color(red: 36 / 255, green: 35 / 255, blue: 33 / 255)
    static let secondaryInk = Color(red: 113 / 255, green: 108 / 255, blue: 101 / 255)
    static let mutedInk = Color(red: 156 / 255, green: 150 / 255, blue: 142 / 255)
    static let border = Color(red: 233 / 255, green: 227 / 255, blue: 219 / 255)
    static let accent = Color(red: 216 / 255, green: 111 / 255, blue: 92 / 255)
    static let accentPressed = Color(red: 185 / 255, green: 83 / 255, blue: 68 / 255)
    static let onAccent: Color = .white
    static let sage = Color(red: 159 / 255, green: 174 / 255, blue: 154 / 255)
    static let blue = Color(red: 145 / 255, green: 169 / 255, blue: 190 / 255)
    static let lavender = Color(red: 181 / 255, green: 166 / 255, blue: 201 / 255)
    static let honey = Color(red: 217 / 255, green: 178 / 255, blue: 108 / 255)

    static let cardRadius: CGFloat = 20
    static let controlRadius: CGFloat = 14
    static let mediaRadius: CGFloat = 16
    static let shadow = Color.black.opacity(0.06)

    static let displayFont = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let titleFont = Font.system(.title2, design: .rounded, weight: .bold)
    static let headlineFont = Font.system(.headline, design: .default, weight: .semibold)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
    static let symbolFont = Font.system(.body, design: .default, weight: .semibold)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 48
        static let screen: CGFloat = 20
    }

    enum Size {
        static let hitTarget: CGFloat = 44
        static let primaryButton: CGFloat = 52
        static let avatar: CGFloat = 40
        static let smallAvatar: CGFloat = 28
        static let media: CGFloat = 236
        static let compactMedia: CGFloat = 108
        static let promptMedia: CGFloat = 152
    }
}

@available(iOS 17.0, *)
struct VelmoPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTokens.headlineFont)
            .foregroundStyle(AppTokens.onAccent)
            .frame(maxWidth: .infinity)
            .frame(height: AppTokens.Size.primaryButton)
            .background(configuration.isPressed ? AppTokens.accentPressed : AppTokens.accent, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
