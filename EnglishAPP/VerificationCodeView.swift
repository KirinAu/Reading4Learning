import SwiftUI

struct VerificationCodeView: View {
    @Binding var isPresented: Bool
    let email: String
    let password: String
    let username: String
    let operation: String
    let onVerificationSuccess: () -> Void
    
    @State private var code: [String] = Array(repeating: "", count: 6)
    @State private var currentIndex: Int = 0
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var countdownSeconds: Int = 0
    @State private var isSendingCode: Bool = false
    @State private var keyboardText: String = ""
    @State private var isError: Bool = false
    @State private var showSuccessView: Bool = false
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
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppFonts.caption())
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Verify Button
                        Button(action: verifyCode) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                }
                                Text("验证")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(code.joined().count != 6 || isLoading)
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
        .sheet(isPresented: $showSuccessView) {
            RegistrationSuccessView(
                isPresented: $showSuccessView,
                email: email,
                password: password,
                onBackToLogin: { email, password in
                    // 传递信息回登录页面
                    onVerificationSuccess()
                }
            )
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
    
    private func verifyCode() {
        let verificationCode = code.joined()
        guard verificationCode.count == 6 else { return }
        
        isLoading = true
        errorMessage = nil
        isError = false
        
        Task {
            do {
                switch operation {
                case "login":
                    let token = try await APIService.shared.login(email: email, password: password, verificationCode: verificationCode)
                    UserDefaults.standard.set(token, forKey: "userToken")
                    
                case "register":
                    _ = try await APIService.shared.register(username: username, email: email, password: password, verificationCode: verificationCode)
                    
                case "reset":
                    _ = try await APIService.shared.resetPassword(email: email, password: "", confirmPassword: "", verificationCode: verificationCode)
                    
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    isLoading = false
                    isError = false
                    if operation == "register" {
                        showSuccessView = true
                    } else {
                        onVerificationSuccess()
                        isPresented = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    isError = true
                    
                    // 显示错误弹窗
                    errorAlertMessage = (error as? APIError)?.message ?? "验证失败"
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
                try await APIService.shared.sendVerificationCode(email: email, operation: operation)
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
        
        // 自动提交验证码
        if limitedNumbers.count == 6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                verifyCode()
            }
        }
        
        // 更新当前选中索引
        currentIndex = min(limitedNumbers.count, 5)
        
        // 重置错误状态
        if !limitedNumbers.isEmpty {
            isError = false
        }
    }
}

struct CodeInputBox: View {
    @Binding var text: String
    let isSelected: Bool
    let onTap: () -> Void
    let isError: Bool
    
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        Button(action: onTap) {
            Text(text.isEmpty ? "" : text)
                .font(AppFonts.title(24))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 50, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    isError ? Color.red : (isSelected ? AppColors.primary : AppColors.border),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .shadow(
                    color: isError ? Color.red.opacity(0.2) : (isSelected ? AppColors.primary.opacity(0.2) : Color.clear),
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .offset(x: shakeOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onChange(of: isError) { newValue in
            if newValue {
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.1)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.1)) {
                        shakeOffset = -10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.1)) {
                        shakeOffset = 10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.1)) {
                        shakeOffset = 0
                    }
                }
            }
        }
    }
}

#Preview {
    VerificationCodeView(
        isPresented: .constant(true),
        email: "test@example.com",
        password: "password123",
        username: "testuser",
        operation: "login"
    ) {
        print("Verification successful")
    }
}
