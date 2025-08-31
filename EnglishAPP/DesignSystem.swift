import SwiftUI

struct AppColors {
    static let primary = Color(red: 0.10, green: 0.47, blue: 0.95)
    static let primaryLight = Color(red: 0.37, green: 0.67, blue: 0.98)
    static let background = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let milkyBottom = Color.white.opacity(0.85)
    static let textPrimary = Color.black.opacity(0.9)
    static let textSecondary = Color.black.opacity(0.6)
    static let textTertiary = Color.black.opacity(0.4)
    static let border = Color.black.opacity(0.08)
    static let error = Color(red: 0.95, green: 0.12, blue: 0.25)
    
    // 新增卡片相关颜色
    static let cardBackground = Color.white
    static let cardBackgroundSecondary = Color(red: 0.99, green: 0.99, blue: 0.99)
    static let cardBorder = Color.black.opacity(0.06)
    static let cardBorderHover = Color.black.opacity(0.12)
    
    // 渐变色彩
    static let gradientPrimary = LinearGradient(
        colors: [Color(red: 0.10, green: 0.47, blue: 0.95), Color(red: 0.37, green: 0.67, blue: 0.98)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientSecondary = LinearGradient(
        colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.90, green: 0.95, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppFonts {
    static func title(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight, design: .rounded) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    
    // 新增卡片专用字体
    static func cardTitle(_ size: CGFloat = 18) -> Font { .system(size: size, weight: .semibold, design: .default) }
    static func cardSubtitle(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .medium, design: .default) }
    static func cardCaption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular, design: .default) }
}

struct AppShadows {
    static let soft = ShadowStyle(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
    static let medium = ShadowStyle(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
    static let strong = ShadowStyle(color: .black.opacity(0.16), radius: 24, x: 0, y: 12)
    
    // 新增卡片专用阴影
    static let cardLight = ShadowStyle(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    static let cardMedium = ShadowStyle(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    static let cardStrong = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
    static let cardHover = ShadowStyle(color: .black.opacity(0.16), radius: 20, x: 0, y: 8)
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
    
    // 新增卡片样式扩展
    func cardStyle(
        cornerRadius: CGFloat = 16,
        shadow: ShadowStyle = AppShadows.cardMedium,
        border: Color = AppColors.cardBorder,
        background: Color = AppColors.cardBackground
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(border, lineWidth: 0.5)
                    )
            )
            .appShadow(shadow)
    }
    
    func cardHoverEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.2), value: true)
    }
}

// 新增卡片组件样式
struct CardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let shadow: ShadowStyle
    let border: Color
    let background: Color
    let isHovered: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(isHovered ? AppColors.cardBorderHover : border, lineWidth: 0.5)
                    )
            )
            .appShadow(isHovered ? AppShadows.cardHover : shadow)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
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

// 新增卡片按钮样式
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
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




