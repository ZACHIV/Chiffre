import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @State private var showSettings = false
    @State private var borderRotation: Double = 0  // 边框动画
    
    var body: some View {
        ZStack {
            // 1. 全局背景
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 2. 顶部标题
                Text(trainer.dataProvider.appName)
                    .font(SurrealTheme.Typography.title(48))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                    .padding(.top, 60)
                
                Spacer()
                
                // 3. 核心卡片 (悬浮玻璃底座 - 已修复圆角背景 Bug)
                ZStack {
                    // 底座背景
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial) // 磨砂材质
                        .background(
                            RoundedRectangle(cornerRadius: 40) // 关键修复：背景层必须也是圆角，防止出现幽灵矩形
                                .fill(Color.white.opacity(0.25))
                        )
                        .frame(width: 300, height: 300)
                        .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.12), radius: 30, y: 15)
                        .shadow(color: Color.white.opacity(0.5), radius: 12, x: -5, y: -5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(
                                    AngularGradient(
                                        colors: [
                                            SurrealTheme.colors.waterBlue,
                                            SurrealTheme.colors.lavenderMist,
                                            SurrealTheme.colors.lilyPad,
                                            SurrealTheme.colors.skyDawn,
                                            SurrealTheme.colors.waterBlue
                                        ],
                                        center: .center,
                                        angle: .degrees(borderRotation)
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    // 内容区域
                    if trainer.isRevealed {
                        // --- 揭晓状态 ---
                        let text = trainer.currentDisplay
                        let isLongText = text.count > 10
                        
                        Text(text)
                            .font(getFont(for: text))
                            .foregroundStyle(SurrealTheme.colors.deepIndigo)
                            .multilineTextAlignment(.center)
                            .transition(.scale.combined(with: .opacity))
                            .minimumScaleFactor(0.5)
                            .lineLimit(isLongText ? 2 : 1)  // 长文本允许2行
                            .lineSpacing(isLongText ? 8 : 0)  // 长文本增加行间距
                            .padding(.horizontal, 30)
                            
                    } else {
                        // --- 隐藏状态 ---
                        Image(systemName: "ear.and.waveform")
                            .font(.system(size: 80))
                            .foregroundStyle(SurrealTheme.colors.coral)
                            .shadow(color: SurrealTheme.colors.coral.opacity(0.3), radius: 10, y: 5)
                            .transition(.scale.combined(with: .opacity))
                            .onTapGesture {
                                trainer.replay()
                            }
                    }
                }
                .onTapGesture {
                    // 点击卡片任意区域：如果未揭晓则重听
                    if !trainer.isRevealed { trainer.replay() }
                }
                
                // 提示文字
                Text(trainer.isRevealed ? trainer.dataProvider.successText : trainer.dataProvider.listenText)
                    .font(SurrealTheme.Typography.body(18))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.6))
                    .padding(.top, 30)
                
                Spacer()
                
                // 4. 底部控制栏
                HStack(spacing: 30) {
                    CircleButton(icon: "speaker.wave.2.fill") {
                        trainer.replay()
                    }
                    
                    // 核心操作按钮
                    Button {
                        if trainer.isRevealed {
                            trainer.generateNew()
                        } else {
                            trainer.reveal()
                        }
                    } label: {
                        Text(trainer.isRevealed ? trainer.dataProvider.nextText : trainer.dataProvider.revealText)
                            .font(SurrealTheme.Typography.header(20))
                            .foregroundStyle(.white)
                            .frame(width: 150, height: 64)
                            .background(trainer.isRevealed ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.coral)
                            .clipShape(Capsule())
                            .shadow(
                                color: (trainer.isRevealed ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.coral).opacity(0.5), 
                                radius: 15, 
                                y: 8
                            )
                    }
                    
                    CircleButton(icon: "slider.horizontal.3") {
                        showSettings = true
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // 启动边框动画
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.height(520)])  // 增加高度以容纳语音选择
                .presentationCornerRadius(30)
        }
    }
    
    // 动态字体大小
    func getFont(for text: String) -> Font {
        if text.count > 10 {
            return SurrealTheme.Typography.number(42) // 电话号码
        } else if text.count > 5 {
            return SurrealTheme.Typography.number(64) // 时间/短价格
        } else {
            return SurrealTheme.Typography.number(96) // 普通数字
        }
    }
}

// 辅助组件
struct CircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.4))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
    }
}
