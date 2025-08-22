import SwiftUI

struct AppColors {
    static let primary = Color(red: 0.10, green: 0.47, blue: 0.95)
    static let primaryLight = Color(red: 0.37, green: 0.67, blue: 0.98)
    static let background = Color.white
    static let milkyBottom = Color.white.opacity(0.85)
    static let textPrimary = Color.black.opacity(0.9)
    static let textSecondary = Color.black.opacity(0.6)
    static let border = Color.black.opacity(0.08)
    static let error = Color(red: 0.95, green: 0.12, blue: 0.25)
}

struct AppFonts {
    static func title(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight, design: .rounded) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular, design: .rounded) }
}

struct AppShadows {
    static let soft = ShadowStyle(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func appShadow(_ style: ShadowStyle = AppShadows.soft) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body(17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.995 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct TextFieldStyleConfig {
    static func inputField(icon: String? = nil) -> some ViewModifier {
        InputFieldModifier(icon: icon)
    }

    private struct InputFieldModifier: ViewModifier {
        let icon: String?
        func body(content: Content) -> some View {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).foregroundColor(AppColors.textSecondary).frame(width: 18) }
                content
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }
}




