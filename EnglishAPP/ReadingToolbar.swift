import SwiftUI

struct ReadingToolbar: View {
    @Binding var mode: Int // 0: 对照 1: 英文 2: 中文
    @Binding var fontScale: Double // 0.8 ... 1.6
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                DetailSegmentButton(title: "对照", index: 0, selectedIndex: $mode)
                DetailSegmentButton(title: "英文", index: 1, selectedIndex: $mode)
                DetailSegmentButton(title: "中文", index: 2, selectedIndex: $mode)
            }
            
            HStack(spacing: 12) {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { fontScale = max(0.8, fontScale - 0.1) } }) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primary)
                }
                
                Slider(value: $fontScale, in: 0.8...1.6)
                    .tint(AppColors.primary)
                
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { fontScale = min(1.6, fontScale + 0.1) } }) {
                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColors.cardBorder, lineWidth: 0.5)
                )
        )
        .appShadow(AppShadows.cardLight)
    }
}



