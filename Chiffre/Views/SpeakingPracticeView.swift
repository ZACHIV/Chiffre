import SwiftUI

struct SpeakingPracticeView: View {
    @StateObject private var trainer = SpeakingTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var borderRotation: Double = 0  // 边框动画

    private var dp: LanguageDataProvider {
        lm.currentLanguage == .french ? FrenchDataProvider() : SpanishDataProvider()
    }
    
    var body: some View {
        ZStack {
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 顶部标题
                VStack(spacing: 4) {
                    Text("Prononciation")
                        .font(SurrealTheme.Typography.title(48))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                        .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                    // P2: 明确此模块训练发音（口语输出），与 Écouter 的听力理解是独立技能
                    Text("口语发音练习 · 与听力理解是独立技能")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.4))
                        .tracking(0.5)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // --- 2. 核心卡片 ---
                ZStack {
                    // 背景层
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.white.opacity(0.3))
                        )
                        .frame(width: 300, height: 300)
                        .shadow(color: shadowColor, radius: 30, y: 15)
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
                    
                    VStack(spacing: 0) {
                        
                        // A. 数字区域
                        VStack(spacing: 8) {
                            Text("\(trainer.currentNumber)")
                                .font(SurrealTheme.Typography.number(110))
                                .foregroundStyle(textColor)
                                .contentTransition(.numericText())
                                .shadow(color: textColor.opacity(0.2), radius: 8, y: 4)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text(dp.speakTapHint)
                            }
                            .font(.caption)
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                        }
                        .onTapGesture {
                            trainer.speakTarget()
                        }
                        .frame(height: 180)
                        
                        // B. 动态反馈区域
                        VStack(spacing: 8) {
                            // 1. 错误反馈
                            if !trainer.capturedWrongText.isEmpty && trainer.status != .correct {
                                Text("\"\(trainer.capturedWrongText)\"")
                                    .font(SurrealTheme.Typography.header(24))
                                    .foregroundStyle(Color.red.opacity(0.8))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule().fill(Color.red.opacity(0.06))
                                    )
                                    .shadow(color: Color.red.opacity(0.15), radius: 6, y: 2)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            // 2. 正确反馈
                            if trainer.status == .correct {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(SurrealTheme.colors.lilyPad)
                                    .shadow(color: SurrealTheme.colors.lilyPad.opacity(0.4), radius: 10, y: 5)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            // 3. 文本提示
                            if trainer.showFrenchText {
                                Text(trainer.targetText)
                                    .font(SurrealTheme.Typography.body(20))
                                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: 80, alignment: .top)
                    }
                }
                
                // 文本显示开关
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        trainer.showFrenchText.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: trainer.showFrenchText ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(trainer.showFrenchText ? SurrealTheme.colors.coral : SurrealTheme.colors.deepIndigo)
                            .contentTransition(.symbolEffect(.replace.downUp))

                        Text(trainer.showFrenchText ? dp.hideTextLabel : dp.showTextLabel)
                            .font(SurrealTheme.Typography.body(16))
                            .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        ZStack {
                            Capsule().fill(Color.white.opacity(0.2))
                            Capsule().fill(.ultraThinMaterial)
                        }
                    )
                    .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.1), radius: 15, y: 8)
                    .shadow(color: Color.white.opacity(0.5), radius: 8, x: -4, y: -4)
                    .overlay(
                        Capsule().stroke(
                            AngularGradient(
                                colors: [
                                    SurrealTheme.colors.waterBlue,
                                    SurrealTheme.colors.lavenderMist,
                                    SurrealTheme.colors.lilyPad,
                                    SurrealTheme.colors.skyDawn,
                                    SurrealTheme.colors.waterBlue
                                ],
                                center: .center,
                                angle: .degrees(borderRotation * 0.7)  // 稍慢一点
                            ),
                            lineWidth: 1
                        )
                    )
                }
                .padding(.top, 30)
                
                Spacer()
                
                // --- 4. 底部控制栏 ---
                VStack(spacing: 20) {
                    Text(statusMessage)
                        .font(SurrealTheme.Typography.body(16))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.6))
                        .frame(height: 20)
                        .id("statusLabel")
                    
                    HStack(spacing: 40) {
                        // 1. 左侧占位符 (透明) - 为了布局平衡
                        Color.clear.frame(width: 60, height: 60)
                        
                        // 2. 录音主按钮 (居中)
                        Button {
                            withAnimation {
                                if trainer.status == .correct {
                                    trainer.generateNew()
                                } else {
                                    trainer.toggleRecording()
                                }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(micButtonColor)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: micButtonColor.opacity(0.4), radius: 15, y: 8)
                                
                                Image(systemName: micIconName)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }
                        
                        // 3. 右侧 Passer 按钮 (方便单手操作)
                        Button {
                            withAnimation { trainer.generateNew() }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 24, weight: .light))
                                Text(dp.skipLabel)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                            .frame(width: 60, height: 60)
                            .contentShape(Rectangle())
                        }
                    }
                    .offset(x: 10) // 视觉微调：稍微向右偏移，保证中间的圆视觉居中
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // 启动边框动画
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
    }
    
    // MARK: - 样式逻辑
    
    var shadowColor: Color {
        switch trainer.status {
        case .correct: return SurrealTheme.colors.lilyPad.opacity(0.3)
        case .wrong: return Color.red.opacity(0.2)
        case .listening: return SurrealTheme.colors.coral.opacity(0.25)
        default: return SurrealTheme.colors.deepIndigo.opacity(0.1)
        }
    }
    
    var borderColor: LinearGradient {
        switch trainer.status {
        case .correct:
            return LinearGradient(
                colors: [SurrealTheme.colors.lilyPad.opacity(0.7), SurrealTheme.colors.lilyPad.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .wrong:
            return LinearGradient(
                colors: [Color.red.opacity(0.6), Color.red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.white.opacity(0.8), .white.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var textColor: Color {
        switch trainer.status {
        case .correct: return SurrealTheme.colors.lilyPad
        case .wrong: return Color.red.opacity(0.8)
        case .listening: return SurrealTheme.colors.coral
        default: return SurrealTheme.colors.deepIndigo
        }
    }
    
    var micButtonColor: Color {
        if trainer.status == .correct { return SurrealTheme.colors.lilyPad }
        if trainer.status == .wrong { return Color.red.opacity(0.8) }
        if trainer.status == .listening { return SurrealTheme.colors.coral }
        return SurrealTheme.colors.deepIndigo
    }
    
    var micIconName: String {
        if trainer.status == .correct { return "checkmark" }
        if trainer.status == .wrong { return "arrow.clockwise" }
        if trainer.status == .listening { return "square.fill" }
        return "mic.fill"
    }
    
    var statusMessage: String {
        switch trainer.status {
        case .idle:      return dp.speakIdlePrompt
        case .listening: return dp.speakListeningPrompt
        case .correct:   return dp.speakCorrectPrompt
        case .wrong:     return dp.speakWrongPrompt
        }
    }
}
