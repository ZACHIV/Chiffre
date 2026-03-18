import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var showSettings = false
    @State private var borderRotation: Double = 0
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            VStack(spacing: 0) {
                // 1. 标题 + 语言徽标
                VStack(spacing: 6) {
                    Text(trainer.dataProvider.appName)
                        .font(SurrealTheme.Typography.title(48))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                        .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                        .contentTransition(.opacity)
                        .id(lm.currentLanguage)  // 语言切换时触发过渡动画

                    Text(lm.currentLanguage.icon + " " + lm.currentLanguage.displayName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(SurrealTheme.colors.deepIndigo.opacity(0.06))
                        .clipShape(Capsule())
                        .contentTransition(.opacity)
                        .id("lang-\(lm.currentLanguage)")
                }
                .padding(.top, 60)

                // 2. HUD：分数 / 连对火焰 / 语速
                hudView
                    .padding(.top, 14)
                    .padding(.horizontal, 28)

                Spacer()

                // 3. 核心卡片
                cardView

                // 4. 输入区 / 反馈区
                inputFeedbackView
                    .padding(.top, 20)
                    .frame(minHeight: 72, alignment: .top)

                Spacer()

                // 5. 底部操作栏
                HStack(spacing: 30) {
                    CircleButton(icon: "speaker.wave.2.fill") {
                        trainer.replay()
                    }

                    mainButton

                    CircleButton(icon: "slider.horizontal.3") {
                        showSettings = true
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
        .onChange(of: trainer.answerState) { _, state in
            isInputFocused = (state == .waiting)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.height(520)])
                .presentationCornerRadius(30)
        }
    }

    // MARK: - HUD

    var hudView: some View {
        HStack(spacing: 0) {
            // 分数
            VStack(alignment: .leading, spacing: 2) {
                Text("Score")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.45))
                Text(trainer.sessionTotal == 0 ? "--" : "\(trainer.sessionCorrect)/\(trainer.sessionTotal)")
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
            }

            Spacer()

            // 连对火焰（只在连对 > 0 时显示）
            if trainer.currentStreak > 0 {
                HStack(spacing: 3) {
                    Text("🔥")
                        .font(.system(size: 15))
                    Text("\(trainer.currentStreak)")
                        .font(.system(size: 16, weight: .bold).monospacedDigit())
                        .foregroundStyle(SurrealTheme.colors.coral)
                }
            }

            Spacer()

            // 语速指示器
            VStack(alignment: .trailing, spacing: 2) {
                Text("速度")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.45))
                HStack(spacing: 3) {
                    ForEach(1...4, id: \.self) { i in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundStyle(
                                i <= trainer.speedLevel
                                    ? SurrealTheme.colors.deepIndigo
                                    : SurrealTheme.colors.deepIndigo.opacity(0.18)
                            )
                    }
                    Text(trainer.speedLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.65))
                }
            }
        }
    }

    // MARK: - 卡片

    var cardView: some View {
        ZStack {
            // 底座
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white.opacity(0.25))
                )
                .frame(width: 300, height: 300)
                .shadow(color: cardShadowColor.opacity(0.15), radius: 30, y: 15)
                .shadow(color: Color.white.opacity(0.5), radius: 12, x: -5, y: -5)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(
                            AngularGradient(
                                colors: cardBorderColors,
                                center: .center,
                                angle: .degrees(borderRotation)
                            ),
                            lineWidth: 2
                        )
                )

            // 内容
            Group {
                switch trainer.answerState {
                case .waiting:
                    Image(systemName: "ear.and.waveform")
                        .font(.system(size: 80))
                        .foregroundStyle(SurrealTheme.colors.coral)
                        .shadow(color: SurrealTheme.colors.coral.opacity(0.3), radius: 10, y: 5)
                        .transition(.scale.combined(with: .opacity))

                case .revealed:
                    Text(trainer.currentDisplay)
                        .font(getFont(for: trainer.currentDisplay))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 30)
                        .transition(.scale.combined(with: .opacity))

                case .correct:
                    Text(trainer.currentDisplay)
                        .font(getFont(for: trainer.currentDisplay))
                        .foregroundStyle(SurrealTheme.colors.lilyPad)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 30)
                        .transition(.scale.combined(with: .opacity))

                case .wrong:
                    Text(trainer.currentDisplay)
                        .font(getFont(for: trainer.currentDisplay))
                        .foregroundStyle(Color.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 30)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onTapGesture {
            if trainer.answerState == .waiting { trainer.replay() }
        }
    }

    // MARK: - 输入 / 反馈

    @ViewBuilder
    var inputFeedbackView: some View {
        switch trainer.answerState {
        case .waiting:
            TextField(trainer.dataProvider.inputPlaceholder, text: $trainer.userInput)
                .focused($isInputFocused)
                .font(SurrealTheme.Typography.body(18))
                .multilineTextAlignment(.center)
                .keyboardType(trainer.preferredKeyboardType)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                        .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.07), radius: 8, y: 4)
                )
                .padding(.horizontal, 36)
                .onSubmit { trainer.verify() }
                .transition(.opacity)

        case .revealed:
            // 直接揭晓：只显示句子，无评分反馈
            sentenceHighlightView
                .transition(.opacity)

        case .correct:
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(SurrealTheme.colors.lilyPad)
                    Text(trainer.dataProvider.successText)
                        .font(SurrealTheme.Typography.body(15))
                        .foregroundStyle(SurrealTheme.colors.lilyPad)
                }
                sentenceHighlightView
            }
            .transition(.scale.combined(with: .opacity))

        case .wrong:
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.red.opacity(0.8))
                    Text("\(trainer.dataProvider.wrongAnswerPrefix) \"\(trainer.userInput)\"")
                        .font(SurrealTheme.Typography.body(14))
                        .foregroundStyle(Color.red.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                sentenceHighlightView
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    // 带高亮的完整句子（数字用珊瑚色标注）
    var sentenceHighlightView: some View {
        highlightedSentenceText()
            .font(.system(size: 13, weight: .regular))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .lineSpacing(2)
    }

    // 在句子中将 speakableContent 高亮为珊瑚色
    func highlightedSentenceText() -> Text {
        let sentence  = trainer.sentenceContext
        let highlight = trainer.speakableContent
        let baseColor = SurrealTheme.colors.deepIndigo.opacity(0.38)

        guard !highlight.isEmpty,
              let range = sentence.range(of: highlight, options: .caseInsensitive) else {
            return Text(sentence).foregroundColor(baseColor)
        }

        let before      = String(sentence[..<range.lowerBound])
        let highlighted = String(sentence[range])
        let after       = String(sentence[range.upperBound...])

        return Text(before).foregroundColor(baseColor)
            + Text(highlighted).foregroundColor(SurrealTheme.colors.coral).bold()
            + Text(after).foregroundColor(baseColor)
    }

    // MARK: - 主按钮（始终可点击）
    var mainButton: some View {
        Button {
            if trainer.answerState != .waiting {
                trainer.generateNew()
            } else {
                trainer.verify()
            }
        } label: {
            Text(trainer.answerState != .waiting
                 ? trainer.dataProvider.nextText
                 : trainer.dataProvider.revealText)
                .font(SurrealTheme.Typography.header(20))
                .foregroundStyle(.white)
                .frame(width: 150, height: 64)
                .background(mainButtonColor)
                .clipShape(Capsule())
                .shadow(color: mainButtonColor.opacity(0.5), radius: 15, y: 8)
        }
    }

    // MARK: - 样式计算

    var mainButtonColor: Color {
        switch trainer.answerState {
        case .waiting:   return SurrealTheme.colors.coral
        case .revealed:  return SurrealTheme.colors.deepIndigo
        case .correct:   return SurrealTheme.colors.lilyPad
        case .wrong:     return SurrealTheme.colors.deepIndigo
        }
    }

    var cardShadowColor: Color {
        switch trainer.answerState {
        case .waiting, .revealed: return SurrealTheme.colors.deepIndigo
        case .correct:            return SurrealTheme.colors.lilyPad
        case .wrong:              return .red
        }
    }

    var cardBorderColors: [Color] {
        let neutral = [SurrealTheme.colors.waterBlue, SurrealTheme.colors.lavenderMist,
                       SurrealTheme.colors.lilyPad, SurrealTheme.colors.skyDawn, SurrealTheme.colors.waterBlue]
        switch trainer.answerState {
        case .waiting, .revealed: return neutral
        case .correct:
            return [SurrealTheme.colors.lilyPad, SurrealTheme.colors.lilyPad.opacity(0.4),
                    SurrealTheme.colors.lilyPad, SurrealTheme.colors.lilyPad.opacity(0.4), SurrealTheme.colors.lilyPad]
        case .wrong:
            return [Color.red, Color.red.opacity(0.4), Color.red, Color.red.opacity(0.4), Color.red]
        }
    }

    func getFont(for text: String) -> Font {
        if text.count > 10 { return SurrealTheme.Typography.number(42) }
        if text.count > 5  { return SurrealTheme.Typography.number(64) }
        return SurrealTheme.Typography.number(96)
    }
}

// MARK: - 圆形图标按钮
struct CircleButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.4))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
    }
}
