import SwiftUI

struct MainAppView: View {
    @State private var selectedTab: Int = 0
    @State private var showProfile: Bool = false
    @State private var showLogoutAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("English Learner")
                            .font(AppFonts.title(24))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("开始你的英语学习之旅")
                            .font(AppFonts.body(14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick Stats
                        HStack(spacing: 16) {
                            StatCard(
                                title: "学习天数",
                                value: "7",
                                icon: "calendar",
                                color: AppColors.primary
                            )
                            
                            StatCard(
                                title: "掌握单词",
                                value: "128",
                                icon: "book.fill",
                                color: AppColors.primaryLight
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Learning Modules
                        VStack(spacing: 16) {
                            Text("学习模块")
                                .font(AppFonts.title(20))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ModuleCard(
                                    title: "阅读文章",
                                    subtitle: "精选英语文章",
                                    icon: "doc.text.fill",
                                    color: [AppColors.primary, AppColors.primaryLight]
                                )
                                
                                ModuleCard(
                                    title: "情景对话",
                                    subtitle: "AI模拟对话",
                                    icon: "message.fill",
                                    color: [Color.blue, Color.blue.opacity(0.7)]
                                )
                                
                                ModuleCard(
                                    title: "单词学习",
                                    subtitle: "智能记忆",
                                    icon: "brain.head.profile",
                                    color: [Color.green, Color.green.opacity(0.7)]
                                )
                                
                                ModuleCard(
                                    title: "听力练习",
                                    subtitle: "提升听力",
                                    icon: "ear.fill",
                                    color: [Color.orange, Color.orange.opacity(0.7)]
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Daily Challenge
                        VStack(spacing: 16) {
                            HStack {
                                Text("每日挑战")
                                    .font(AppFonts.title(20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Button("查看全部") {
                                    // TODO: 跳转到挑战页面
                                }
                                .font(AppFonts.body(14))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.primary)
                            }
                            
                            DailyChallengeCard()
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Articles
                        VStack(spacing: 16) {
                            HStack {
                                Text("推荐文章")
                                    .font(AppFonts.title(20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Button("更多") {
                                    // TODO: 跳转到文章列表
                                }
                                .font(AppFonts.body(14))
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.primary)
                            }
                            
                            VStack(spacing: 12) {
                                ArticleCard(
                                    title: "The Future of AI in Education",
                                    subtitle: "How artificial intelligence is transforming learning",
                                    difficulty: "中级",
                                    readTime: "5分钟"
                                )
                                
                                ArticleCard(
                                    title: "Sustainable Living Tips",
                                    subtitle: "Simple ways to live a more eco-friendly life",
                                    difficulty: "初级",
                                    readTime: "3分钟"
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(onLogout: {
                showLogoutAlert = true
            })
        }
        .alert("退出登录", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                logout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
    }
    
    private func logout() {
        // 清除用户token和登录状态
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // 关闭当前页面，返回到登录页面
        dismiss()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppFonts.title(24))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(AppFonts.body(12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct ModuleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: [Color]
    
    var body: some View {
        Button(action: {
            // TODO: 跳转到对应模块
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(AppFonts.body(16))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(AppFonts.caption())
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: color,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color[0].opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DailyChallengeCard: View {
    var body: some View {
        Button(action: {
            // TODO: 开始每日挑战
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今日挑战")
                        .font(AppFonts.body(16))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("完成5个单词练习")
                        .font(AppFonts.body(14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index < 3 ? AppColors.primary : AppColors.border)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ArticleCard: View {
    let title: String
    let subtitle: String
    let difficulty: String
    let readTime: String
    
    var body: some View {
        Button(action: {
            // TODO: 跳转到文章详情
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(AppFonts.body(16))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(AppFonts.body(14))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        Text(difficulty)
                            .font(AppFonts.caption())
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.primary.opacity(0.1))
                            )
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(readTime)
                                .font(AppFonts.caption())
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let onLogout: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primary)
                    
                    VStack(spacing: 4) {
                        Text("用户名")
                            .font(AppFonts.title(20))
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("user@example.com")
                            .font(AppFonts.body(14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.top, 40)
                
                // Settings
                VStack(spacing: 0) {
                    SettingsRow(icon: "gear", title: "设置", action: {})
                    SettingsRow(icon: "bell", title: "通知", action: {})
                    SettingsRow(icon: "questionmark.circle", title: "帮助", action: {})
                    SettingsRow(icon: "arrow.right.square", title: "退出登录", action: {
                        onLogout()
                        dismiss()
                    })
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(AppFonts.body(16))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainAppView()
}
