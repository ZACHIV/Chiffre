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

    private let helperColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private let structureColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 10)
    ]

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection
                    focusSection
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

                    Text("专项训练时间、价格、电话和编号这些最容易糊掉的口头信息。")
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
                ChiffreBadge(title: trainer.currentPrompt.sceneTag, systemImage: "mappin.and.ellipse", tint: SurrealTheme.colors.coral)
                ChiffreBadge(title: trainer.currentPrompt.structureLabel, systemImage: "square.split.2x1", tint: SurrealTheme.colors.lilyPad)
            }
        }
    }

    private var focusSection: some View {
        LazyVGrid(columns: metricColumns, spacing: 12) {
            ChiffreMetricCard(
                title: "场景",
                value: trainer.currentPrompt.sceneTag,
                caption: trainer.currentPrompt.taskTitle
            )

            ChiffreMetricCard(
                title: "结构",
                value: trainer.currentPrompt.structureLabel,
                caption: "先判断类型，再决定怎么听",
                tint: SurrealTheme.colors.coral
            )

            ChiffreMetricCard(
                title: "辅助",
                value: trainer.assistStageLabel,
                caption: "当前语速 \(trainer.speedLabel)",
                tint: SurrealTheme.colors.lilyPad
            )
        }
    }

    private var practiceSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Listening Drill",
                title: trainer.currentPrompt.taskTitle,
                caption: trainer.coachMessage
            )

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(SurrealTheme.colors.surfaceStrong)

                    VStack(spacing: 14) {
                        if trainer.answerState == .waiting {
                            Image(systemName: "ear.and.waveform")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(SurrealTheme.colors.coral)

                            Text("先听整句，再把关键信息写下来")
                                .font(SurrealTheme.Typography.header(22))
                                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                                .multilineTextAlignment(.center)

                            Text(trainer.currentPrompt.coachLine)
                                .font(SurrealTheme.Typography.body(14))
                                .foregroundStyle(SurrealTheme.colors.textSecondary)
                                .multilineTextAlignment(.center)

                            if trainer.shouldShowHintCard, let scaffold = trainer.hintScaffold {
                                Text(scaffold)
                                    .font(SurrealTheme.Typography.number(28))
                                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                                    .padding(.top, 4)
                            }
                        } else {
                            Text(trainer.currentDisplay)
                                .font(currentDisplayFont)
                                .foregroundStyle(answerTint)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)

                            ChiffreStatusTag(title: answerStateLabel, tint: answerTint)

                            Text(trainer.coachMessage)
                                .font(SurrealTheme.Typography.body(14))
                                .foregroundStyle(SurrealTheme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(24)
                }
                .frame(height: 250)

                HStack(spacing: 10) {
                    ChiffreBadge(title: trainer.mode.rawValue, systemImage: trainer.mode.icon)
                    ChiffreBadge(title: "\(trainer.lastReplayLayer.shortTitle)重播", systemImage: "waveform.path.ecg", tint: SurrealTheme.colors.waterBlue)
                }
            }
        }
    }

    private var responseSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: trainer.answerState == .waiting ? "Response" : "Review",
                title: trainer.answerState == .waiting ? "把你听到的内容写下来" : "对照结构复盘",
                caption: trainer.answerState == .waiting ? "不确定时先重听，再决定要不要提示。" : trainer.coachMessage
            )

            if trainer.answerState == .waiting {
                waitingContent
            } else {
                reviewContent
            }
        }
    }

    private var waitingContent: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            Text("支持数字、时间、价格、电话、日期、车次和航班号等结构化转写。")
                .font(SurrealTheme.Typography.body(13))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            LazyVGrid(columns: helperColumns, spacing: 10) {
                ChiffreActionButton(title: "重听整句", systemImage: "speaker.wave.2.fill", style: .secondary, fullWidth: true) {
                    trainer.replayFullSentence()
                }

                ChiffreActionButton(title: trainer.focusReplayTitle, systemImage: "dot.scope", style: .secondary, fullWidth: true) {
                    trainer.replayFocusedSegment()
                }

                ChiffreActionButton(title: "慢速听", systemImage: "tortoise.fill", style: .secondary, fullWidth: true) {
                    trainer.replaySlowSentence()
                }

                ChiffreActionButton(title: trainer.hintButtonTitle, systemImage: "lightbulb.fill", style: .secondary, fullWidth: true) {
                    trainer.advanceHint()
                }
            }

            if trainer.shouldShowHintCard {
                hintCard
            }
        }
    }

    private var hintCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ChiffreStatusTag(title: trainer.assistStageLabel, tint: SurrealTheme.colors.coral)
                Spacer()
                Text(trainer.hintCardTitle)
                    .font(SurrealTheme.Typography.label(13))
                    .foregroundStyle(SurrealTheme.colors.textSecondary)
            }

            Text(trainer.hintCardMessage)
                .font(SurrealTheme.Typography.body(15))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)

            if let scaffold = trainer.hintScaffold {
                Text(scaffold)
                    .font(SurrealTheme.Typography.number(30))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if let partial = trainer.hintPartialReveal {
                Text(partial)
                    .font(SurrealTheme.Typography.number(24))
                    .foregroundStyle(SurrealTheme.colors.coral)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SurrealTheme.colors.surfaceStrong)
        )
    }

    private var reviewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            feedbackBanner
            structureCard
            sentenceCard
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

                Text(feedbackLine)
                    .font(SurrealTheme.Typography.body(14))
                    .foregroundStyle(SurrealTheme.colors.textSecondary)
            }
        }
    }

    private var structureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("结构拆解")
                .font(SurrealTheme.Typography.label(13))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            LazyVGrid(columns: structureColumns, spacing: 10) {
                ForEach(trainer.structureSegments) { segment in
                    ChiffreStructureChip(title: segment.label, value: segment.value, tint: answerTint)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SurrealTheme.colors.surfaceStrong)
        )
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
            return SurrealTheme.colors.coral
        }
    }

    private var answerStateLabel: String {
        switch trainer.answerState {
        case .waiting:
            return "等待输入"
        case .revealed:
            return "已显示答案"
        case .correct:
            return "这次听清了"
        case .wrong:
            return "再抓一次关键位"
        }
    }

    private var feedbackLine: String {
        switch trainer.answerState {
        case .revealed:
            return "这次先不计分，先把这一类结构看顺。"
        case .correct:
            return "你的输入已经对上关键结构，继续保持这个节奏。"
        case .wrong:
            return "你的输入是“\(trainer.userInput)”，先对照结构卡找差异。"
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
            return "waveform.badge.magnifyingglass"
        case .waiting:
            return "square.fill"
        }
    }

    private var primaryActionTitle: String {
        switch trainer.answerState {
        case .waiting:
            return trainer.canVerify ? "对照一下" : "显示答案"
        case .revealed, .correct, .wrong:
            return "下一题"
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
