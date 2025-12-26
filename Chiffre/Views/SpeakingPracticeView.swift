import SwiftUI

struct SpeakingPracticeView: View {
    @StateObject private var trainer = SpeakingTrainer()
    
    var body: some View {
        ZStack {
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 顶部标题
                Text("Prononciation")
                    .font(SurrealTheme.Typography.header(24))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .padding(.top, 60)
                
                Spacer()
                
                // --- 核心卡片 (保持正方形，完全静止) ---
                ZStack {
                    // 背景层
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.white.opacity(0.3))
                        )
                        .frame(width: 300, height: 300)
                        .shadow(color: shadowColor, radius: 25, y: 12)
                        .shadow(color: Color.white.opacity(0.6), radius: 10, x: -4, y: -4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(borderColor, lineWidth: 1.5)
                        )
                    
                    VStack(spacing: 0) {
                        
                        // A. 数字区域 (已移除所有 scaleEffect 动画)
                        VStack(spacing: 8) {
                            Text("\(trainer.currentNumber)")
                                .font(SurrealTheme.Typography.number(110))
                                .foregroundStyle(textColor)
                                .contentTransition(.numericText())
                                .shadow(color: textColor.opacity(0.2), radius: 8, y: 4)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Toucher pour écouter")
                            }
                            .font(.caption)
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.4))
                        }
                        // [已删除] .scaleEffect(...) 和 .animation(...)
                        // 现在的 UI 是完全静止的
                        .onTapGesture {
                            trainer.speakTarget()
                        }
                        .frame(height: 180) // 固定高度
                        
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
                                        Capsule().fill(Color.red.opacity(0.08))
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            // 2. 正确反馈
                            if trainer.status == .correct {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.green)
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
                        
                        Text(trainer.showFrenchText ? "Masquer le texte" : "Afficher le texte")
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
                    .shadow(color: Color.white.opacity(0.7), radius: 5, x: -3, y: -3)
                    .overlay(
                        Capsule().stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.7), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
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
                        // Passer 按钮
                        Button {
                            withAnimation { trainer.generateNew() }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 24, weight: .light))
                                Text("Passer")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.4))
                            .frame(width: 60, height: 60)
                            .contentShape(Rectangle())
                        }
                        
                        // 录音主按钮
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
                        
                        Color.clear.frame(width: 60, height: 60)
                    }
                    .offset(x: -10)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - 样式逻辑
    
    var shadowColor: Color {
        switch trainer.status {
        case .correct: return Color.green.opacity(0.3)
        case .wrong: return Color.red.opacity(0.2)
        case .listening: return SurrealTheme.colors.coral.opacity(0.25)
        default: return SurrealTheme.colors.deepIndigo.opacity(0.1)
        }
    }
    
    var borderColor: LinearGradient {
        switch trainer.status {
        case .correct:
            return LinearGradient(colors: [.green.opacity(0.6), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        case .wrong:
            return LinearGradient(colors: [.red.opacity(0.6), .red.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var textColor: Color {
        switch trainer.status {
        case .correct: return Color.green
        case .wrong: return Color.red.opacity(0.8)
        case .listening: return SurrealTheme.colors.coral
        default: return SurrealTheme.colors.deepIndigo
        }
    }
    
    var micButtonColor: Color {
        if trainer.status == .correct { return Color.green }
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
        case .idle: return "Appuyez pour parler"
        case .listening: return "Je vous écoute..."
        case .correct: return "Parfait !"
        case .wrong: return "Essayez encore"
        }
    }
}
