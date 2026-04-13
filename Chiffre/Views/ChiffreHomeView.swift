import SwiftUI

struct ChiffreHomeView: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var languageAnimationToken = 0

    var body: some View {
        GeometryReader { proxy in
            let metrics = ListeningCanvasTheme.Metrics(size: proxy.size)

            ZStack {
                ListeningBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ListeningHomeHeader(
                            metrics: metrics,
                            currentLanguage: lm.currentLanguage,
                            appName: trainer.dataProvider.appName,
                            appSubtitle: "把最常见的生活口语，拆成可以反复训练的句子。",
                            languageSelection: languageSelection,
                            modeSelection: modeTrigger
                        )
                        .padding(.bottom, metrics.sectionSpacing)

                        ListeningStageView(
                            answerState: trainer.answerState,
                            currentDisplay: trainer.currentDisplay,
                            annotation: trainer.revealAnnotation,
                            footnote: stageFootnote,
                            accent: accentColor,
                            textColor: answerTextColor,
                            metrics: metrics,
                            replay: trainer.replayFull
                        )
                        .padding(.bottom, metrics.sectionSpacing)

                        if trainer.answerState != .waiting {
                            ListeningSupportPanel(
                                feedbackIcon: feedbackIcon,
                                feedbackTitle: feedbackTitle,
                                feedbackColor: accentColor,
                                sentenceView: highlightedSentenceText(),
                                sentenceAccessibilityLabel: trainer.sentenceContext
                            )
                            .padding(.bottom, 20)
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: proxy.size.height - metrics.contentBottomReserve, alignment: .top)
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.top, metrics.topPadding)
                    .padding(.bottom, metrics.bottomPadding)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ListeningBottomActionRow(
                    primaryTitle: trainer.answerState == .waiting ? trainer.dataProvider.revealText : trainer.dataProvider.nextText,
                    primaryIcon: trainer.answerState == .waiting ? "checkmark.circle.fill" : "arrow.right.circle.fill",
                    primaryGradient: trainer.answerState == .correct ? ListeningCanvasTheme.successGradient : ListeningCanvasTheme.primaryGradient,
                    primaryAction: primaryAction
                )
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, metrics.bottomDockSpacing)
                .padding(.bottom, metrics.bottomDockSpacing)
                .background(Color.clear)
            }
        }
    }

    private var languageSelection: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button(language.icon + " " + language.displayName) {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) {
                        lm.currentLanguage = language
                    }
                    languageAnimationToken += 1
                }
            }
        } label: {
            ListeningLanguageButton(
                language: lm.currentLanguage,
                animationToken: languageAnimationToken
            )
        }
        .buttonStyle(.plain)
        .onChange(of: lm.currentLanguage) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.52)) {
                languageAnimationToken += 1
            }
        }
    }

    private var modeTrigger: some View {
        Menu {
            ForEach(GameMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                        trainer.mode = mode
                    }
                    trainer.generateNew(speakNow: false)
                } label: {
                    Label(mode.rawValue, systemImage: mode.icon)
                }
            }
        } label: {
            ListeningModeTrigger(mode: trainer.mode)
        }
        .buttonStyle(.plain)
    }

    private var accentColor: Color {
        switch trainer.answerState {
        case .waiting: return ListeningCanvasTheme.sunrise
        case .revealed: return ListeningCanvasTheme.water
        case .correct: return ListeningCanvasTheme.leaf
        case .wrong: return ListeningCanvasTheme.sunrise
        }
    }

    private var answerTextColor: Color {
        trainer.answerState == .correct ? ListeningCanvasTheme.leaf : ListeningCanvasTheme.title
    }

    private var stageFootnote: String {
        switch trainer.answerState {
        case .waiting: return "先完整听一句，确认后直接揭晓。"
        case .revealed: return "答案已展开，继续下一题。"
        case .correct: return trainer.dataProvider.successText
        case .wrong: return trainer.dataProvider.gentleWrongText
        }
    }

    private var feedbackIcon: String {
        switch trainer.answerState {
        case .waiting: return "waveform"
        case .revealed: return "eye.fill"
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "arrow.triangle.2.circlepath.circle.fill"
        }
    }

    private var feedbackTitle: String {
        switch trainer.answerState {
        case .waiting: return "准备好时就揭晓答案"
        case .revealed: return "答案已揭晓"
        case .correct: return trainer.dataProvider.successText
        case .wrong: return trainer.dataProvider.gentleWrongText
        }
    }

    private func primaryAction() {
        if trainer.answerState == .waiting {
            trainer.verify()
        } else {
            trainer.generateNew()
        }
    }

    private func highlightedSentenceText() -> Text {
        let sentence = trainer.sentenceContext
        let highlight = trainer.speakableContent
        let baseColor = ListeningCanvasTheme.body

        guard !highlight.isEmpty,
              let range = sentence.range(of: highlight, options: .caseInsensitive) else {
            return Text(sentence).foregroundStyle(baseColor)
        }

        let before = String(sentence[..<range.lowerBound])
        let emphasized = String(sentence[range])
        let after = String(sentence[range.upperBound...])

        return Text(before).foregroundStyle(baseColor)
            + Text(emphasized).foregroundStyle(ListeningCanvasTheme.sunrise).bold()
            + Text(after).foregroundStyle(baseColor)
    }
}

struct ListeningHomeHeader<LanguageSelection: View, ModeSelection: View>: View {
    let metrics: ListeningCanvasTheme.Metrics
    let currentLanguage: AppLanguage
    let appName: String
    let appSubtitle: String
    let languageSelection: LanguageSelection
    let modeSelection: ModeSelection

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.headerSpacing) {
            HStack(alignment: .top) {
                languageSelection
                Spacer(minLength: 16)
            }
            .padding(.bottom, 10)

            Text(appName)
                .font(SurrealTheme.Typography.title(metrics.brandSize))
                .foregroundStyle(ListeningCanvasTheme.title)
                .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.45), radius: 10, y: 5)
                .contentTransition(.opacity)
                .frame(maxWidth: .infinity, alignment: .center)
                .id(currentLanguage)
                .padding(.top, 12)
                .padding(.bottom, 6)

            Text(appSubtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 18)

            HStack {
                modeSelection
                Spacer(minLength: 16)
            }
            .padding(.top, 4)
        }
    }
}

struct ListeningLanguageButton: View {
    let language: AppLanguage
    let animationToken: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(language.icon)
                .font(.system(size: 16))

            Text(language.displayName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))

            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .symbolEffect(.bounce, value: animationToken)

            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ListeningCanvasTheme.sunrise.opacity(0.9))
                .symbolEffect(.pulse.byLayer, value: animationToken)
                .scaleEffect(animationToken.isMultiple(of: 2) ? 0.92 : 1.04)
        }
        .foregroundStyle(ListeningCanvasTheme.title)
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.64),
                            SurrealTheme.colors.lavenderMist.opacity(0.3),
                            SurrealTheme.colors.skyDawn.opacity(0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
        )
        .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.16), radius: 10, y: 4)
        .accessibilityLabel("语言：\(language.displayName)")
        .accessibilityHint("点击切换语言")
    }
}

struct ListeningModeTrigger: View {
    let mode: GameMode

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Catégorie")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.1)

            HStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityHidden(true)

                Text(mode.rawValue)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(ListeningCanvasTheme.title)

            Text(mode.summary)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottomLeading) {
            Rectangle()
                .fill(ListeningCanvasTheme.panelStroke.opacity(0.9))
                .frame(width: 198, height: 1)
                .offset(y: 12)
        }
        .accessibilityLabel(mode.rawValue)
        .accessibilityHint("点击更改类别")
    }
}
