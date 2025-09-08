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
    @StateObject private var annotationManager = AnnotationManager()
    
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
                            UnifiedSelectableTextView(
                                text: article.english ?? "",
                                fontScale: fontScale,
                                articleId: String(article.id),
                                articleTitle: article.title,
                                articleImageUrl: article.imgUrl,
                                annotationManager: annotationManager
                            )
                        } else {
                            // 中文模式：使用 chinese 字段
                            UnifiedSelectableTextView(
                                text: article.chinese ?? "",
                                fontScale: fontScale,
                                articleId: String(article.id),
                                articleTitle: article.title,
                                articleImageUrl: article.imgUrl,
                                annotationManager: annotationManager
                            )
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
            annotationManager.loadAnnotations()
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
                    Text("    " + para) // 四个半角空格作为首行缩进
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

// 支持下划线的文章文本视图
struct UnderlinedArticleTextView: View {
    let text: String
    let fontScale: Double
    let articleId: String
    let annotationManager: AnnotationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(text.split(separator: "\n").map(String.init), id: \.self) { para in
                if !para.trimmingCharacters(in: .whitespaces).isEmpty {
                    UnderlinedParagraphView(
                        paragraph: "    " + para,
                        fontScale: fontScale,
                        articleId: articleId,
                        annotationManager: annotationManager
                    )
                }
            }
        }
    }
}

struct UnderlinedParagraphView: View {
    let paragraph: String
    let fontScale: Double
    let articleId: String
    let annotationManager: AnnotationManager

    var body: some View {
        let highlights = annotationManager.annotations.first(where: { $0.articleId == articleId })?.highlightedRanges ?? []

        if highlights.isEmpty {
            // 没有下划线，直接显示普通文本
            Text(paragraph)
                .font(.system(size: 18 * fontScale, weight: .regular, design: .serif))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            // 有下划线，逐字符处理
            let attributedString = createAttributedString()
            Text(attributedString)
                .font(.system(size: 18 * fontScale, weight: .regular, design: .serif))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString(paragraph)
        let highlights = annotationManager.annotations.first(where: { $0.articleId == articleId })?.highlightedRanges ?? []

        for highlight in highlights {
            // 由于段落前面有4个空格，需要调整位置
            let adjustedStart = highlight.startIndex + 4
            let adjustedEnd = highlight.endIndex + 4

            if adjustedStart >= 0 && adjustedEnd <= paragraph.count && adjustedStart < adjustedEnd {
                if let range = Range(NSRange(location: adjustedStart, length: adjustedEnd - adjustedStart), in: paragraph) {
                    if let attributedRange = Range(range, in: attributedString) {
                        attributedString[attributedRange].underlineStyle = .single
                        attributedString[attributedRange].foregroundColor = .blue
                    }
                }
            }
        }

        return attributedString
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
                        NavigationLink(destination: MyAnnotationsView()) {
                            SettingsRowContent(icon: "highlighter", title: "我的批注")
                        }
                        .buttonStyle(PlainButtonStyle())
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
            SettingsRowContent(icon: icon, title: title)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsRowContent: View {
    let icon: String
    let title: String
    
    var body: some View {
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

// MARK: - My Annotations View

struct MyAnnotationsView: View {
    @StateObject private var annotationManager = AnnotationManager()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("我的批注")
                    .font(AppFonts.title(24))
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(annotationManager.annotations.count) 篇")
                    .font(AppFonts.body(14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Content
            if annotationManager.annotations.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "highlighter")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.textTertiary)

                    VStack(spacing: 8) {
                        Text("还没有批注")
                            .font(AppFonts.body(18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)

                        Text("在阅读文章时选中文字进行下划线，批注会显示在这里")
                            .font(AppFonts.body(14))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(annotationManager.annotations) { annotation in
                            AnnotationCard(annotation: annotation)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            annotationManager.loadAnnotations()
        }
    }
}

// MARK: - Annotation Models

struct ArticleAnnotation: Identifiable, Codable {
    let id = UUID()
    let articleId: String
    let articleTitle: String
    let articleImageUrl: String?
    let highlightedRanges: [HighlightRange]
    let lastUpdated: Date

    init(articleId: String, articleTitle: String, articleImageUrl: String?, highlightedRanges: [HighlightRange]) {
        self.articleId = articleId
        self.articleTitle = articleTitle
        self.articleImageUrl = articleImageUrl
        self.highlightedRanges = highlightedRanges
        self.lastUpdated = Date()
    }
}

struct HighlightRange: Codable {
    let startIndex: Int
    let endIndex: Int
    let paragraphIndex: Int
    let timestamp: Date

    init(startIndex: Int, endIndex: Int, paragraphIndex: Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.paragraphIndex = paragraphIndex
        self.timestamp = Date()
    }
}

// 旧数据结构，用于数据迁移
struct OldArticleAnnotation: Codable {
    let id: UUID
    let articleId: String
    let articleTitle: String
    let articleImageUrl: String?
    let highlightedWords: [OldHighlightedWord]
    let lastUpdated: Date
}

struct OldHighlightedWord: Codable {
    let id: UUID
    let word: String
    let range: OldWordRange
    let timestamp: Date
    let highlightType: OldHighlightType
    let note: String?
}

struct OldWordRange: Codable {
    let startIndex: Int
    let endIndex: Int
    let paragraphIndex: Int
}

enum OldHighlightType: String, Codable {
    case unknown = "unknown"
    case important = "important"
    case review = "review"
    case favorite = "favorite"
}

// MARK: - Annotation Manager

class AnnotationManager: ObservableObject {
    @Published var annotations: [ArticleAnnotation] = []

    private let userDefaults = UserDefaults.standard
    private let annotationsKey = "articleAnnotations"

    func loadAnnotations() {
        guard let data = userDefaults.data(forKey: annotationsKey) else {
            print("No annotation data found")
            return
        }

        print("Loading annotation data...")

        do {
            // 尝试解码新格式
            annotations = try JSONDecoder().decode([ArticleAnnotation].self, from: data)
            print("Successfully loaded \(annotations.count) annotations")
        } catch {
            print("加载批注数据失败: \(error)")

            // 如果解码失败，尝试迁移旧数据
            migrateOldData(data)
        }
    }

    private func migrateOldData(_ data: Data) {
        do {
            print("Attempting to migrate old annotation data...")
            // 尝试解码旧格式的数据
            let oldAnnotations = try JSONDecoder().decode([OldArticleAnnotation].self, from: data)
            print("Found \(oldAnnotations.count) old annotations to migrate")

            // 转换为新格式
            annotations = oldAnnotations.map { oldAnnotation in
                let newRanges = oldAnnotation.highlightedWords.map { oldWord in
                    HighlightRange(
                        startIndex: oldWord.range.startIndex,
                        endIndex: oldWord.range.endIndex,
                        paragraphIndex: oldWord.range.paragraphIndex
                    )
                }

                return ArticleAnnotation(
                    articleId: oldAnnotation.articleId,
                    articleTitle: oldAnnotation.articleTitle,
                    articleImageUrl: oldAnnotation.articleImageUrl,
                    highlightedRanges: newRanges
                )
            }

            // 保存转换后的数据
            saveAnnotations()
            print("成功迁移旧批注数据，共迁移 \(annotations.count) 条批注")
        } catch {
            print("迁移旧数据失败: \(error)")
        }
    }

    private func saveAnnotations() {
        do {
            let data = try JSONEncoder().encode(annotations)
            userDefaults.set(data, forKey: annotationsKey)
        } catch {
            print("保存批注数据失败: \(error)")
        }
    }

    func addAnnotation(_ annotation: ArticleAnnotation) {
        if let index = annotations.firstIndex(where: { $0.articleId == annotation.articleId }) {
            annotations[index] = annotation
        } else {
            annotations.append(annotation)
        }
        saveAnnotations()
    }

    func removeAnnotation(articleId: String) {
        annotations.removeAll { $0.articleId == articleId }
        saveAnnotations()
    }

    func addHighlight(articleId: String, articleTitle: String, articleImageUrl: String?, range: HighlightRange) {
        var highlightedRanges = annotations.first(where: { $0.articleId == articleId })?.highlightedRanges ?? []
        highlightedRanges.append(range)

        let annotation = ArticleAnnotation(
            articleId: articleId,
            articleTitle: articleTitle,
            articleImageUrl: articleImageUrl,
            highlightedRanges: highlightedRanges
        )
        addAnnotation(annotation)
    }

    func hasHighlights(for articleId: String) -> Bool {
        return annotations.contains { $0.articleId == articleId }
    }
}

// MARK: - Selectable Article Text Component

struct SelectableArticleTextView: View {
    let text: String
    let fontScale: Double
    let articleId: String
    let articleTitle: String
    let articleImageUrl: String?
    let annotationManager: AnnotationManager

    var body: some View {
        ZStack {
            // 基础文本显示（支持下划线）
            UnderlinedArticleTextView(
                text: text,
                fontScale: fontScale,
                articleId: articleId,
                annotationManager: annotationManager
            )

            // 透明的选中层
            SelectableOverlay(
                text: text,
                fontScale: fontScale,
                articleId: articleId,
                articleTitle: articleTitle,
                articleImageUrl: articleImageUrl,
                annotationManager: annotationManager
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HighlightUpdated"))) { _ in
            // 当下划线更新时，强制重新渲染
        }
    }
}

// MARK: - Unified UITextView 渲染（显示+选择+下划线）

struct UnifiedSelectableTextView: UIViewRepresentable {
    let text: String
    let fontScale: Double
    let articleId: String
    let articleTitle: String
    let articleImageUrl: String?
    let annotationManager: AnnotationManager

    func makeUIView(context: Context) -> UITextView {
        let textView = UnifiedTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        // 右侧增加少量内边距，缓和右缘
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.delegate = context.coordinator

        // 注入上下文
        textView.articleId = articleId
        textView.articleTitle = articleTitle
        textView.articleImageUrl = articleImageUrl
        textView.annotationManager = annotationManager
        textView.coordinator = context.coordinator

        // 首次渲染
        context.coordinator.render(text: text, on: textView, fontScale: fontScale)
        // 关键：让 TextView 宽度跟随 SwiftUI 布局，从而触发正确的自动换行
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)

        // 自定义菜单
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "下划线", action: #selector(UnifiedTextView.highlightAction))
        ]

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.render(text: text, on: uiView, fontScale: fontScale)
        uiView.invalidateIntrinsicContentSize()
    }

    // 让 SwiftUI 正确计算高度，避免内容被截断（iOS 17+）
    @available(iOS 17.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize {
        let targetWidth = proposal.width ?? uiView.bounds.width
        let fit = uiView.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: targetWidth, height: fit.height)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(articleId: articleId, articleTitle: articleTitle, articleImageUrl: articleImageUrl, annotationManager: annotationManager)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let articleId: String
        let articleTitle: String
        let articleImageUrl: String?
        weak var annotationManager: AnnotationManager?

        init(articleId: String, articleTitle: String, articleImageUrl: String?, annotationManager: AnnotationManager) {
            self.articleId = articleId
            self.articleTitle = articleTitle
            self.articleImageUrl = articleImageUrl
            self.annotationManager = annotationManager
        }

        func render(text: String, on textView: UITextView, fontScale: Double) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.paragraphSpacing = 24
            // 使用两端对齐以减少右缘参差，同时保留首行缩进
            paragraphStyle.alignment = .justified
            paragraphStyle.firstLineHeadIndent = 18 // 约等于四个空格
            // 右侧尾缩进（负值表示相对容器右侧向内收缩几个点）
            paragraphStyle.tailIndent = -2
            // 提升换行质量：开启连字符与标准/推出策略，避免末尾单字符换行
            paragraphStyle.hyphenationFactor = 0.7
            paragraphStyle.allowsDefaultTighteningForTruncation = true
            if #available(iOS 14.0, *) {
                paragraphStyle.lineBreakStrategy = [.standard, .pushOut]
            }

            // 归一化段落：删去空行，统一用单个 \n 分隔，避免“原文本空行 + paragraphSpacing”叠加导致的大间距
            let normalized: String = {
                let unix = text.replacingOccurrences(of: "\r\n", with: "\n")
                let parts = unix.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
                let nonEmpty = parts.filter { !$0.isEmpty }
                return nonEmpty.joined(separator: "\n")
            }()

            let attr = NSMutableAttributedString(string: normalized)
            attr.addAttributes([
                .font: serifFont(ofSize: 18 * fontScale),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attr.length))

            let highlights = annotationManager?.annotations.first(where: { $0.articleId == articleId })?.highlightedRanges ?? []
            for h in highlights {
                let r = NSRange(location: h.startIndex, length: max(0, h.endIndex - h.startIndex))
                guard r.location >= 0, r.location + r.length <= attr.length else { continue }
                let style = NSUnderlineStyle.thick.rawValue | NSUnderlineStyle.byWord.rawValue
                attr.addAttribute(.underlineStyle, value: style, range: r)
                attr.addAttribute(.underlineColor, value: UIColor.systemBlue.withAlphaComponent(0.9), range: r)
            }

            textView.attributedText = attr
            textView.textAlignment = .justified
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.textContainer.maximumNumberOfLines = 0
            textView.textContainer.widthTracksTextView = true
            textView.isScrollEnabled = false
            textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
            // 同步高度，避免截断
            // 使用 sizeToFit 让 contentSize 与布局一致，避免部分设备上高度不同步
            let targetWidth = textView.bounds.width
            let fit = textView.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
            if abs(textView.bounds.height - fit.height) > 1 {
                textView.frame.size.height = fit.height
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            if textView.selectedRange.length > 0 {
                UIMenuController.shared.showMenu(from: textView, rect: textView.firstRect(for: textView.selectedTextRange!))
            }
        }
    }
}

private func serifFont(ofSize size: CGFloat) -> UIFont {
    if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.serif) {
        return UIFont(descriptor: descriptor, size: size)
    }
    return UIFont.systemFont(ofSize: size)
}

class UnifiedTextView: UITextView {
    weak var coordinator: UnifiedSelectableTextView.Coordinator?
    weak var annotationManager: AnnotationManager?
    var articleId: String?
    var articleTitle: String?
    var articleImageUrl: String?

    override var intrinsicContentSize: CGSize {
        // 高度随内容而变，宽度由外部约束决定
        let targetWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let fit = sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: fit.height)
    }

    private var lastIntrinsicWidth: CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        // 仅在宽度显著变化时才刷新内在尺寸，避免反复触发布局
        let w = bounds.width.rounded()
        if abs(w - lastIntrinsicWidth) > 0.5 {
            lastIntrinsicWidth = w
            invalidateIntrinsicContentSize()
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) { return selectedRange.length > 0 }
        if action == #selector(highlightAction) { return selectedRange.length > 0 }
        return false
    }

    @objc func highlightAction() {
        guard let annotationManager = annotationManager, let articleId = articleId, let articleTitle = articleTitle else { return }
        guard let range = selectedRange.nonEmpty else { return }
        let h = HighlightRange(startIndex: range.location, endIndex: range.location + range.length, paragraphIndex: 0)
        annotationManager.addHighlight(articleId: articleId, articleTitle: articleTitle, articleImageUrl: articleImageUrl, range: h)

        // 立即应用到当前文本
        let attr = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString())
        let style = NSUnderlineStyle.thick.rawValue | NSUnderlineStyle.byWord.rawValue
        attr.addAttribute(.underlineStyle, value: style, range: range)
        attr.addAttribute(.underlineColor, value: UIColor.systemBlue.withAlphaComponent(0.9), range: range)
        attributedText = attr
        selectedRange = NSRange(location: 0, length: 0)
        // 内容改变，刷新高度
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
}

// 旧的叠加实现（为兼容暂保留）
struct SelectableOverlay: UIViewRepresentable {
    let text: String
    let fontScale: Double
    let articleId: String
    let articleTitle: String
    let articleImageUrl: String?
    let annotationManager: AnnotationManager

    func makeUIView(context: Context) -> UITextView {
        let textView = CustomTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textColor = .clear // 文本透明，但保持布局
        textView.text = text
        textView.font = serifFont(ofSize: 18 * fontScale)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.delegate = context.coordinator

        // 设置批注管理器和文章信息
        textView.setup(with: annotationManager, articleId: articleId, articleTitle: articleTitle, articleImageUrl: articleImageUrl)

        // 自定义菜单
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "下划线", action: #selector(CustomTextView.highlightAction))
        ]

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = serifFont(ofSize: 18 * fontScale)
    }

    private func serifFont(ofSize size: CGFloat) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let parent: SelectableOverlay

        init(_ parent: SelectableOverlay) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            print("Selection changed: length=\(textView.selectedRange.length), location=\(textView.selectedRange.location)")
            if textView.selectedRange.length > 0 {
                print("Showing menu for selection")
                UIMenuController.shared.showMenu(from: textView, rect: textView.firstRect(for: textView.selectedTextRange!))
            }
        }
    }
}

class CustomTextView: UITextView {
    weak var annotationManager: AnnotationManager?
    var articleId: String?
    var articleTitle: String?
    var articleImageUrl: String?

    func setup(with manager: AnnotationManager, articleId: String, articleTitle: String, articleImageUrl: String?) {
        self.annotationManager = manager
        self.articleId = articleId
        self.articleTitle = articleTitle
        self.articleImageUrl = articleImageUrl
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) { return selectedRange.length > 0 }
        if action == #selector(highlightAction) { return selectedRange.length > 0 }
        return false
    }

    @objc func highlightAction() {
        print("Highlight action triggered")
        guard let range = selectedRange.nonEmpty,
              let articleId = articleId,
              let articleTitle = articleTitle,
              let annotationManager = annotationManager else {
            print("Missing required data for highlight action")
            return
        }

        print("Creating highlight range: location=\(range.location), length=\(range.length)")

        // 创建下划线范围
        let highlightRange = HighlightRange(
            startIndex: range.location,
            endIndex: range.location + range.length,
            paragraphIndex: 0
        )

        // 添加到数据管理器
        annotationManager.addHighlight(
            articleId: articleId,
            articleTitle: articleTitle,
            articleImageUrl: articleImageUrl,
            range: highlightRange
        )

        print("Highlight added successfully")

        // 取消选择
        selectedRange = NSRange(location: 0, length: 0)

        // 发送通知，让父视图知道下划线已更新
        NotificationCenter.default.post(name: NSNotification.Name("HighlightUpdated"), object: nil)
    }
}

struct AnnotationCard: View {
    let annotation: ArticleAnnotation
    @State private var isHovered: Bool = false

    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: createArticleFromAnnotation())) {
            VStack(alignment: .leading, spacing: 12) {
                // Article info
                HStack(spacing: 12) {
                    // Article image
                    AsyncImage(url: URL(string: annotation.articleImageUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.1)
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        @unknown default:
                            Color.gray.opacity(0.1)
                        }
                    }
                    .frame(width: 80, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Article details
                    VStack(alignment: .leading, spacing: 6) {
                        Text(annotation.articleTitle)
                            .font(AppFonts.body(16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 8) {
                            Text("\(annotation.highlightedRanges.count) 个下划线")
                                .font(AppFonts.body(12))
                                .foregroundColor(AppColors.textSecondary)

                            Spacer()

                            Text(formatDate(annotation.lastUpdated))
                                .font(AppFonts.body(12))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }

                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private func createArticleFromAnnotation() -> APIService.Article {
        return APIService.Article(
            id: Int(annotation.articleId) ?? 0,
            transcriptId: annotation.articleId,
            title: annotation.articleTitle,
            speaker: "",
            url: "",
            description: "",
            duration: "",
            views: 0,
            publishedAt: "",
            language: "en",
            englishTranscript: "",
            chineseTranscript: "",
            english: "",
            chinese: "",
            topics: [],
            createDate: "",
            updateDate: "",
            imgUrl: annotation.articleImageUrl
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - Extensions

extension NSRange {
    var nonEmpty: NSRange? {
        length > 0 ? self : nil
    }
}

#Preview {
    MainAppView()
}
