//
//  EnglishAPPApp.swift
//  EnglishAPP
//
//  Created by Kirin Au on 2025/8/20.
//

import SwiftUI

@main
struct EnglishAPPApp: App {
    init() {
        // 临时禁用ATS（仅用于开发测试）
        UserDefaults.standard.set(true, forKey: "NSAppTransportSecurityAllowsArbitraryLoads")
        
        APIService.shared.setBaseURL("http://8.148.158.113:9090") // 根据API文档设置
        
        // 开发阶段临时设置
        print("🚀 EnglishAPP 启动中...")
        print("📱 当前运行在模拟器模式")
        print("🔓 ATS已临时禁用，允许HTTP连接")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    AuthView()
}
