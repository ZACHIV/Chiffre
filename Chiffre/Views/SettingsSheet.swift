import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var trainer: NumberTrainer
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ListeningCanvasTheme.background
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Capsule()
                        .fill(ListeningCanvasTheme.secondary.opacity(0.35))
                        .frame(width: 42, height: 5)
                        .padding(.top, 14)

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Réglages")
                                .font(SurrealTheme.Typography.title(32))
                                .foregroundStyle(ListeningCanvasTheme.title)

                            Text("日出配色下，只保留对听力真正有帮助的控制。")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(ListeningCanvasTheme.body)
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(ListeningCanvasTheme.title)
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.28))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    SunriseSection {
                        LanguageSelectionSection()
                    }

                    SunriseSection {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mode (模式)")
                                .font(SurrealTheme.Typography.header(16))
                                .foregroundStyle(ListeningCanvasTheme.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(GameMode.allCases) { mode in
                                        ModeCapsule(mode: mode, isSelected: trainer.mode == mode) {
                                            trainer.mode = mode
                                            trainer.generateNew(speakNow: false)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    SunriseSection {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Vitesse (速度)")
                                    .font(SurrealTheme.Typography.header(16))
                                    .foregroundStyle(ListeningCanvasTheme.secondary)

                                Spacer()

                                Text("\(trainer.speedLabel) · \(String(format: "%.2f", trainer.playbackRate))")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(ListeningCanvasTheme.sunrise)
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                            }

                            Slider(
                                value: Binding(
                                    get: { trainer.playbackRate },
                                    set: { trainer.playbackRate = $0 }
                                ),
                                in: 0.38...0.68,
                                step: 0.01
                            )
                            .tint(SurrealTheme.colors.coral)

                            SpeedPreviewMeter(level: trainer.speedLevel)

                            HStack(spacing: 10) {
                                SpeedPresetPill(title: "慢一点", value: 0.44, trainer: trainer)
                                SpeedPresetPill(title: "推荐", value: 0.56, trainer: trainer)
                                SpeedPresetPill(title: "自然", value: 0.64, trainer: trainer)
                            }

                            Button {
                                SpeechManager.shared.speak(LanguageVoiceManager.shared.getTestPhrase(), rate: trainer.currentRate)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "speaker.wave.2.fill")
                                    Text("试听当前语速")
                                }
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(ListeningCanvasTheme.title)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    SunriseSection {
                        VoiceSelectionSection()
                    }

                    SunriseSection {
                        rangeSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .animation(.spring(response: 0.36, dampingFraction: 0.82), value: trainer.mode)
            .animation(.easeInOut(duration: 0.22), value: trainer.speedLevel)
        }
    }

    @ViewBuilder
    private var rangeSection: some View {
        if trainer.mode == .number {
            VStack(alignment: .leading, spacing: 16) {
                Text("Plage (范围)")
                    .font(SurrealTheme.Typography.header(16))
                    .foregroundStyle(ListeningCanvasTheme.secondary)

                VStack(spacing: 10) {
                    HStack {
                        Text("0 - \(trainer.maxRange)")
                            .font(SurrealTheme.Typography.body(18))
                            .monospacedDigit()
                            .foregroundStyle(ListeningCanvasTheme.title)
                        Spacer()
                    }

                    Slider(value: Binding(
                        get: { Double(trainer.maxRange) },
                        set: { trainer.maxRange = Int($0) }
                    ), in: 10...9999, step: 10)
                    .tint(SurrealTheme.colors.waterBlue)
                }

                HStack(spacing: 12) {
                    PresetButton(label: "简单", value: 10, trainer: trainer)
                    PresetButton(label: "中等", value: 100, trainer: trainer)
                    PresetButton(label: "困难", value: 1000, trainer: trainer)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("当前模式")
                    .font(SurrealTheme.Typography.header(16))
                    .foregroundStyle(ListeningCanvasTheme.secondary)

                Text(getModeDescription(for: trainer.mode))
                    .font(SurrealTheme.Typography.body(16))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .background(isSelected ? ListeningCanvasTheme.primaryGradient : LinearGradient(colors: [Color.white.opacity(0.34), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundStyle(isSelected ? Color.white : ListeningCanvasTheme.title)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(isSelected ? Color.white.opacity(0.18) : ListeningCanvasTheme.panelStroke, lineWidth: 1)
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
                .background(isSelected ? ListeningCanvasTheme.primaryGradient : LinearGradient(colors: [Color.white.opacity(0.36), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .foregroundStyle(isSelected ? .white : ListeningCanvasTheme.title)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white.opacity(0.18) : ListeningCanvasTheme.panelStroke, lineWidth: 1)
                )
        }
    }
}

// MARK: - 语音选择组件
struct VoiceSelectionSection: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Voix (语音)")
                    .font(SurrealTheme.Typography.header(16))
                    .foregroundStyle(ListeningCanvasTheme.secondary)

                Spacer()

                // 试听按钮
                Button {
                    SpeechManager.shared.speak(lm.getTestPhrase())
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("试听")
                    }
                    .font(.caption)
                    .foregroundStyle(ListeningCanvasTheme.sunrise)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ListeningCanvasTheme.sunrise.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            // 根据当前语言显示对应的语音选择
            if lm.currentLanguage == .french {
                FrenchVoiceSelection()
            } else {
                SpanishVoiceSelection()
            }
        }
    }
}

struct FrenchVoiceSelection: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FrenchVoice.allCases) { voice in
                    VoiceCapsule(
                        voice: voice,
                        isSelected: lm.selectedFrenchVoice == voice
                    ) {
                        lm.selectedFrenchVoice = voice
                        SpeechManager.shared.speak("Bonjour, je m'appelle \(voice.rawValue)")
                    }
                }
            }
        }
    }
}

struct SpanishVoiceSelection: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SpanishVoice.allCases) { voice in
                    VoiceCapsule(
                        voice: voice,
                        isSelected: lm.selectedSpanishVoice == voice
                    ) {
                        lm.selectedSpanishVoice = voice
                        SpeechManager.shared.speak("Hola, me llamo \(voice.rawValue)")
                    }
                }
            }
        }
    }
}

// MARK: - 语言选择组件
struct LanguageSelectionSection: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Langue (语言)")
                .font(SurrealTheme.Typography.header(16))
                .foregroundStyle(ListeningCanvasTheme.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { language in
                        LanguageCapsule(
                            language: language,
                            isSelected: lm.currentLanguage == language
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                lm.currentLanguage = language
                            }
                            testLanguage(language)
                        }
                    }
                }
            }
        }
    }

    private func testLanguage(_ language: AppLanguage) {
        let phrase: String
        switch language {
        case .french:  phrase = "Français sélectionné"
        case .spanish: phrase = "Español seleccionado"
        }
        SpeechManager.shared.speak(phrase)
    }
}

// 辅助组件：语言选择胶囊
struct LanguageCapsule: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(language.icon)
                Text(language.displayName)
                    .font(.caption).bold()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(isSelected ? ListeningCanvasTheme.primaryGradient : LinearGradient(colors: [Color.white.opacity(0.34), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundStyle(isSelected ? .white : ListeningCanvasTheme.title)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(isSelected ? Color.white.opacity(0.18) : ListeningCanvasTheme.panelStroke, lineWidth: 1)
            )
        }
    }
}

// 辅助组件：语音选择胶囊
struct VoiceCapsule: View {
    let voice: any LanguageVoice
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
            .background(isSelected ? ListeningCanvasTheme.primaryGradient : LinearGradient(colors: [Color.white.opacity(0.34), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundStyle(isSelected ? .white : ListeningCanvasTheme.title)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(isSelected ? Color.white.opacity(0.18) : ListeningCanvasTheme.panelStroke, lineWidth: 1)
            )
        }
    }
}

struct SunriseSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ImpressionistGlassCard(cornerRadius: 28) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
        }
    }
}

struct SpeedPreviewMeter: View {
    let level: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(1...4, id: \.self) { index in
                Capsule()
                    .fill(index <= level ? ListeningCanvasTheme.sunrise : ListeningCanvasTheme.mist.opacity(0.55))
                    .frame(width: 10, height: CGFloat(14 + index * 7))
                    .scaleEffect(y: index <= level ? 1 : 0.72, anchor: .bottom)
                    .animation(.spring(response: 0.32, dampingFraction: 0.76), value: level)
            }

            Text("越快越接近真实语流")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .padding(.leading, 4)
        }
    }
}

struct SpeedPresetPill: View {
    let title: String
    let value: Double
    @ObservedObject var trainer: NumberTrainer

    private var isSelected: Bool {
        abs(trainer.playbackRate - value) < 0.011
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                trainer.playbackRate = value
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : ListeningCanvasTheme.title)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? ListeningCanvasTheme.primaryGradient : LinearGradient(colors: [Color.white.opacity(0.36), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.white.opacity(0.18) : ListeningCanvasTheme.panelStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
