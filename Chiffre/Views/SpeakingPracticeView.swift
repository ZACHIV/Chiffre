import SwiftUI

struct SpeakingPracticeView: View {
    @StateObject private var trainer = SpeakingTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared

    private var dp: LanguageDataProvider {
        lm.currentLanguage == .french ? FrenchDataProvider() : SpanishDataProvider()
    }

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection
                    promptSection
                    feedbackSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prononciation")
                .font(SurrealTheme.Typography.title(34))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)

            Text("数字会展示在眼前，发音结果会立刻反馈，整套流程更适合连续口语练习。")
                .font(SurrealTheme.Typography.body(15))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            HStack(spacing: 10) {
                ChiffreBadge(title: lm.currentLanguage.displayName, systemImage: "globe")
                ChiffreStatusTag(title: statusTitle, tint: statusTint)
            }
        }
    }

    private var promptSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Speaking Drill",
                title: "看数字，直接开口",
                caption: "数字卡片支持点击重听，录音状态始终可见。"
            )

            VStack(spacing: 14) {
                Button {
                    trainer.speakTarget()
                } label: {
                    VStack(spacing: 10) {
                        Text("\(trainer.currentNumber)")
                            .font(SurrealTheme.Typography.number(72))
                            .foregroundStyle(statusTint)
                            .monospacedDigit()
                            .minimumScaleFactor(0.7)

                        Label(dp.speakTapHint, systemImage: "speaker.wave.2.fill")
                            .font(SurrealTheme.Typography.label(14))
                            .foregroundStyle(SurrealTheme.colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(SurrealTheme.colors.surfaceStrong)
                    )
                }
                .buttonStyle(.plain)

                HStack(spacing: 10) {
                    ChiffreActionButton(title: "重听", systemImage: "speaker.wave.2.fill", style: .secondary) {
                        trainer.speakTarget()
                    }

                    ChiffreActionButton(title: trainer.showFrenchText ? dp.hideTextLabel : dp.showTextLabel, systemImage: trainer.showFrenchText ? "eye.slash.fill" : "eye.fill", style: .secondary, fullWidth: true) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            trainer.showFrenchText.toggle()
                        }
                    }
                }
            }
        }
    }

    private var feedbackSection: some View {
        ChiffreCard {
            ChiffreSectionHeader(
                eyebrow: "Live Feedback",
                title: statusHeadline,
                caption: statusMessage
            )

            VStack(alignment: .leading, spacing: 12) {
                if trainer.showFrenchText || trainer.status == .correct {
                    FeedbackBlock(
                        title: "标准表达",
                        bodyText: trainer.targetText.isEmpty ? "-" : trainer.targetText,
                        tint: SurrealTheme.colors.lilyPad
                    )
                }

                if !trainer.capturedWrongText.isEmpty && trainer.status != .correct {
                    FeedbackBlock(
                        title: "识别到的内容",
                        bodyText: trainer.capturedWrongText,
                        tint: SurrealTheme.colors.danger
                    )
                }

                if trainer.capturedWrongText.isEmpty && !trainer.showFrenchText && trainer.status != .correct {
                    FeedbackBlock(
                        title: "提示",
                        bodyText: "先听数字，再按住录音。系统会把识别到的文本即时显示在这里。",
                        tint: SurrealTheme.colors.waterBlue
                    )
                }
            }
        }
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(SurrealTheme.colors.border)

            HStack(spacing: 10) {
                ChiffreActionButton(title: trainer.showFrenchText ? "隐藏文本" : "显示文本", systemImage: trainer.showFrenchText ? "eye.slash.fill" : "eye.fill", style: .secondary) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        trainer.showFrenchText.toggle()
                    }
                }

                ChiffreActionButton(title: primaryActionTitle, systemImage: primaryActionIcon, style: .primary, fullWidth: true) {
                    if trainer.status == .correct {
                        trainer.generateNew()
                    } else {
                        trainer.toggleRecording()
                    }
                }

                ChiffreActionButton(title: dp.skipLabel, systemImage: "arrow.right", style: .secondary) {
                    trainer.generateNew()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial)
    }

    private var primaryActionTitle: String {
        switch trainer.status {
        case .idle:
            return "开始录音"
        case .listening:
            return "停止录音"
        case .correct:
            return dp.nextText
        case .wrong:
            return "重新录音"
        }
    }

    private var primaryActionIcon: String {
        switch trainer.status {
        case .idle:
            return "mic.fill"
        case .listening:
            return "stop.fill"
        case .correct:
            return "arrow.right"
        case .wrong:
            return "arrow.clockwise"
        }
    }

    private var statusTitle: String {
        switch trainer.status {
        case .idle:
            return "待开始"
        case .listening:
            return "录音中"
        case .correct:
            return "已通过"
        case .wrong:
            return "需重试"
        }
    }

    private var statusHeadline: String {
        switch trainer.status {
        case .idle:
            return "准备好后直接开口"
        case .listening:
            return "系统正在听你说话"
        case .correct:
            return "这次发音通过了"
        case .wrong:
            return "可以立刻再试一次"
        }
    }

    private var statusMessage: String {
        switch trainer.status {
        case .idle:
            return dp.speakIdlePrompt
        case .listening:
            return dp.speakListeningPrompt
        case .correct:
            return dp.speakCorrectPrompt
        case .wrong:
            return dp.speakWrongPrompt
        }
    }

    private var statusTint: Color {
        switch trainer.status {
        case .idle:
            return SurrealTheme.colors.deepIndigo
        case .listening:
            return SurrealTheme.colors.coral
        case .correct:
            return SurrealTheme.colors.lilyPad
        case .wrong:
            return SurrealTheme.colors.danger
        }
    }
}

private struct FeedbackBlock: View {
    let title: String
    let bodyText: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(SurrealTheme.Typography.label(13))
                .foregroundStyle(tint)

            Text(bodyText)
                .font(SurrealTheme.Typography.body(16))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SurrealTheme.colors.surfaceStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
    }
}
