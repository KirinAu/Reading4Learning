import SwiftUI

struct ResetPasswordVerificationView: View {
    @Binding var isPresented: Bool
    let email: String
    let onSuccess: () -> Void
    
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var code: [String] = Array(repeating: "", count: 6)
    @State private var currentIndex: Int = 0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var countdownSeconds: Int = 0
    @State private var isSendingCode: Bool = false
    @State private var keyboardText: String = ""
    @State private var isError: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorAlertMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("返回") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .font(AppFonts.body(16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Button("重新发送") {
                        sendVerificationCode()
                    }
                    .font(AppFonts.body(16, weight: .medium))
                    .foregroundColor(countdownSeconds > 0 ? AppColors.textSecondary : AppColors.primary)
                    .disabled(countdownSeconds > 0 || isSendingCode)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Email Animation
                        SimpleLottieView(animationName: "Email", size: CGSize(width: 200, height: 200))
                            .padding(.top, 20)
                        
                        // Title and Description
                        VStack(spacing: 12) {
                            Text("验证码已发送")
                                .font(AppFonts.title(28))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("我们已向 \(email) 发送了验证码")
                                .font(AppFonts.body(16))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Code Input
                        VStack(spacing: 16) {
                            Text("请输入6位验证码")
                                .font(AppFonts.body(15, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(0..<6, id: \.self) { index in
                                    CodeInputBox(
                                        text: $code[index],
                                        isSelected: currentIndex == index,
                                        onTap: {
                                            currentIndex = index
                                            isTextFieldFocused = true
                                        },
                                        isError: isError
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Hidden text field for keyboard input
                            TextField("", text: $keyboardText)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.none)
                                .disableAutocorrection(true)
                                .opacity(0)
                                .frame(height: 1)
                                .focused($isTextFieldFocused)
                                .onChange(of: keyboardText) { newValue in
                                    handleKeyboardInput(newValue)
                                }
                                .onTapGesture {
                                    currentIndex = 0
                                    isTextFieldFocused = true
                                }
                        }
                        
                        // New Password Input
                        VStack(spacing: 16) {
                            Text("设置新密码")
                                .font(AppFonts.body(15, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                            
                            SecureField("新密码", text: $newPassword)
                                .modifier(TextFieldStyleConfig.inputField(icon: "lock"))
                            
                            SecureField("确认新密码", text: $confirmNewPassword)
                                .modifier(TextFieldStyleConfig.inputField(icon: "lock"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Verify Button
                        Button(action: resetPassword) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                }
                                Text("重置密码")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(code.joined().count != 6 || newPassword.isEmpty || confirmNewPassword.isEmpty || newPassword != confirmNewPassword || isLoading)
                        .padding(.horizontal, 20)
                        
                        // Resend Info
                        VStack(spacing: 8) {
                            if countdownSeconds > 0 {
                                Text("\(countdownSeconds)秒后可重新发送")
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                Text("没有收到验证码？")
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .alert("错误", isPresented: $showErrorAlert) {
            Button("确定") {
                showErrorAlert = false
            }
        } message: {
            Text(errorAlertMessage)
        }
        .onAppear {
            startCountdown()
            // 延迟一下再聚焦，确保页面完全加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    private func resetPassword() {
        let verificationCode = code.joined()
        guard verificationCode.count == 6 else { return }
        guard newPassword == confirmNewPassword else {
            errorMessage = "两次输入的密码不一致"
            return
        }
        
        isLoading = true
        errorMessage = nil
        isError = false
        
        Task {
            do {
                _ = try await APIService.shared.resetPassword(
                    email: email,
                    password: newPassword,
                    confirmPassword: confirmNewPassword,
                    verificationCode: verificationCode
                )
                
                DispatchQueue.main.async {
                    isLoading = false
                    isError = false
                    onSuccess()
                    isPresented = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    isError = true
                    
                    // 显示错误弹窗
                    errorAlertMessage = (error as? APIError)?.message ?? "重置密码失败"
                    showErrorAlert = true
                    
                    // 清空验证码输入框
                    code = Array(repeating: "", count: 6)
                    currentIndex = 0
                    keyboardText = ""
                }
            }
        }
    }
    
    private func sendVerificationCode() {
        guard countdownSeconds == 0 else { return }
        
        isSendingCode = true
        Task {
            do {
                try await APIService.shared.sendVerificationCode(email: email, operation: "reset")
                DispatchQueue.main.async {
                    isSendingCode = false
                    startCountdown()
                    code = Array(repeating: "", count: 6)
                    currentIndex = 0
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = (error as? APIError)?.message ?? "发送验证码失败"
                    isSendingCode = false
                }
            }
        }
    }
    
    private func startCountdown() {
        countdownSeconds = 60
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func handleKeyboardInput(_ input: String) {
        let numbers = input.filter { $0.isNumber }
        
        // 限制最多6位数字
        let limitedNumbers = String(numbers.prefix(6))
        
        // 更新code数组
        for (index, char) in limitedNumbers.enumerated() {
            if index < 6 {
                code[index] = String(char)
            }
        }
        
        // 清空超出6位的部分
        for index in limitedNumbers.count..<6 {
            code[index] = ""
        }
        
        // 不自动提交，让用户手动点击按钮
        
        // 更新当前选中索引
        currentIndex = min(limitedNumbers.count, 5)
        
        // 重置错误状态
        if !limitedNumbers.isEmpty {
            isError = false
        }
    }
}

#Preview {
    ResetPasswordVerificationView(
        isPresented: .constant(true),
        email: "test@example.com"
    ) {
        print("重置密码成功")
    }
}
