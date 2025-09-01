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
    @State private var selectedTab: Int = 0
    @State private var showProfile: Bool = false
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
                    // Top Navigation - 四等分布局
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

                    // Main Content
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
                    
                    Spacer(minLength: 0)
                }
                
                // Bottom Bar 现在在 ZStack 内部，确保贴底
                VStack {
                    Spacer()
                    BottomBar(
                        onHome: { withAnimation { selectedSegment = 0 } },
                        onCenter: { },
                        onProfile: { showProfile = true }
                    )
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(onLogout: {
                showLogoutAlert = true
            })
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
                .font(AppFonts.cardSubtitle(15))
                .fontWeight(selectedIndex == index ? .semibold : .medium)
                .foregroundColor(selectedIndex == index ? .white : AppColors.textSecondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            selectedIndex == index ? 
                            AppColors.primary : 
                            AppColors.cardBackground
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    selectedIndex == index ? 
                                    Color.clear : 
                                    AppColors.cardBorder, 
                                    lineWidth: 0.5
                                )
                        )
                )
                .appShadow(
                    selectedIndex == index ? 
                    AppShadows.cardMedium : 
                    AppShadows.cardLight
                )
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Bottom Bar

struct BottomBar: View {
    let onHome: () -> Void
    let onCenter: () -> Void
    let onProfile: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: onHome) {
                VStack(spacing: 2) {
                    AutoPlayLottieView(animationName: "Home", size: CGSize(width: 50, height: 50))
                    Text("首页")
                        .font(AppFonts.cardCaption(11))
                        .fontWeight(.medium)
                }
                .foregroundColor(AppColors.primary)
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
            
            Button(action: onProfile) {
                VStack(spacing: 6) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                    Text("我的")
                        .font(AppFonts.cardCaption(11))
                        .fontWeight(.medium)
                }
                .foregroundColor(AppColors.textSecondary)
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
    @State private var mode: Int = 0 // 0: 对照 1: 英文 2: 中文
    @State private var fontScale: Double = 1.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image - 增强视觉效果
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: article.imgUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image): 
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty: 
                            ZStack { 
                                AppColors.cardBackgroundSecondary
                                ProgressView()
                                    .scaleEffect(1.2)
                            }
                        case .failure: 
                            ZStack { 
                                AppColors.cardBackgroundSecondary
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
                            AppColors.cardBackgroundSecondary
                        }
                    }
                    .frame(height: 240)
                    .clipped()
                    
                    // 底部渐变遮罩
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    
                    // 底部信息
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            if let speaker = article.speaker, !speaker.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    Text(speaker)
                                        .font(AppFonts.cardSubtitle(14))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            if let duration = article.duration, !duration.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    Text("\(duration)s")
                                        .font(AppFonts.cardCaption(12))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                Text("\(article.views ?? 0)")
                                    .font(AppFonts.cardCaption(12))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .appShadow(AppShadows.cardStrong)
                .padding(.horizontal, 16)

                // Title & Meta - 增强卡片样式
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    Text(article.title)
                        .font(AppFonts.title(24))
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)

                    // 主题标签
                    if let topics = article.topics, !topics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(topics, id: \.self) { tag in
                                    Text(tag)
                                        .font(AppFonts.cardSubtitle(13))
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(AppColors.primary.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 0.5)
                                                )
                                        )
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.cardBorder, lineWidth: 0.5)
                        )
                )
                .appShadow(AppShadows.cardLight)
                .padding(.horizontal, 16)

                // Mode Switch - 增强样式
                HStack(spacing: 12) {
                    DetailSegmentButton(title: "对照", index: 0, selectedIndex: $mode)
                    DetailSegmentButton(title: "英文", index: 1, selectedIndex: $mode)
                    DetailSegmentButton(title: "中文", index: 2, selectedIndex: $mode)
                }
                .padding(.horizontal, 16)

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    if mode == 0 {
                        ParallelTextView(english: article.englishTranscript ?? "", chinese: article.chineseTranscript ?? "", fontScale: fontScale)
                    } else if mode == 1 {
                        ArticleTextView(text: article.englishTranscript ?? "", fontScale: fontScale)
                    } else {
                        ArticleTextView(text: article.chineseTranscript ?? "", fontScale: fontScale)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { fontScale = max(0.8, fontScale - 0.1) } }) {
                        Image(systemName: "textformat.size.smaller")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                    }
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { fontScale = min(1.6, fontScale + 0.1) } }) {
                        Image(systemName: "textformat.size.larger")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
    }
}

// 单文排版
struct ArticleTextView: View {
    let text: String
    let fontScale: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(text.split(separator: "\n").map(String.init), id: \.self) { para in
                if !para.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(para)
                        .font(AppFonts.body(16 * fontScale))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColors.cardBorder, lineWidth: 0.5)
                )
        )
        .appShadow(AppShadows.cardLight)
    }
}

// 对照排版（英文—中文成对）
struct ParallelTextView: View {
    let english: String
    let chinese: String
    let fontScale: Double
    var body: some View {
        let enLines = english.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let zhLines = chinese.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let count = max(enLines.count, zhLines.count)
        
        return VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<count, id: \.self) { i in
                VStack(alignment: .leading, spacing: 8) {
                    if i < enLines.count {
                        Text(enLines[i])
                            .font(AppFonts.body(16 * fontScale))
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.gradientSecondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(AppColors.primary.opacity(0.1), lineWidth: 0.5)
                                    )
                            )
                    }
                    if i < zhLines.count {
                        Text(zhLines[i])
                            .font(AppFonts.body(15 * fontScale))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColors.cardBackgroundSecondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(AppColors.cardBorder, lineWidth: 0.5)
                                    )
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppColors.cardBorder, lineWidth: 0.5)
                )
        )
        .appShadow(AppShadows.cardLight)
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
