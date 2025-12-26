import SwiftUI

struct ReferenceView: View {
    // 定义数据结构：分组
    struct NumberGroup: Identifiable {
        let id = UUID()
        let title: String
        let numbers: [Int]
    }
    
    // 修改点：补全了 70-79 和 90-99 的完整序列
    let groups: [NumberGroup] = [
        NumberGroup(title: "Les Bases (基础)", numbers: Array(1...20)),
        NumberGroup(title: "Les Dizaines (整十)", numbers: [30, 40, 50, 60]),
        NumberGroup(title: "Les Complexes (进阶)", numbers: Array(70...79) + [80] + Array(90...99))
    ]
    
    // 网格布局配置
    let columns = [
        GridItem(.adaptive(minimum: 64, maximum: 80), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // 1. 全局背景
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 顶部标题
                Text("Référence")
                    .font(SurrealTheme.Typography.header(24))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                
                // 2. 滚动内容区
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        ForEach(groups) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                // 分组标题
                                Text(group.title)
                                    .font(SurrealTheme.Typography.header(18))
                                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.6))
                                    .padding(.leading, 10)
                                
                                // 分组内容的玻璃容器
                                GlassContainer {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(group.numbers, id: \.self) { num in
                                            NumberCell(number: num)
                                        }
                                    }
                                    .padding(20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // 底部留白给 TabBar
                }
            }
        }
    }
}

// --- 辅助组件：独立的数字单元格 ---
struct NumberCell: View {
    let number: Int
    @State private var isPressed = false
    
    var body: some View {
        Button {
            // 1. 发音逻辑
            // 将 Int 转为法语拼写字符串 (如 71 -> "soixante et onze")
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            formatter.locale = Locale(identifier: "fr-FR")
            let text = formatter.string(from: NSNumber(value: number)) ?? "\(number)"
            
            SpeechManager.shared.speak(text)
            
            // 2. 触感反馈
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // 3. 弹跳动画
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { isPressed = false }
            }
            
        } label: {
            ZStack {
                // 按钮背景
                Circle()
                    .fill(Color.white.opacity(isPressed ? 0.6 : 0.3))
                    .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.1), radius: 5, y: 3)
                
                // 数字文本
                Text("\(number)")
                    .font(SurrealTheme.Typography.number(24))
                    .foregroundStyle(isPressed ? SurrealTheme.colors.coral : SurrealTheme.colors.deepIndigo)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
            }
            .frame(height: 64)
        }
    }
}

// --- 辅助组件：玻璃容器 ---
struct GlassContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.25))
                )
                .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.05), radius: 15, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            
            content
        }
    }
}
