import SwiftUI

struct ResetPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showVerificationCode: Bool = false
    @State private var countdownSeconds: Int = 0
    @State private var isSendingCode: Bool = false
    
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title
                        VStack(spacing: 12) {
                            Text("重置密码")
                                .font(AppFonts.title(28))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("请输入您的邮箱地址，我们将发送验证码帮您重置密码")
                                .font(AppFonts.body(16))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            TextField("邮箱", text: $email)
                                .textInputAutocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                                .modifier(TextFieldStyleConfig.inputField(icon: "envelope"))
                            
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
                            
                            Button(action: sendVerificationCode) {
                                HStack {
                                    if isSendingCode {
                                        ProgressView().tint(.white)
                                    }
                                    Text("发送验证码")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(email.isEmpty || !email.contains("@") || countdownSeconds > 0 || isSendingCode)
                        }
                        .padding(.horizontal, 20)
                        
                        // Resend Info
                        if countdownSeconds > 0 {
                            VStack(spacing: 8) {
                                Text("\(countdownSeconds)秒后可重新发送")
                                    .font(AppFonts.caption())
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showVerificationCode) {
            ResetPasswordVerificationView(
                isPresented: $showVerificationCode,
                email: email
            ) {
                // 重置密码成功
                isPresented = false
            }
        }
    }
    
    private func sendVerificationCode() {
        guard !email.isEmpty && email.contains("@") else {
            errorMessage = "请输入有效邮箱"
            return
        }
        
        errorMessage = nil
        isSendingCode = true
        
        Task {
            do {
                try await APIService.shared.sendVerificationCode(email: email, operation: "reset")
                DispatchQueue.main.async {
                    isSendingCode = false
                    startCountdown()
                    showVerificationCode = true
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
}

#Preview {
    ResetPasswordView(isPresented: .constant(true))
}
