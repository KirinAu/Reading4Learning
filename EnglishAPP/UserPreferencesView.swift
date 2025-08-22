import SwiftUI

struct UserPreferencesView: View {
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedAnswers: [Int] = Array(repeating: -1, count: 5)
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let questions = [
        Question(
            title: "你的年龄范围是？",
            options: ["12–18", "18–25", "25–35", "35+"]
        ),
        Question(
            title: "你觉得自己的英语水平？",
            options: ["初级（能看懂少量单词）", "中级（能读文章，但有难度）", "高级（能流利阅读交流）"]
        ),
        Question(
            title: "你学习英语的主要目标？",
            options: ["出国/考试", "提升口语交流", "阅读兴趣", "学业/工作需要"]
        ),
        Question(
            title: "你更喜欢哪种学习方式？",
            options: ["阅读文章", "情景对话（AI模拟）", "记单词", "听力练习"]
        ),
        Question(
            title: "你更感兴趣的内容主题？",
            options: ["校园 & 学业", "职场 & 商务", "旅行 & 日常生活", "娱乐 & 科技"]
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    if currentQuestionIndex > 0 {
                        Button("返回") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentQuestionIndex -= 1
                            }
                        }
                        .font(AppFonts.body(16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button("跳过") {
                        // 跳过所有问题，直接进入主应用
                        dismiss()
                    }
                    .font(AppFonts.body(16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Progress Bar
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Question Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Question
                        VStack(spacing: 16) {
                            Text(questions[currentQuestionIndex].title)
                                .font(AppFonts.title(28))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)
                            
                            Text("帮助我们为你推荐合适的内容")
                                .font(AppFonts.body(16))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Options
                        VStack(spacing: 16) {
                            ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                                OptionButton(
                                    text: questions[currentQuestionIndex].options[index],
                                    isSelected: selectedAnswers[currentQuestionIndex] == index,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAnswers[currentQuestionIndex] = index
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 50)
                }
                
                // Bottom Button
                VStack {
                    Button(action: handleNextButton) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                            Text(currentQuestionIndex == questions.count - 1 ? "完成" : "下一步")
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
                    )
                    .shadow(
                        color: AppColors.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedAnswers[currentQuestionIndex] == -1 || isLoading)
                    .opacity(selectedAnswers[currentQuestionIndex] == -1 ? 0.6 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func handleNextButton() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentQuestionIndex += 1
            }
        } else {
            // 完成所有问题
            enterMainApp()
        }
    }
    
    private func enterMainApp() {
        isLoading = true
        // 这里可以保存用户偏好设置到服务器
        // 然后进入主应用
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            // 关闭当前页面，返回到主应用
            dismiss()
        }
    }
}

struct Question {
    let title: String
    let options: [String]
}

struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(AppFonts.body(16))
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        isSelected ? 
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color.clear : AppColors.border,
                        lineWidth: isSelected ? 0 : 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    UserPreferencesView()
}





