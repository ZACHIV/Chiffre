import SwiftUI

struct ReferenceView: View {
    // 数据结构
    struct NumberGroup: Identifiable {
        let id = UUID()
        let frenchTitle: String
        let cnSubtitle: String
        let numbers: [Int]
    }
    
    let groups: [NumberGroup] = [
        NumberGroup(frenchTitle: "Les Bases", cnSubtitle: "基础数字 1-20", numbers: Array(1...20)),
        NumberGroup(frenchTitle: "Les Dizaines", cnSubtitle: "整十进位", numbers: [30, 40, 50, 60]),
        // 修改点：在末尾追加了 100, 1000, 和代表无限的 -1
        NumberGroup(
            frenchTitle: "Les Complexes",
            cnSubtitle: "进位 · 大数 · 无限",
            numbers: Array(70...79) + [80] + Array(90...99) + [100, 1000, -1]
        )
    ]
    
    // 布局优化：4列布局
    let columns = [
        GridItem(.adaptive(minimum: 75, maximum: 100), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // 1. 全局背景
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 顶部标题
                Text("Référence")
                    .font(SurrealTheme.Typography.title(48))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                
                // 2. 滚动内容区
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 50) {
                        ForEach(groups) { group in
                            VStack(alignment: .leading, spacing: 20) {
                                // 标题排版
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(group.frenchTitle)
                                        .font(.custom("Didot", size: 32))
                                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                                    
                                    Text(group.cnSubtitle)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                                        .tracking(1)
                                }
                                .padding(.leading, 20)
                                
                                // 数字网格
                                LazyVGrid(columns: columns, spacing: 30) {
                                    ForEach(group.numbers, id: \.self) { num in
                                        BorderlessNumberCell(number: num)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

// --- 无边界数字单元格 ---
struct BorderlessNumberCell: View {
    let number: Int
    @State private var isPressed = false
    
    // 逻辑判断：是否是特殊字符（无限）
    var isInfinity: Bool { number == -1 }
    
    var body: some View {
        Button {
            // 1. 发音逻辑
            if isInfinity {
                // 根据语言显示不同的无限表达
                let infinityText = LanguageVoiceManager.currentLanguage == .french ? "L'infini" : "El infinito"
                SpeechManager.shared.speak(infinityText)
            } else {
                // 常规数字发音 - 根据当前语言
                let formatter = NumberFormatter()
                formatter.numberStyle = .spellOut
                formatter.locale = Locale(identifier: LanguageVoiceManager.currentLanguage.localeIdentifier)
                let text = formatter.string(from: NSNumber(value: number)) ?? "\(number)"
                SpeechManager.shared.speak(text)
            }
            
            // 2. 触感
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // 3. 动画
            withAnimation(.spring(duration: 0.3)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { isPressed = false }
            }
            
        } label: {
            ZStack {
                // 交互反馈层
                Circle()
                    .fill(SurrealTheme.colors.coral.opacity(0.15))
                    .scaleEffect(isPressed ? 1.0 : 0.5)
                    .opacity(isPressed ? 1.0 : 0.0)
                    .frame(width: 70, height: 70)
                
                // 数字/符号显示层
                Text(isInfinity ? "∞" : "\(number)")
                    // 针对 1000 和 ∞ 稍微调整一下字号，保持视觉平衡
                    .font(.custom("Didot", size: isInfinity ? 40 : (number >= 1000 ? 28 : 34)))
                    .foregroundStyle(isPressed ? SurrealTheme.colors.coral : SurrealTheme.colors.deepIndigo)
                    // 无限符号微调位置，让它视觉居中
                    .offset(y: isInfinity ? -2 : 0)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .frame(height: 70)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
