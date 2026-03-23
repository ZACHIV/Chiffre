import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool

    private let metricColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection
                    metricsSection
                    practiceSection
                    responseSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .onAppear {
            isInputFocused = trainer.answerState == .waiting
        }
        .onChange(of: trainer.answerState) { _, state in
            isInputFocused = state == .waiting
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trainer.dataProvider.appName)
                        .font(SurrealTheme.Typography.title(34))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)

                    Text("更清晰的听写训练，先听，再输入，再复盘。")
                        .font(SurrealTheme.Typography.body(15))
                        .foregroundStyle(SurrealTheme.colors.textSecondary)
                }

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(SurrealTheme.colors.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(SurrealTheme.colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                ChiffreBadge(title: lm.currentLanguage.displayName, systemImage: "globe")
                ChiffreBadge(title: trainer.mode.rawValue, systemImage: trainer.mode.icon, tint: SurrealTheme.colors.coral)
            }
        }
    }

    private var metricsSection: some View {
        LazyVGrid(columns: metricColumns, spacing: 12) {
            ChiffreMetricCard(
                title: "准确率",
                value: trainer.sessionTotal == 0 ? "--" : "\(trainer.sessionCorrect)/\(trainer.sessionTotal)",
                caption: trainer.sessionTotal == 0 ? "开始一轮后显示" : "当前会话表现"
            )

            ChiffreMetricCard(
                title: "连对",
                value: trainer.currentStreak == 0 ? "0" : "\(trainer.currentStreak)",
                caption: trainer.currentStreak == 0 ? "保持节奏" : "连续答对中",
                tint: SurrealTheme.colors.coral
            )

            ChiffreMetricCard(
                title: "语速",
                value: trainer.speedLabel,
                caption: "会随表现自动调整",
                tint: SurrealTheme.colors.lilyPad
            )
        }
    }

    private var practiceSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Current Drill",
                title: trainer.mode.rawValue,
                caption: modeSummary
            )

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(SurrealTheme.colors.surfaceStrong)

                    VStack(spacing: 12) {
                        if trainer.answerState == .waiting {
                            Image(systemName: "ear.and.waveform")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(SurrealTheme.colors.coral)

                            Text("先听音，再输入你听到的内容")
                                .font(SurrealTheme.Typography.header(22))
                                .foregroundStyle(SurrealTheme.colors.deepIndigo)

                            Text("随时可以重播音频，不需要先打开设置。")
                                .font(SurrealTheme.Typography.body(14))
                                .foregroundStyle(SurrealTheme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(trainer.currentDisplay)
                                .font(currentDisplayFont)
                                .foregroundStyle(answerTint)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)

                            ChiffreStatusTag(title: answerStateLabel, tint: answerTint)
                        }
                    }
                    .padding(24)
                }
                .frame(height: 220)

                HStack(spacing: 10) {
                    ChiffreBadge(title: trainer.speedLabel, systemImage: "waveform.path.ecg", tint: SurrealTheme.colors.lilyPad)

                    if trainer.mode == .number {
                        ChiffreBadge(title: "0 - \(trainer.maxRange)", systemImage: "number.square", tint: SurrealTheme.colors.coral)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var responseSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Response",
                title: trainer.answerState == .waiting ? "输入答案" : "结果反馈",
                caption: trainer.answerState == .waiting ? "留空点击主按钮会直接显示答案。" : feedbackCaption
            )

            switch trainer.answerState {
            case .waiting:
                VStack(alignment: .leading, spacing: 12) {
                    TextField(trainer.dataProvider.inputPlaceholder, text: $trainer.userInput)
                        .focused($isInputFocused)
                        .font(SurrealTheme.Typography.body(18))
                        .keyboardType(trainer.preferredKeyboardType)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 18)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(SurrealTheme.colors.surfaceStrong)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(SurrealTheme.colors.border, lineWidth: 1)
                        )
                        .onSubmit {
                            trainer.verify()
                        }

                    Text("支持数字、日期、电话、价格等格式；系统会做适度宽松匹配。")
                        .font(SurrealTheme.Typography.body(13))
                        .foregroundStyle(SurrealTheme.colors.textSecondary)
                }

            case .revealed, .correct, .wrong:
                VStack(alignment: .leading, spacing: 14) {
                    feedbackBanner
                    sentenceCard
                }
            }
        }
    }

    private var feedbackBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: feedbackIcon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(answerTint)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(answerTint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(answerStateLabel)
                    .font(SurrealTheme.Typography.header(18))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)

                if trainer.answerState == .wrong {
                    Text("你的输入：\(trainer.userInput)")
                        .font(SurrealTheme.Typography.body(14))
                        .foregroundStyle(SurrealTheme.colors.textSecondary)
                } else if trainer.answerState == .revealed {
                    Text("这次不计分，先看答案和语境再继续。")
                        .font(SurrealTheme.Typography.body(14))
                        .foregroundStyle(SurrealTheme.colors.textSecondary)
                } else {
                    Text("答对了，下一题会继续沿着当前语速推进。")
                        .font(SurrealTheme.Typography.body(14))
                        .foregroundStyle(SurrealTheme.colors.textSecondary)
                }
            }
        }
    }

    private var sentenceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("语境复盘")
                .font(SurrealTheme.Typography.label(13))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            highlightedSentenceText()
                .font(SurrealTheme.Typography.body(16))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SurrealTheme.colors.surfaceStrong)
        )
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(SurrealTheme.colors.border)

            HStack(spacing: 10) {
                ChiffreActionButton(title: "重播", systemImage: "speaker.wave.2.fill", style: .secondary) {
                    trainer.replay()
                }

                ChiffreActionButton(title: primaryActionTitle, systemImage: primaryActionIcon, style: .primary, fullWidth: true) {
                    if trainer.answerState == .waiting {
                        trainer.verify()
                    } else {
                        trainer.generateNew()
                    }
                }

                ChiffreActionButton(title: "设置", systemImage: "slider.horizontal.3", style: .secondary) {
                    showSettings = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial)
    }

    private var currentDisplayFont: Font {
        if trainer.currentDisplay.count > 14 { return SurrealTheme.Typography.number(34) }
        if trainer.currentDisplay.count > 8 { return SurrealTheme.Typography.number(42) }
        return SurrealTheme.Typography.number(58)
    }

    private var answerTint: Color {
        switch trainer.answerState {
        case .waiting, .revealed:
            return SurrealTheme.colors.deepIndigo
        case .correct:
            return SurrealTheme.colors.lilyPad
        case .wrong:
            return SurrealTheme.colors.danger
        }
    }

    private var answerStateLabel: String {
        switch trainer.answerState {
        case .waiting:
            return "等待输入"
        case .revealed:
            return "已显示答案"
        case .correct:
            return "回答正确"
        case .wrong:
            return "需要再练一次"
        }
    }

    private var feedbackCaption: String {
        switch trainer.answerState {
        case .revealed:
            return "这次没有计分，适合先建立题型感觉。"
        case .correct:
            return "你的输入和目标答案已经匹配。"
        case .wrong:
            return "对照语境找出差异，再继续下一题。"
        case .waiting:
            return ""
        }
    }

    private var feedbackIcon: String {
        switch trainer.answerState {
        case .revealed:
            return "eye.fill"
        case .correct:
            return "checkmark.circle.fill"
        case .wrong:
            return "xmark.circle.fill"
        case .waiting:
            return "square.fill"
        }
    }

    private var primaryActionTitle: String {
        switch trainer.answerState {
        case .waiting:
            return trainer.canVerify ? trainer.dataProvider.revealText : revealAnswerTitle
        case .revealed, .correct, .wrong:
            return trainer.dataProvider.nextText
        }
    }

    private var primaryActionIcon: String {
        switch trainer.answerState {
        case .waiting:
            return trainer.canVerify ? "checkmark" : "eye"
        case .revealed, .correct, .wrong:
            return "arrow.right"
        }
    }

    private var revealAnswerTitle: String {
        switch lm.currentLanguage {
        case .french:
            return "Réponse"
        case .spanish:
            return "Respuesta"
        }
    }

    private var modeSummary: String {
        if trainer.mode == .number {
            return "数字范围 0 - \(trainer.maxRange)，适合做基础节奏和转写训练。"
        }

        return "当前题型会自动生成真实语境中的 \(trainer.mode.rawValue) 练习。"
    }

    private func highlightedSentenceText() -> Text {
        let sentence = trainer.sentenceContext
        let highlight = trainer.speakableContent
        let baseColor = SurrealTheme.colors.textSecondary

        guard !highlight.isEmpty,
              let range = sentence.range(of: highlight, options: .caseInsensitive) else {
            return Text(sentence).foregroundColor(baseColor)
        }

        let before = String(sentence[..<range.lowerBound])
        let highlighted = String(sentence[range])
        let after = String(sentence[range.upperBound...])

        return Text(before).foregroundColor(baseColor)
        + Text(highlighted).foregroundColor(answerTint).bold()
        + Text(after).foregroundColor(baseColor)
    }
}
