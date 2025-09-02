import SwiftUI

// MARK: - Array Extension for chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct MainAppView: View {
    @State private var selectedTab: Int = 0 // 0: 首页 1: 我的
    @State private var showLogoutAlert: Bool = false
    @State private var selectedSegment: Int = 0 // 0: 文章 1: 场景 2: 单词
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""
    @StateObject private var articlesVM = ArticlesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                                    // Top Navigation - 只在首页显示
                if selectedTab == 0 {
                    HStack(spacing: 0) {
                        TopTabButton(title: "文章", index: 0, selectedIndex: $selectedSegment)
                            .frame(maxWidth: .infinity)
                        
                        TopTabButton(title: "场景", index: 1, selectedIndex: $selectedSegment)
                            .frame(maxWidth: .infinity)
                        
                        TopTabButton(title: "单词", index: 2, selectedIndex: $selectedSegment)
                            .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            showSearch = true
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.primary)
                                
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }

                    // Main Content
                    Group {
                        if selectedTab == 0 {
                            // 首页内容
                            Group {
                                if selectedSegment == 0 {
                                    ArticleGridView(vm: articlesVM)
                                } else if selectedSegment == 1 {
                                    PlaceholderView(title: "场景", subtitle: "即将上线 · 敬请期待")
                                } else {
                                    PlaceholderView(title: "单词", subtitle: "即将上线 · 敬请期待")
                                }
                            }
                            .onAppear {
                                if articlesVM.items.isEmpty { articlesVM.reload(keyword: "") }
                            }
                            .padding(.top, 12)
                        } else {
                            // 我的页面
                            ProfileView()
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                
                // Bottom Bar 现在在 ZStack 内部，确保贴底
                VStack {
                    Spacer()
                    BottomBar(
                        onHome: { withAnimation { selectedTab = 0 } },
                        onCenter: { },
                        onProfile: { withAnimation { selectedTab = 1 } },
                        selectedTab: $selectedTab
                    )
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchSheet(text: $searchText, onSubmit: { keyword in
                articlesVM.reload(keyword: keyword)
                selectedSegment = 0
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

// MARK: - Top Tab Control

struct TopTabButton: View {
    let title: String
    let index: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 4) {
                        // 为所有标签添加Lottie动画
            if selectedIndex == index {
                switch title {
                case "文章":
                    AutoPlayLottieView(animationName: "Girl with books", size: CGSize(width: 50, height: 50))
                case "场景":
                    AutoPlayLottieView(animationName: "Dynamic Quad Cubes", size: CGSize(width: 50, height: 50))
                        .offset(x: 8) // 向右移动，靠近文字
                case "单词":
                    AutoPlayLottieView(animationName: "Document Icon Lottie Animation", size: CGSize(width: 50, height: 50))
                        .offset(x: 10) // 向右移动，靠近文字
                default:
                    EmptyView()
                }
            } else {
                // 未选中时显示占位符，保持高度一致
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 50, height: 50)
            }
            
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.3)) { 
                    selectedIndex = index 
                } 
            }) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(AppFonts.body(16))
                        .fontWeight(selectedIndex == index ? .semibold : .medium)
                        .foregroundColor(selectedIndex == index ? AppColors.primary : AppColors.textSecondary)
                    
                    Rectangle()
                        .fill(selectedIndex == index ? AppColors.primary : Color.clear)
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Detail Page Segment Control

struct DetailSegmentButton: View {
    let title: String
    let index: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        Button(action: { 
            withAnimation(.easeInOut(duration: 0.3)) { 
                selectedIndex = index 
            } 
        }) {
            Text(title)
                .font(.system(size: 15, weight: selectedIndex == index ? .semibold : .medium))
                .foregroundColor(selectedIndex == index ? .white : AppColors.textSecondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            selectedIndex == index ? 
                            AppColors.primary : 
                            Color.clear
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bottom Bar

struct BottomBar: View {
    let onHome: () -> Void
    let onCenter: () -> Void
    let onProfile: () -> Void
    @Binding var selectedTab: Int
    @State private var homeAnimationTrigger: Bool = false
    @State private var profileAnimationTrigger: Bool = false
    @State private var homeHasPlayed: Bool = false
    @State private var profileHasPlayed: Bool = false

    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                homeAnimationTrigger.toggle()
                onHome()
            }) {
                VStack(spacing: 0) {
                    ZStack {
                        // 固定尺寸的容器框
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                        
                        // Lottie动画居中显示
                        TriggerableLottieView(animationName: "Home", size: CGSize(width: 50, height: 50), trigger: $homeAnimationTrigger)
                            .onChange(of: homeAnimationTrigger) { _ in
                                homeHasPlayed = true
                                // 动画播放完成后重置trigger
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    homeAnimationTrigger = false
                                }
                            }
                    }
                    Text("首页")
                        .font(AppFonts.cardCaption(11))
                        .fontWeight(.medium)
                }
                .foregroundColor(selectedTab == 0 ? AppColors.primary : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            // 中间预留空白按钮（不可用）
            Button(action: onCenter) {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
            .frame(maxWidth: .infinity)
            .disabled(true)
            
            Button(action: {
                profileAnimationTrigger.toggle()
                onProfile()
            }) {
                VStack(spacing: 0) {
                    ZStack {
                        // 固定尺寸的容器框
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                        
                        // Lottie动画居中显示
                        TriggerableLottieView(animationName: "Profile Icon", size: CGSize(width: 30, height: 30), trigger: $profileAnimationTrigger)
                            .onChange(of: profileAnimationTrigger) { _ in
                                profileHasPlayed = true
                                // 动画播放完成后重置trigger
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    profileAnimationTrigger = false
                                }
                            }
                    }
                    Text("我的")
                        .font(AppFonts.cardCaption(11))
                        .fontWeight(.medium)
                }
                .foregroundColor(selectedTab == 1 ? AppColors.primary : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 72)

        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Search Sheet

struct SearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    let onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 搜索输入框
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                    
                    TextField("搜索文章标题或主题...", text: $text)
                        .font(AppFonts.body(16))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                        .onSubmit {
                            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                                onSubmit(text)
                                dismiss()
                            }
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.cardBorder, lineWidth: 0.5)
                        )
                )
                .appShadow(AppShadows.cardLight)
                .padding(.horizontal, 20)
                
                // 搜索建议
                VStack(alignment: .leading, spacing: 16) {
                    Text("热门搜索")
                        .font(AppFonts.cardSubtitle(16))
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(["英语学习", "商务英语", "日常对话", "旅游英语"], id: \.self) { suggestion in
                            Button(action: {
                                text = suggestion
                                onSubmit(suggestion)
                                dismiss()
                            }) {
                                Text(suggestion)
                                    .font(AppFonts.cardCaption(13))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(AppColors.cardBackgroundSecondary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(AppColors.cardBorder, lineWidth: 0.5)
                                            )
                                    )
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarTitle("搜索", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { 
                        dismiss() 
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("搜索") {
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                            onSubmit(text)
                            dismiss()
                        }
                    }
                    .foregroundColor(AppColors.primary)
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - Articles Grid

struct ArticleGridView: View {
    @ObservedObject var vm: ArticlesViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let horizontalPadding: CGFloat = 20
            let cardSpacing: CGFloat = 16
            let availableWidth = screenWidth - (horizontalPadding * 2)
            let cardWidth = (availableWidth - cardSpacing) / 2
            let cardHeight: CGFloat = 200 // 固定卡片高度，确保一致性
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    ForEach(vm.items.chunked(into: 2), id: \.first?.id) { chunk in
                        HStack(spacing: cardSpacing) {
                            ForEach(chunk, id: \.id) { item in
                                ArticleGridCard(article: item, cardWidth: cardWidth, cardHeight: cardHeight)
                                    .frame(width: cardWidth, height: cardHeight)
                                    .onAppear {
                                        if let lastItem = vm.items.last, item.id == lastItem.id {
                                            vm.loadMoreIfNeeded()
                                        }
                                    }
                            }
                            
                            // 如果这一行只有一个卡片，添加占位符保持对齐
                            if chunk.count == 1 {
                                Color.clear
                                    .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                        .frame(width: availableWidth)
                    }
                    
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
            .refreshable { await vm.pullToRefresh() }
        }
    }
}

struct ArticleGridCard: View {
    typealias Article = APIService.Article
    let article: Article
    var cardWidth: CGFloat = 0
    var cardHeight: CGFloat = 0
    @State private var isHovered: Bool = false
    
    private var viewsString: String {
        let v = article.views ?? 0
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }
    
    var body: some View {
        NavigationLink {
            ArticleDetailView(article: article)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 图片区域 - 固定高度，不会被撑大
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: article.imgUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.1)
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                    Text("加载失败")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        @unknown default:
                            Color.gray.opacity(0.1)
                        }
                    }
                    .frame(width: cardWidth - 16, height: 100) // 减小图片尺寸，留出边距
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // 图片本身的圆角
                    
                    // 右上角标签 - 毛玻璃效果
                    VStack(spacing: 2) {
                        if let topic = article.topics?.first {
                            Text(topic)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .clipShape(Capsule())
                        }
                        
                        if let duration = article.duration {
                            Text("\(duration)s")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 8) // 给图片区域添加水平边距
                .padding(.top, 8) // 给图片区域添加上边距
                
                // 内容区域
                VStack(alignment: .leading, spacing: 8) {
                    // 标题
                    Text(article.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 32, alignment: .top)
                    
                    // 标签
                    if let topics = article.topics, !topics.isEmpty {
                        HStack(spacing: 3) {
                            ForEach(topics.prefix(2), id: \.self) { topic in
                                Text(topic)
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(AppColors.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    
                    // 底部信息
                    HStack(spacing: 6) {
                        if let speaker = article.speaker, !speaker.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                Text(speaker)
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                            Text(viewsString)
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .frame(width: cardWidth, height: cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Placeholder

struct PlaceholderView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 40))
                .foregroundColor(AppColors.primary)
            Text(title)
                .font(AppFonts.title(20))
                .foregroundColor(AppColors.textPrimary)
            Text(subtitle)
                .font(AppFonts.body(14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ViewModel

final class ArticlesViewModel: ObservableObject {
    @Published var items: [APIService.Article] = []
    @Published var isLoading: Bool = false
    private var pageNum: Int = 1
    private let pageSize: Int = 20
    private var keyword: String = ""
    private var hasMore: Bool = true
    
    func reload(keyword: String) {
        self.keyword = keyword
        pageNum = 1
        hasMore = true
        items.removeAll()
        Task { await fetch() }
    }
    
    func loadMoreIfNeeded() {
        guard !isLoading, hasMore else { return }
        pageNum += 1
        Task { await fetch(append: true) }
    }
    
    @MainActor
    func pullToRefresh() async {
        pageNum = 1
        hasMore = true
        items.removeAll()
        await fetch()
    }
    
    @MainActor
    private func fetch(append: Bool = false) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await APIService.shared.fetchArticles(pageNum: pageNum, pageSize: pageSize, keyword: keyword)
            if append {
                items.append(contentsOf: page.list)
            } else {
                items = page.list
            }
            let loadedCount = items.count
            hasMore = loadedCount < page.total
        } catch {
            print("Articles fetch error: \(error)")
        }
    }
}

// MARK: - Article Detail

struct ArticleDetailView: View {
    typealias Article = APIService.Article
    let article: Article
    @State private var mode: Int = 1 // 0: 对照 1: 英文 2: 中文 - 默认显示英文
    @State private var fontScale: Double = 1.0
    @State private var isAnimating: Bool = false
    @State private var showReaderToolbar: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image - 无圆角，全宽显示
                AsyncImage(url: URL(string: article.imgUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image): 
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty: 
                        ZStack { 
                            Color.gray.opacity(0.1)
                            ProgressView()
                                .scaleEffect(1.2)
                        }
                    case .failure: 
                        ZStack { 
                            Color.gray.opacity(0.1)
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.textTertiary)
                                Text("图片加载失败")
                                    .font(AppFonts.cardCaption(12))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    @unknown default: 
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(height: 240)
                .clipped()

                // Content Area - 左右留更多空，遵循iOS设计原则
                VStack(alignment: .leading, spacing: 32) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 20) {
                        // 标题
                        Text(article.title)
                            .font(.system(size: 32 * fontScale, weight: .bold, design: .serif))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .padding(.top, 32)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)

                        // 文章信息
                        HStack(spacing: 16) {
                            if let speaker = article.speaker, !speaker.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(speaker)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            if let duration = article.duration, !duration.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                    Text("\(duration)s")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                Text("\(article.views ?? 0)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)

                        // 主题标签
                        if let topics = article.topics, !topics.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(topics, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppColors.primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(AppColors.primary.opacity(0.1))
                                            )
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 15)
                            .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                        }
                    }
                    .padding(.horizontal, 28)

                    // 移除中部的模式切换按钮，改为右上角入口

                    // Content - 无容器包裹，直接显示文本
                    VStack(alignment: .leading, spacing: 0) {
                        if mode == 0 {
                            // 对照模式：使用 englishTranscript 和 chineseTranscript
                            ParallelTextView(english: article.englishTranscript ?? "", chinese: article.chineseTranscript ?? "", fontScale: fontScale)
                        } else if mode == 1 {
                            // 英文模式：使用 english 字段
                            ArticleTextView(text: article.english ?? "", fontScale: fontScale)
                        } else {
                            // 中文模式：使用 chinese 字段
                            ArticleTextView(text: article.chinese ?? "", fontScale: fontScale)
                        }
                    }
                    .padding(.horizontal, 28)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)
                    
                    // 原著地址
                    if let url = article.url, !url.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Divider()
                                .padding(.vertical, 24)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("原著地址")
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Link(destination: URL(string: url) ?? URL(string: "https://example.com")!) {
                                    Text(url)
                                        .font(.system(size: 15, weight: .regular, design: .serif))
                                        .foregroundColor(AppColors.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAnimating = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { withAnimation { showReaderToolbar = true } }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showReaderToolbar) {
            VStack(spacing: 16) {
                HStack {
                    Text("阅读设置")
                        .font(AppFonts.body(16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Button(action: { showReaderToolbar = false }) {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textSecondary)
                    }
                }
                ReadingToolbar(mode: $mode, fontScale: $fontScale)
            }
            .padding(16)
            .background(AppColors.background)
            .presentationDetents([.height(180), .medium])
        }
    }
}

// 单文排版 - 无容器包裹，直接显示文本
struct ArticleTextView: View {
    let text: String
    let fontScale: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 24) { // 恢复原来的间距
            ForEach(text.split(separator: "\n").map(String.init), id: \.self) { para in
                if !para.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("　　" + para) // 两个全角空格作为首行缩进
                        .font(.system(size: 18 * fontScale, weight: .regular, design: .serif))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// 对照排版 - 一句英文一句中文，无容器包裹
struct ParallelTextView: View {
    let english: String
    let chinese: String
    let fontScale: Double
    var body: some View {
        let enLines = english.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let zhLines = chinese.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let count = max(enLines.count, zhLines.count)
        
        return VStack(alignment: .leading, spacing: 32) {
            ForEach(0..<count, id: \.self) { i in
                VStack(alignment: .leading, spacing: 16) {
                    // 英文句子
                    if i < enLines.count {
                        Text(enLines[i])
                            .font(.system(size: 18 * fontScale, weight: .medium, design: .serif))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // 中文句子
                    if i < zhLines.count {
                        Text(zhLines[i])
                            .font(.system(size: 17 * fontScale, weight: .regular, design: .serif))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
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
    @State private var userInfo: APIService.UserInfo?
    @State private var isLoading: Bool = true
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)
                        
                        VStack(spacing: 4) {
                            Text(userInfo?.username ?? "用户名")
                                .font(AppFonts.title(20))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(userInfo?.email ?? "user@example.com")
                                .font(AppFonts.body(14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // User Info Card
                    if let user = userInfo {
                        VStack(spacing: 16) {
                            InfoRow(title: "用户ID", value: "\(user.id)")
                            InfoRow(title: "注册时间", value: formatDate(user.createDate))
                            InfoRow(title: "最后登录", value: formatDate(user.lastLoginDate))
                            if let city = user.city, !city.isEmpty {
                                InfoRow(title: "城市", value: city)
                            }
                            if let gender = user.gender, !gender.isEmpty {
                                InfoRow(title: "性别", value: gender)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Settings
                    VStack(spacing: 0) {
                        SettingsRow(icon: "gear", title: "设置", action: {})
                        SettingsRow(icon: "bell", title: "通知", action: {})
                        SettingsRow(icon: "questionmark.circle", title: "帮助", action: {})
                        SettingsRow(icon: "arrow.right.square", title: "退出登录", action: {
                            showLogoutAlert = true
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
            }
            .background(AppColors.background.ignoresSafeArea())
            .onAppear {
                loadUserInfo()
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
    
    private func loadUserInfo() {
        // 首先尝试从UserDefaults读取已保存的用户信息
        if let userDict = UserDefaults.standard.dictionary(forKey: "userInfo"),
           let id = userDict["id"] as? Int,
           let email = userDict["email"] as? String,
           let username = userDict["username"] as? String,
           let createDate = userDict["createDate"] as? String,
           let lastLoginDate = userDict["lastLoginDate"] as? String {
            
            let user = APIService.UserInfo(
                id: id,
                email: email,
                username: username,
                gender: userDict["gender"] as? String,
                city: userDict["city"] as? String,
                createDate: createDate,
                updateDate: userDict["updateDate"] as? String,
                lastLoginDate: lastLoginDate
            )
            
            self.userInfo = user
            self.isLoading = false
        } else {
            // 如果没有保存的信息，则从API获取
            Task {
                do {
                    if let email = UserDefaults.standard.string(forKey: "userEmail") {
                        let user = try await APIService.shared.fetchUserInfo(email: email)
                        await MainActor.run {
                            self.userInfo = user
                            self.isLoading = false
                            
                            // 保存用户信息到UserDefaults
                            if let user = user {
                                saveUserInfo(user)
                            }
                        }
                    } else {
                        await MainActor.run {
                            self.isLoading = false
                        }
                    }
                } catch {
                    print("Failed to load user info: \(error)")
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func saveUserInfo(_ user: APIService.UserInfo) {
        let userDict: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "gender": user.gender ?? "",
            "city": user.city ?? "",
            "createDate": user.createDate,
            "updateDate": user.updateDate ?? "",
            "lastLoginDate": user.lastLoginDate
        ]
        UserDefaults.standard.set(userDict, forKey: "userInfo")
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    private func logout() {
        // 清除用户token和登录状态
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userInfo")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // 返回到登录页面 - 通过重新启动应用来实现
        exit(0)
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

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(AppFonts.body(14))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(AppFonts.body(14))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    MainAppView()
}
