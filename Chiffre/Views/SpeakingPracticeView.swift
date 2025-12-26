import SwiftUI

struct SpeakingPracticeView: View {
    @StateObject private var trainer = SpeakingTrainer()
    @State private var shakeOffset: CGFloat = 0 // 震动动画偏移量
    
    var body: some View {
        ZStack {
            // 1. 全局背景
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 顶部标题
                Text("Prononciation")
                    .font(SurrealTheme.Typography.header(24))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .padding(.top, 60)
                
                Spacer()
                
                // 2. 核心卡片 (包含数字 + 错误反馈)
                ZStack {
                    // 卡片背景
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .background(Color.white.opacity(0.4)) // 稍微加深一点背景，提升对比度
                        .frame(width: 320, height: 400) // 增加高度以容纳反馈信息
                        .shadow(color: shadowColor, radius: 30, y: 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(borderColor, lineWidth: 2)
                        )
                    
                    VStack(spacing: 30) {
                        // --- A. 数字区域 ---
                        VStack(spacing: 10) {
                            Text("\(trainer.currentNumber)")
                                .font(SurrealTheme.Typography.number(110)) // 加大字号
                                .foregroundStyle(textColor)
                                .contentTransition(.numericText())
                                .shadow(color: textColor.opacity(0.3), radius: 10, y: 5)
                            
                            // 点击提示
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Toucher pour écouter")
                            }
                            .font(.caption)
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                        }
                        .scaleEffect(trainer.status == .listening ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: trainer.status == .listening)
                        .onTapGesture {
                            trainer.speakTarget()
                        }
                        
                        // --- B. 动态反馈区域 (整合在卡片内) ---
                        VStack(spacing: 12) {
                            // 1. 错误反馈 (红色胶囊)
                            if !trainer.capturedWrongText.isEmpty && trainer.status != .correct {
                                VStack(spacing: 4) {
                                    Text("Vous avez dit (识别为):")
                                        .font(.caption)
                                        .foregroundStyle(Color.red.opacity(0.8))
                                    
                                    Text("\"\(trainer.capturedWrongText)\"")
                                        .font(SurrealTheme.Typography.header(22))
                                        .foregroundStyle(Color.red)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // 2. 正确提示 (绿色)
                            if trainer.status == .correct {
                                Text("Excellent !")
                                    .font(SurrealTheme.Typography.header(28))
                                    .foregroundStyle(Color.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            // 3. 答案提示 (用户开启开关后显示)
                            if trainer.showFrenchText && trainer.status != .correct {
                                Text(trainer.targetText)
                                    .font(SurrealTheme.Typography.body(22))
                                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                                    .padding(.top, 5)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: 80) // 给反馈区域预留固定高度，防止跳动
                    }
                }
                .offset(x: shakeOffset)
                // 监听错误状态触发震动
                .onChange(of: trainer.status) { newStatus in
                    if newStatus == .wrong { triggerShake() }
                }
                
                // 3. 中间操作栏 (找回了显示文本开关)
                Button {
                    withAnimation { trainer.showFrenchText.toggle() }
                } label: {
                    HStack {
                        Image(systemName: trainer.showFrenchText ? "eye.slash.fill" : "eye.fill")
                        Text(trainer.showFrenchText ? "Masquer le texte" : "Afficher le texte")
                    }
                    .font(SurrealTheme.Typography.body(16))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
                    )
                }
                .padding(.top, 30)
                
                Spacer()
                
                // 4. 底部控制栏
                VStack(spacing: 20) {
                    // 状态提示语 (移到按钮上方)
                    Text(statusMessage)
                        .font(SurrealTheme.Typography.body(16))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.6))
                        .frame(height: 20)
                        .id("statusLabel") // 避免动画时的文字模糊
                    
                    HStack(spacing: 50) {
                        // 跳过按钮
                        Button {
                            withAnimation { trainer.generateNew() }
                        } label: {
                            Image(systemName: "arrow.forward")
                                .font(.title2)
                                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                                .frame(width: 60, height: 60)
                                .background(Color.white.opacity(0.5))
                                .clipShape(Circle())
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
                                    .frame(width: 84, height: 84)
                                    .shadow(color: micButtonColor.opacity(0.4), radius: 12, y: 6)
                                
                                Image(systemName: micIconName)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.white)
                                    .contentTransition(.symbolEffect(.replace)) // iOS 17 图标切换动画
                            }
                        }
                    }
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
        if trainer.status == .listening { return "square.fill" } // 录音中显示停止符号
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
    
    func triggerShake() {
        let duration = 0.5
        let amount: CGFloat = 10
        withAnimation(.default) { shakeOffset = amount }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation { shakeOffset = -amount } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { shakeOffset = amount * 0.5 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { withAnimation { shakeOffset = -amount * 0.5 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { withAnimation { shakeOffset = 0 } }
    }
}
