import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var showSettings = false

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
                        annotation: trainer.revealAnnotation,
                        footnote: stageFootnote,
                        accent: accentColor,
                        textColor: answerTextColor,
                        borderColor: accentColor,
                        metrics: metrics,
                        replay: trainer.replayFull
                    )

                    ListeningSupportPanel(
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
                        requestHint: trainer.requestHint
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
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.height(520)])
                .presentationCornerRadius(30)
        }
    }

    private func header(metrics: ListeningCanvasTheme.Metrics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Menu {
                    ForEach(AppLanguage.allCases) { language in
                        Button(language.icon + " " + language.displayName) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                lm.currentLanguage = language
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(lm.currentLanguage.icon)
                        Text(lm.currentLanguage.displayName)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(ListeningCanvasTheme.pillGradient)
                    )
                    .overlay(
                        Capsule()
                            .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text(trainer.dataProvider.appName)
                .font(SurrealTheme.Typography.title(metrics.brandSize))
                .foregroundStyle(ListeningCanvasTheme.title)
                .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                .contentTransition(.opacity)
                .frame(maxWidth: .infinity, alignment: .center)
                .id(lm.currentLanguage)
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
        case .waiting: return "先听，再写；点验证就直接揭晓。"
        case .revealed: return "数字已展开，继续下一题。"
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
        trainer.hasHintContent ? "再显一位" : "提示一位"
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
