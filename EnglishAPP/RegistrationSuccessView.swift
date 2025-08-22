import SwiftUI

struct RegistrationSuccessView: View {
    @Binding var isPresented: Bool
    let email: String
    let password: String
    let onBackToLogin: (String, String) -> Void
    
    @State private var showAnimation: Bool = false
    @State private var showContent: Bool = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Button("完成") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .font(AppFonts.body(16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Success Animation
                VStack(spacing: 32) {
                    SimpleLottieView(animationName: "finish", size: CGSize(width: 200, height: 200))
                        .scaleEffect(showAnimation ? 1.0 : 0.8)
                        .opacity(showAnimation ? 1.0 : 0.0)
                    
                    // Success Message
                    VStack(spacing: 16) {
                        Text("注册成功！")
                            .font(AppFonts.title(28))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Text("欢迎加入 English Learner")
                            .font(AppFonts.body(16))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Back to Login Button
                Button(action: {
                    onBackToLogin(email, password)
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("返回登录")
                            .font(AppFonts.body(16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: AppColors.primary.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    RegistrationSuccessView(
        isPresented: .constant(true),
        email: "test@example.com",
        password: "password123"
    ) { email, password in
        print("Back to login with: \(email), \(password)")
    }
}

