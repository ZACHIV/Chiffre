import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let metrics = ListeningCanvasTheme.Metrics(size: proxy.size)

            ZStack {
                ListeningBackground()

                VStack(spacing: metrics.sectionSpacing) {
                    header(metrics: metrics)

                    ListeningStageView(
                        mode: trainer.mode,
                        answerState: trainer.answerState,
                        currentDisplay: trainer.currentDisplay,
                        footnote: stageFootnote,
                        accent: accentColor,
                        textColor: answerTextColor,
                        borderColor: accentColor,
                        metrics: metrics,
                        replay: trainer.replayFull
                    )

                    ListeningSupportPanel(
                        userInput: $trainer.userInput,
                        placeholder: trainer.dataProvider.inputPlaceholder,
                        keyboardType: trainer.preferredKeyboardType,
                        hasHintContent: trainer.hasHintContent,
                        hintMessage: trainer.hintMessage,
                        hintVisual: trainer.hintVisual,
                        answerState: trainer.answerState,
                        feedbackIcon: feedbackIcon,
                        feedbackTitle: feedbackTitle,
                        feedbackColor: accentColor,
                        sentenceView: highlightedSentenceText(),
                        hintTitle: compactHintTitle,
                        replay: trainer.replayFull,
                        replayFocused: trainer.replayFocused,
                        requestHint: trainer.requestHint,
                        submit: trainer.verify,
                        isInputFocused: $isInputFocused
                    )

                    Spacer(minLength: 0)

                    ListeningBottomActionRow(
                        primaryTitle: trainer.answerState == .waiting ? trainer.dataProvider.revealText : trainer.dataProvider.nextText,
                        primaryIcon: trainer.answerState == .waiting ? "checkmark.circle.fill" : "arrow.right.circle.fill",
                        primaryGradient: trainer.answerState == .correct ? ListeningCanvasTheme.successGradient : ListeningCanvasTheme.primaryGradient,
                        primaryAction: primaryAction,
                        settingsAction: { showSettings = true }
                    )
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
            }
        }
        .onAppear {
            isInputFocused = trainer.answerState == .waiting
        }
        .onChange(of: trainer.answerState) { _, state in
            isInputFocused = state == .waiting
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.height(520)])
                .presentationCornerRadius(30)
        }
    }

    private func header(metrics: ListeningCanvasTheme.Metrics) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(trainer.dataProvider.appName)
                    .font(SurrealTheme.Typography.title(metrics.brandSize))
                    .foregroundStyle(ListeningCanvasTheme.title)
                    .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                    .contentTransition(.opacity)
                    .id(lm.currentLanguage)

                Text(lm.currentLanguage.icon + " " + lm.currentLanguage.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.28))
                    )
                    .overlay(
                        Capsule()
                            .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
                    )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(scoreText)
                    .font(.system(size: 21, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(ListeningCanvasTheme.title)

                Text("速度 \(trainer.speedLabel)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)

                if trainer.currentStreak > 0 {
                    Text("连对 \(trainer.currentStreak)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.sunrise)
                }
            }
        }
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
        case .waiting: return "完整语境播放，点击画布可再听一遍"
        case .revealed: return "答案已揭晓，继续下一题"
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
        case .waiting: return ""
        case .revealed: return "答案已揭晓"
        case .correct: return trainer.dataProvider.successText
        case .wrong: return trainer.dataProvider.gentleWrongText
        }
    }

    private var compactHintTitle: String {
        switch trainer.hintStage {
        case .none: return "提示"
        case .replayFull: return "聚焦"
        case .replayFocused: return "结构"
        case .structure: return "支架"
        case .scaffold: return "半揭晓"
        case .partialReveal: return "答案"
        case .fullReveal: return "完成"
        }
    }

    private var scoreText: String {
        trainer.sessionTotal == 0 ? "--" : "\(trainer.sessionCorrect)/\(trainer.sessionTotal)"
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
            return Text(sentence).foregroundColor(baseColor)
        }

        let before = String(sentence[..<range.lowerBound])
        let emphasized = String(sentence[range])
        let after = String(sentence[range.upperBound...])

        return Text(before).foregroundColor(baseColor)
            + Text(emphasized).foregroundColor(ListeningCanvasTheme.sunrise).bold()
            + Text(after).foregroundColor(baseColor)
    }
}
