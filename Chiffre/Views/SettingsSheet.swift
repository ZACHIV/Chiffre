import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @Environment(\.dismiss) private var dismiss

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SurrealTheme.mainBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        introCard
                        languageSection
                        voiceSection
                        modeSection

                        if trainer.mode == .number {
                            rangeSection
                        }

                        summarySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(SurrealTheme.Typography.label(16))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
        }
    }

    private var introCard: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Practice Setup",
                title: "训练选项",
                caption: "把语言、音色、题型和范围放在同一层，减少来回试错。"
            )

            HStack(spacing: 10) {
                ChiffreBadge(title: lm.currentLanguage.displayName, systemImage: "globe")
                ChiffreBadge(title: trainer.mode.rawValue, systemImage: trainer.mode.icon, tint: SurrealTheme.colors.coral)
            }
        }
    }

    private var languageSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Language",
                title: "训练语言",
                caption: "切换后，听写页和口语页都会立即刷新。"
            )

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            lm.currentLanguage = language
                        }
                        preview(language: language)
                    } label: {
                        ChiffreOptionTile(
                            icon: language == .french ? "globe.europe.africa.fill" : "globe.americas.fill",
                            title: language.displayName,
                            subtitle: language == .french ? "法语数字与常见生活表达" : "西语数字与常见生活表达",
                            isSelected: lm.currentLanguage == language,
                            accent: SurrealTheme.colors.deepIndigo
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var voiceSection: some View {
        ChiffreCard {
            HStack(alignment: .top) {
                ChiffreSectionHeader(
                    eyebrow: "Voice",
                    title: "发音音色",
                    caption: "选择更顺耳的一种，练习时更容易维持专注。"
                )

                Spacer(minLength: 12)

                ChiffreActionButton(title: "试听", systemImage: "speaker.wave.2.fill", style: .secondary) {
                    SpeechManager.shared.speak(lm.getTestPhrase())
                }
            }

            VStack(spacing: 12) {
                if lm.currentLanguage == .french {
                    ForEach(FrenchVoice.allCases) { voice in
                        Button {
                            lm.selectedFrenchVoice = voice
                            SpeechManager.shared.speak("Bonjour, je m'appelle \(voice.rawValue)")
                        } label: {
                            VoiceChoiceRow(
                                title: voice.displayName,
                                subtitle: voice == .amelie ? "推荐做默认训练音色" : "更沉稳，适合对比辨音",
                                icon: voice.icon,
                                isSelected: lm.selectedFrenchVoice == voice
                            )
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    ForEach(SpanishVoice.allCases) { voice in
                        Button {
                            lm.selectedSpanishVoice = voice
                            SpeechManager.shared.speak("Hola, me llamo \(voice.rawValue)")
                        } label: {
                            VoiceChoiceRow(
                                title: voice.displayName,
                                subtitle: voice == .monica ? "推荐做默认训练音色" : "更低沉，适合切换节奏时使用",
                                icon: voice.icon,
                                isSelected: lm.selectedSpanishVoice == voice
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var modeSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Mode",
                title: "练习内容",
                caption: "不再横向滚动，所有模式直接平铺，方便比较。"
            )

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(GameMode.allCases) { mode in
                    Button {
                        trainer.mode = mode
                        trainer.generateNew(speakNow: false)
                    } label: {
                        ChiffreOptionTile(
                            icon: mode.icon,
                            title: mode.rawValue,
                            subtitle: modeDescription(for: mode),
                            isSelected: trainer.mode == mode,
                            accent: SurrealTheme.colors.coral
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var rangeSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Range",
                title: "数字范围",
                caption: "用更明确的难度阶梯控制输入密度。"
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("0 - \(trainer.maxRange)")
                        .font(SurrealTheme.Typography.header(28))
                        .monospacedDigit()
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)

                    Spacer()

                    ChiffreStatusTag(title: rangeLabel, tint: SurrealTheme.colors.lilyPad)
                }

                Slider(
                    value: Binding(
                        get: { Double(trainer.maxRange) },
                        set: { trainer.maxRange = Int($0) }
                    ),
                    in: 10...9999,
                    step: 10
                )
                .tint(SurrealTheme.colors.coral)

                HStack(spacing: 10) {
                    RangePresetChip(title: "简单", value: 10, trainer: trainer)
                    RangePresetChip(title: "中等", value: 100, trainer: trainer)
                    RangePresetChip(title: "困难", value: 1000, trainer: trainer)
                }
            }
        }
    }

    private var summarySection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Ready",
                title: "当前配置",
                caption: "关闭后立即回到练习，不需要再次确认。"
            )

            VStack(alignment: .leading, spacing: 10) {
                summaryRow(title: "语言", value: lm.currentLanguage.displayName)
                summaryRow(title: "音色", value: currentVoiceName)
                summaryRow(title: "题型", value: trainer.mode.rawValue)

                if trainer.mode == .number {
                    summaryRow(title: "范围", value: "0 - \(trainer.maxRange)")
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(SurrealTheme.colors.border)

            ChiffreActionButton(title: "返回练习", systemImage: "checkmark", style: .primary, fullWidth: true) {
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial)
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(SurrealTheme.Typography.label(14))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            Spacer()

            Text(value)
                .font(SurrealTheme.Typography.body(15))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
        }
        .padding(.vertical, 2)
    }

    private var currentVoiceName: String {
        switch lm.currentLanguage {
        case .french:
            return lm.selectedFrenchVoice.displayName
        case .spanish:
            return lm.selectedSpanishVoice.displayName
        }
    }

    private var rangeLabel: String {
        switch trainer.maxRange {
        case ..<50:
            return "基础"
        case ..<300:
            return "进阶"
        default:
            return "挑战"
        }
    }

    private func preview(language: AppLanguage) {
        switch language {
        case .french:
            SpeechManager.shared.speak("Français sélectionné")
        case .spanish:
            SpeechManager.shared.speak("Español seleccionado")
        }
    }

    private func modeDescription(for mode: GameMode) -> String {
        switch mode {
        case .number:
            return "单数字和大数字，适合打基础。"
        case .phoneNumber:
            return "手机号分组转写，更贴近真实输入。"
        case .price:
            return "金额与小数表达，强化节奏辨识。"
        case .time:
            return "24 小时制时间，适合口头信息理解。"
        case .year:
            return "历史年份和近未来年份混合。"
        case .month:
            return "日期与月份组合，训练连读。"
        case .trainNumber:
            return "车次加数字，适合公共交通场景。"
        case .flightNumber:
            return "字母加数字组合，强化听辨跨度。"
        }
    }
}

private struct VoiceChoiceRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? SurrealTheme.colors.deepIndigo.opacity(0.22) : SurrealTheme.colors.deepIndigo.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SurrealTheme.Typography.header(17))
                    .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)

                Text(subtitle)
                    .font(SurrealTheme.Typography.body(13))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.82) : SurrealTheme.colors.textSecondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.surfaceStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.border, lineWidth: 1)
        )
    }
}

private struct RangePresetChip: View {
    let title: String
    let value: Int
    @ObservedObject var trainer: NumberTrainer

    private var isSelected: Bool {
        trainer.maxRange == value
    }

    var body: some View {
        Button {
            trainer.maxRange = value
            trainer.generateNew(speakNow: false)
        } label: {
            Text(title)
                .font(SurrealTheme.Typography.label(14))
                .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? SurrealTheme.colors.coral : SurrealTheme.colors.surfaceStrong)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? SurrealTheme.colors.coral : SurrealTheme.colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
