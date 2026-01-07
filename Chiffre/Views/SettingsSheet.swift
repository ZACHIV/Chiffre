import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var trainer: NumberTrainer
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Monet-inspired soft gradient background
            LinearGradient(
                colors: [
                    SurrealTheme.colors.skyDawn.opacity(0.3),
                    SurrealTheme.colors.lavenderMist.opacity(0.4),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 顶部抓手
                Capsule().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 5).padding(.top, 15)
                
                Text("Réglages (设置)")
                    .font(SurrealTheme.Typography.header(24))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                
                // MARK: - 1. 模式选择 (横向滚动胶囊)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mode (模式)")
                        .font(SurrealTheme.Typography.header(16))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 30)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(GameMode.allCases) { mode in
                                ModeCapsule(mode: mode, isSelected: trainer.mode == mode) {
                                    trainer.mode = mode
                                    trainer.generateNew(speakNow: false)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
                
                Divider().padding(.horizontal, 30)
                
                // MARK: - 2. 语音选择 (横向滚动胶囊)
                VoiceSelectionSection()
                
                Divider().padding(.horizontal, 30)
                
                // MARK: - 2. 动态内容区
                // 只有在数字模式下，才显示范围调节
                if trainer.mode == .number {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("范围: 0 - \(trainer.maxRange)")
                                    .font(SurrealTheme.Typography.body(18))
                                    .monospacedDigit()
                                Spacer()
                            }
                            
                            Slider(value: Binding(
                                get: { Double(trainer.maxRange) },
                                set: { trainer.maxRange = Int($0) }
                            ), in: 10...9999, step: 10)
                            .tint(SurrealTheme.colors.coral)
                        }
                        
                        // 预设按钮 (恢复了！)
                        HStack(spacing: 12) {
                            PresetButton(label: "简单 (10)", value: 10, trainer: trainer)
                            PresetButton(label: "中等 (100)", value: 100, trainer: trainer)
                            PresetButton(label: "困难 (1000)", value: 1000, trainer: trainer)
                        }
                    }
                    .padding(.horizontal, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // 其他模式的提示文案
                    ContentUnavailableView {
                        Image(systemName: trainer.mode.icon)
                            .font(.largeTitle)
                            .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                    } description: {
                        Text(getModeDescription(for: trainer.mode))
                            .font(SurrealTheme.Typography.body(16))
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 150)
                }
                
                Spacer()
            }
            .animation(.spring(), value: trainer.mode)
        }
    }
    
    func getModeDescription(for mode: GameMode) -> String {
        switch mode {
        case .phoneNumber: return "生成随机的法国手机号格式\n(06/07 开头)"
        case .price: return "练习含小数点的价格表达\n(如 12,50 €)"
        case .time: return "练习 24 小时制时间表达\n(如 14h30)"
        case .year: return "练习历史年份或近期年份\n(1950 - 2030)"
        case .month: return "练习日期+月份表达\n(如 le 15 janvier)"
        case .trainNumber: return "练习法国火车号码\n(TGV, Intercités, TER)"
        case .flightNumber: return "练习国际航班号\n(如 AF 1234, EK 73)"
        default: return ""
        }
    }
}

// 辅助组件：模式选择胶囊
struct ModeCapsule: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: mode.icon)
                Text(mode.rawValue)
                    .font(.caption).bold()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(isSelected ? SurrealTheme.colors.deepIndigo : Color.black.opacity(0.05))
            .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(SurrealTheme.colors.deepIndigo.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// 辅助组件：预设按钮 (保持之前的逻辑)
struct PresetButton: View {
    let label: String
    let value: Int
    @ObservedObject var trainer: NumberTrainer
    
    var isSelected: Bool { trainer.maxRange == value }
    
    var body: some View {
        Button {
            trainer.maxRange = value
            trainer.generateNew(speakNow: false)
        } label: {
            Text(label)
                .font(.caption).bold()
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? SurrealTheme.colors.coral : Color.white)
                .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        }
    }
}

// MARK: - 语音选择组件
struct VoiceSelectionSection: View {
    @AppStorage("selectedVoice") private var selectedVoice: String = FrenchVoice.amelie.rawValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Voix (语音)")
                    .font(SurrealTheme.Typography.header(16))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 试听按钮
                Button {
                    testCurrentVoice()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("试听")
                    }
                    .font(.caption)
                    .foregroundStyle(SurrealTheme.colors.coral)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(SurrealTheme.colors.coral.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FrenchVoice.allCases) { voice in
                        VoiceCapsule(
                            voice: voice,
                            isSelected: selectedVoice == voice.rawValue
                        ) {
                            selectedVoice = voice.rawValue
                            // 切换语音后立即试听
                            testVoice(voice)
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
        }
    }
    
    private func testCurrentVoice() {
        let voice = FrenchVoice(rawValue: selectedVoice) ?? .amelie
        testVoice(voice)
    }
    
    private func testVoice(_ voice: FrenchVoice) {
        // 测试语音：朗读一个示例句子
        let testPhrases = [
            "Bonjour, je m'appelle \(voice.rawValue)",
            "le quinze janvier",
            "douze euros cinquante"
        ]
        SpeechManager.shared.speak(testPhrases.randomElement()!)
    }
}

// 辅助组件：语音选择胶囊
struct VoiceCapsule: View {
    let voice: FrenchVoice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: voice.icon)
                Text(voice.displayName)
                    .font(.caption).bold()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(isSelected ? SurrealTheme.colors.deepIndigo : Color.black.opacity(0.05))
            .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(SurrealTheme.colors.deepIndigo.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
