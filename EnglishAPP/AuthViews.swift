import SwiftUI

struct AuthView: View {
    @State private var isLogin: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var formOffset: CGFloat = 0
    @State private var nameFieldOpacity: Double = 0
    @State private var nameFieldHeight: CGFloat = 0
    @State private var showVerificationCode: Bool = false
    @State private var registrationUsername: String = ""
    @State private var showMainApp: Bool = false
    @State private var autoFillEmail: String = ""
    @State private var autoFillPassword: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    // Logo / Title
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .foregroundColor(AppColors.primary)
                            .appShadow()
                        Text("English Learner")
                            .font(AppFonts.title(30))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, 36)

                    // Toggle
                    HStack(spacing: 10) {
                        SegmentButton(title: "登陆", isSelected: isLogin) { 
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isLogin = true
                                updateFormAnimation()
                            }
                        }
                        SegmentButton(title: "注册", isSelected: !isLogin) { 
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isLogin = false
                                updateFormAnimation()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Form Card
                    VStack(spacing: 14) {
                        // Name field with animation
                        if !isLogin {
                            TextField("昵称", text: $name)
                                .textInputAutocapitalization(.none)
                                .disableAutocorrection(true)
                                .modifier(TextFieldStyleConfig.inputField(icon: "person"))
                                .opacity(nameFieldOpacity)
                                .frame(height: nameFieldHeight)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                        
                        TextField("邮箱", text: $email)
                            .onChange(of: autoFillEmail) { newValue in
                                if !newValue.isEmpty {
                                    email = newValue
                                    autoFillEmail = ""
                                }
                            }
                            .textInputAutocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .modifier(TextFieldStyleConfig.inputField(icon: "envelope"))
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        
                        SecureField("密码", text: $password)
                            .onChange(of: autoFillPassword) { newValue in
                                if !newValue.isEmpty {
                                    password = newValue
                                    autoFillPassword = ""
                                }
                            }
                            .modifier(TextFieldStyleConfig.inputField(icon: "lock"))
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))

                        if let errorMessage { ErrorBanner(message: errorMessage) }

                        Button(action: handlePrimaryAction) {
                            HStack {
                                if isLoading { ProgressView().tint(.white) }
                                Text(isLogin ? "登 陆" : "注 册")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        if isLogin {
                            Button("忘记密码？") { /* TODO: push reset */ }
                                .font(AppFonts.caption())
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.top, 2)
                        }
                    }
                    .padding(18)
                    .glassBackground(cornerRadius: 20)
                    .appShadow()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .offset(y: formOffset)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isLogin)
                }
                .padding(.bottom, 120)
            }

            // Milky bottom
            VStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.milkyBottom)
                    .frame(height: 86)
                    .overlay(
                        HStack(spacing: 12) {
                            Circle().fill(AppColors.primary.opacity(0.12)).frame(width: 42, height: 42)
                                .overlay(Image(systemName: "book.fill").foregroundColor(AppColors.primary))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("开始你的英语学习之旅")
                                    .font(AppFonts.body(15, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("文章阅读 · 单词学习 · 场景训练")
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    )
                    .overlay(
                        Rectangle().fill(AppColors.border).frame(height: 1).frame(maxHeight: .infinity, alignment: .top)
                    )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $showMainApp) {
            UserPreferencesView()
        }
        .sheet(isPresented: $showVerificationCode) {
            VerificationCodeView(
                isPresented: $showVerificationCode,
                email: email,
                password: password,
                username: isLogin ? email : registrationUsername,
                operation: isLogin ? "login" : "register"
            ) {
                // 验证成功后的处理
                if isLogin {
                    // 登录成功，进入主应用
                    showMainApp = true
                } else {
                    // 注册成功，自动填充登录信息
                    autoFillEmail = email
                    autoFillPassword = password
                    // 切换到登录模式
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isLogin = true
                        updateFormAnimation()
                    }
                }
            }
        }
        .onChange(of: showVerificationCode) { newValue in
            if !newValue {
                // 当验证码页面关闭时，检查是否需要切换到登录模式
                if !isLogin {
                    // 如果是注册模式，切换到登录模式并填充邮箱
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isLogin = true
                        updateFormAnimation()
                    }
                }
            }
        }
    }

    private func handlePrimaryAction() {
        errorMessage = nil
        guard validateInputs() else { return }
        isLoading = true
        Task {
            do {
                if isLogin {
                    // 登录：先发送验证码
                    try await APIService.shared.sendVerificationCode(email: email, operation: "login")
                    DispatchQueue.main.async {
                        showVerificationCode = true
                    }
                } else {
                    // 注册：先发送验证码
                    registrationUsername = name
                    try await APIService.shared.sendVerificationCode(email: email, operation: "register")
                    DispatchQueue.main.async {
                        showVerificationCode = true
                    }
                }
            } catch {
                errorMessage = (error as? APIError)?.message ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    private func updateFormAnimation() {
        if isLogin {
            // 切换到登录：隐藏昵称字段
            withAnimation(.easeInOut(duration: 0.3)) {
                nameFieldOpacity = 0
                nameFieldHeight = 0
            }
            // 表单向上移动
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                formOffset = -20
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                formOffset = 0
            }
        } else {
            // 切换到注册：显示昵称字段
            withAnimation(.easeInOut(duration: 0.3)) {
                nameFieldOpacity = 1
                nameFieldHeight = 50
            }
            // 表单向下移动
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                formOffset = 20
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                formOffset = 0
            }
        }
    }

    private func validateInputs() -> Bool {
        if !isLogin && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "请输入昵称"
            return false
        }
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "请输入有效邮箱"
            return false
        }
        if password.count < 6 {
            errorMessage = "密码至少 6 位"
            return false
        }

        return true
    }
    

}

private struct SegmentButton: View {
    @State private var isPressed = false
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(AppFonts.body(15, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? 
                                    [AppColors.primary, AppColors.primaryLight] : 
                                    [Color.white, Color.white.opacity(0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear,
                            radius: isSelected ? 8 : 0,
                            x: 0,
                            y: isSelected ? 4 : 0
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isSelected ? Color.clear : AppColors.border,
                            lineWidth: isSelected ? 0 : 1.5
                        )
                )
                .scaleEffect(isSelected ? 1.05 : (isPressed ? 0.95 : 1.0))
                .offset(y: isSelected ? -2 : 0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.2), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isPressed)
    }
}

private struct ErrorBanner: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.white)
            Text(message).font(AppFonts.caption()).foregroundColor(.white)
            Spacer()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.error))
    }
}

#Preview {
    AuthView()
}


