//
//  ContentView.swift
//  EnglishAPP
//
//  Created by Kirin Au on 2025/8/20.
//

import SwiftUI

// 环境变量定义
private struct LogoutTriggerKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var logoutTrigger: Binding<Bool> {
        get { self[LogoutTriggerKey.self] }
        set { self[LogoutTriggerKey.self] = newValue }
    }
}

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    @State private var isLoading: Bool = true
    
    // 用于强制刷新登录状态
    @State private var refreshTrigger: Bool = false
    
    var body: some View {
        Group {
            if isLoading {
                // 启动加载页面
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                    
                    Text("EnglishAPP")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background.ignoresSafeArea())
            } else if isLoggedIn {
                // 已登录，显示主应用
                MainAppView()
            } else {
                // 未登录，显示登录页面
                AuthView()
            }
        }
        .onAppear {
            checkLoginStatus()
        }
        .onChange(of: refreshTrigger) { _ in
            checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        // 检查是否有登录token和用户信息
        let hasToken = UserDefaults.standard.string(forKey: "userToken") != nil
        let hasUserInfo = UserDefaults.standard.dictionary(forKey: "userInfo") != nil
        let isLoggedInFlag = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        // 模拟启动延迟，让用户看到启动页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoggedIn = hasToken && hasUserInfo && isLoggedInFlag
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}
