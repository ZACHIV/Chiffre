import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var showSettings = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let metrics = ListeningLayoutMetrics(size: proxy.size)

            ZStack {
                VanGoghListeningBackground(answerState: trainer.answerState)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: metrics.sectionSpacing) {
                        header(metrics: metrics)
                        listeningStage(metrics: metrics)
                        lowerPanel(metrics: metrics)
                        Spacer(minLength: metrics.flexSpacer)
                        primaryActionButton
                    }
                    .frame(minHeight: proxy.size.height - metrics.bottomPadding, alignment: .top)
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.top, metrics.topPadding)
                    .padding(.bottom, metrics.bottomPadding)
                }
            }
            .ignoresSafeArea()
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

    private func header(metrics: ListeningLayoutMetrics) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(trainer.dataProvider.appName)
                    .font(.system(size: metrics.brandSize, weight: .bold, design: .serif).italic())
                    .kerning(-1.6)
                    .foregroundStyle(ListeningPalette.cream)
                    .shadow(color: ListeningPalette.ink.opacity(0.35), radius: 16, y: 8)
                    .contentTransition(.opacity)
                    .id(lm.currentLanguage)

                Text(lm.currentLanguage.icon + " " + lm.currentLanguage.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningPalette.cream.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(ListeningPalette.skyGlow.opacity(0.22))
                    )
                    .overlay(
                        Capsule()
                            .stroke(ListeningPalette.cream.opacity(0.18), lineWidth: 1)
                    )
                    .contentTransition(.opacity)
                    .id("lang-\(lm.currentLanguage)")
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 14) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ListeningPalette.cream)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            Circle()
                                .stroke(ListeningPalette.cream.opacity(0.18), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                VStack(alignment: .trailing, spacing: 8) {
                    Text(scoreText)
                        .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(ListeningPalette.cream)

                    Text(streakText)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningPalette.cream.opacity(0.72))

                    speedMeter
                }
            }
        }
    }

    private func listeningStage(metrics: ListeningLayoutMetrics) -> some View {
        Button {
            trainer.replayFull()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: metrics.stageCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: stageSurfaceColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: metrics.stageCornerRadius, style: .continuous)
                            .stroke(stageBorderColor.opacity(0.55), lineWidth: 1.4)
                    )
                    .shadow(color: stageAccentColor.opacity(0.28), radius: 28, y: 16)

                stageBrushOverlay

                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        ModePill(mode: trainer.mode)
                        Spacer()

                        if trainer.answerState == .waiting {
                            Text("轻点重听")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(ListeningPalette.cream.opacity(0.7))
                        }
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 14) {
                        if trainer.answerState == .waiting {
                            Image(systemName: "ear.and.waveform")
                                .font(.system(size: metrics.iconSize, weight: .light))
                                .foregroundStyle(stageAccentColor)

                            WavePulseRow(accent: stageAccentColor)
                        } else {
                            Text(trainer.currentDisplay)
                                .font(stageFont(for: trainer.currentDisplay, metrics: metrics))
                                .foregroundStyle(stageTextColor)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.42)
                                .lineLimit(2)
                                .padding(.horizontal, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)

                    Text(stageFootnote)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningPalette.cream.opacity(0.78))
                }
                .padding(metrics.stagePadding)
            }
            .frame(height: metrics.stageHeight)
        }
        .buttonStyle(.plain)
    }

    private func lowerPanel(metrics: ListeningLayoutMetrics) -> some View {
        VStack(spacing: 14) {
            if trainer.answerState == .waiting {
                TextField(trainer.dataProvider.inputPlaceholder, text: $trainer.userInput)
                    .focused($isInputFocused)
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningPalette.cream)
                    .multilineTextAlignment(.center)
                    .keyboardType(trainer.preferredKeyboardType)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(ListeningPalette.cream.opacity(0.18), lineWidth: 1)
                    )
                    .onSubmit {
                        trainer.verify()
                    }

                if trainer.hasHintContent {
                    hintPanel
                }

                supportToolbar
            } else {
                feedbackPanel
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: metrics.panelCornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: metrics.panelCornerRadius, style: .continuous)
                .stroke(ListeningPalette.cream.opacity(0.14), lineWidth: 1)
        )
    }

    private var hintPanel: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(trainer.hintMessage)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningPalette.cream.opacity(0.86))

            if !trainer.hintVisual.isEmpty {
                Text(trainer.hintVisual)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(ListeningPalette.sunflower)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ListeningPalette.ink.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ListeningPalette.sunflower.opacity(0.18), lineWidth: 1)
        )
    }

    private var supportToolbar: some View {
        HStack(spacing: 10) {
            ToolCapsuleButton(title: "重听", icon: "speaker.wave.2.fill", tint: ListeningPalette.sunflower) {
                trainer.replayFull()
            }

            ToolCapsuleButton(title: "聚焦", icon: "waveform", tint: ListeningPalette.cypress) {
                trainer.replayFocused()
            }

            ToolCapsuleButton(title: compactHintTitle, icon: "sparkles", tint: ListeningPalette.skyGlow) {
                trainer.requestHint()
            }

            Menu {
                Button("慢速听") {
                    trainer.replaySlow()
                }

                Button("设置") {
                    showSettings = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))

                    Circle()
                        .stroke(ListeningPalette.cream.opacity(0.16), lineWidth: 1)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ListeningPalette.cream)
                }
                .frame(width: 42, height: 42)
            }
        }
    }

    private var feedbackPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: feedbackIconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(stageAccentColor)

                Text(feedbackTitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningPalette.cream)

                Spacer()
            }

            if trainer.answerState == .wrong, !trainer.userInput.isEmpty {
                Text("你的输入: \(trainer.userInput)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningPalette.cream.opacity(0.68))
            }

            sentenceHighlightView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
    }

    private var sentenceHighlightView: some View {
        highlightedSentenceText()
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .multilineTextAlignment(.leading)
            .lineSpacing(3)
    }

    private var primaryActionButton: some View {
        Button {
            if trainer.answerState == .waiting {
                trainer.verify()
            } else {
                trainer.generateNew()
            }
        } label: {
            HStack(spacing: 12) {
                Text(mainButtonTitle)
                    .font(.system(size: 22, weight: .bold, design: .serif))

                Spacer()

                Image(systemName: trainer.answerState == .waiting ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(ListeningPalette.ink)
            .padding(.horizontal, 24)
            .frame(height: 64)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: mainButtonColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: mainButtonColors.first?.opacity(0.45) ?? Color.clear, radius: 20, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var speedMeter: some View {
        HStack(spacing: 5) {
            ForEach(1...4, id: \.self) { level in
                Circle()
                    .fill(level <= trainer.speedLevel ? ListeningPalette.sunflower : ListeningPalette.cream.opacity(0.18))
                    .frame(width: 6, height: 6)
            }

            Text(trainer.speedLabel)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningPalette.cream.opacity(0.72))
        }
    }

    private var stageBrushOverlay: some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.66)
                .stroke(ListeningPalette.sunflower.opacity(0.18), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 210, height: 210)
                .offset(x: 74, y: -60)
                .rotationEffect(.degrees(18))

            Circle()
                .trim(from: 0.22, to: 0.82)
                .stroke(ListeningPalette.skyGlow.opacity(0.22), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .frame(width: 250, height: 250)
                .offset(x: -82, y: 62)
                .rotationEffect(.degrees(-26))
        }
    }

    private var stageSurfaceColors: [Color] {
        [
            ListeningPalette.ink.opacity(0.48),
            ListeningPalette.navy.opacity(0.72),
            ListeningPalette.indigo.opacity(0.86)
        ]
    }

    private var stageBorderColor: Color {
        switch trainer.answerState {
        case .waiting: return ListeningPalette.cream
        case .revealed: return ListeningPalette.skyGlow
        case .correct: return ListeningPalette.cypress
        case .wrong: return ListeningPalette.sunflower
        }
    }

    private var stageAccentColor: Color {
        switch trainer.answerState {
        case .waiting: return ListeningPalette.sunflower
        case .revealed: return ListeningPalette.skyGlow
        case .correct: return ListeningPalette.cypress
        case .wrong: return ListeningPalette.sunflower
        }
    }

    private var stageTextColor: Color {
        switch trainer.answerState {
        case .waiting: return ListeningPalette.sunflower
        case .revealed: return ListeningPalette.cream
        case .correct: return ListeningPalette.cypress
        case .wrong: return ListeningPalette.cream
        }
    }

    private var stageFootnote: String {
        switch trainer.answerState {
        case .waiting: return "完整语境播放，点击画布可再听一遍"
        case .revealed: return "答案已展开，准备进入下一题"
        case .correct: return trainer.dataProvider.successText
        case .wrong: return trainer.dataProvider.gentleWrongText
        }
    }

    private var mainButtonTitle: String {
        trainer.answerState == .waiting ? trainer.dataProvider.revealText : trainer.dataProvider.nextText
    }

    private var mainButtonColors: [Color] {
        switch trainer.answerState {
        case .waiting:
            return [ListeningPalette.sunflower, ListeningPalette.wheat]
        case .revealed:
            return [ListeningPalette.skyGlow, ListeningPalette.cream]
        case .correct:
            return [ListeningPalette.cypress, ListeningPalette.mint]
        case .wrong:
            return [ListeningPalette.sunflower, ListeningPalette.ember]
        }
    }

    private var feedbackIconName: String {
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

    private var streakText: String {
        trainer.currentStreak == 0 ? "慢慢来，先把节奏找回来" : "连对 \(trainer.currentStreak) 题"
    }

    private func stageFont(for text: String, metrics: ListeningLayoutMetrics) -> Font {
        if text.count > 12 {
            return .system(size: metrics.largeAnswerSize * 0.54, weight: .bold, design: .serif)
        }
        if text.count > 6 {
            return .system(size: metrics.largeAnswerSize * 0.72, weight: .bold, design: .serif)
        }
        return .system(size: metrics.largeAnswerSize, weight: .bold, design: .serif)
    }

    private func highlightedSentenceText() -> Text {
        let sentence = trainer.sentenceContext
        let highlight = trainer.speakableContent
        let baseColor = ListeningPalette.cream.opacity(0.74)

        guard !highlight.isEmpty,
              let range = sentence.range(of: highlight, options: .caseInsensitive) else {
            return Text(sentence).foregroundColor(baseColor)
        }

        let before = String(sentence[..<range.lowerBound])
        let emphasized = String(sentence[range])
        let after = String(sentence[range.upperBound...])

        return Text(before).foregroundColor(baseColor)
            + Text(emphasized).foregroundColor(ListeningPalette.sunflower).bold()
            + Text(after).foregroundColor(baseColor)
    }
}

private struct ListeningLayoutMetrics {
    let size: CGSize

    var horizontalPadding: CGFloat {
        size.width > 430 ? 30 : 22
    }

    var topPadding: CGFloat {
        size.height < 760 ? 20 : 28
    }

    var bottomPadding: CGFloat {
        size.height < 760 ? 14 : 22
    }

    var sectionSpacing: CGFloat {
        size.height < 760 ? 18 : 24
    }

    var flexSpacer: CGFloat {
        size.height < 760 ? 8 : 18
    }

    var brandSize: CGFloat {
        size.width > 430 ? 56 : 48
    }

    var stageHeight: CGFloat {
        min(max(size.height * 0.32, 250), 340)
    }

    var stagePadding: CGFloat {
        size.height < 760 ? 22 : 26
    }

    var stageCornerRadius: CGFloat {
        size.height < 760 ? 34 : 40
    }

    var panelCornerRadius: CGFloat {
        28
    }

    var iconSize: CGFloat {
        size.height < 760 ? 72 : 84
    }

    var largeAnswerSize: CGFloat {
        size.height < 760 ? 74 : 92
    }
}

private enum ListeningPalette {
    static let navy = Color(red: 0.06, green: 0.11, blue: 0.28)
    static let indigo = Color(red: 0.11, green: 0.19, blue: 0.43)
    static let ink = Color(red: 0.04, green: 0.08, blue: 0.18)
    static let skyGlow = Color(red: 0.44, green: 0.66, blue: 0.97)
    static let sunflower = Color(red: 0.96, green: 0.76, blue: 0.25)
    static let wheat = Color(red: 0.98, green: 0.83, blue: 0.45)
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.86)
    static let cypress = Color(red: 0.39, green: 0.67, blue: 0.51)
    static let mint = Color(red: 0.66, green: 0.84, blue: 0.68)
    static let ember = Color(red: 0.86, green: 0.52, blue: 0.24)
}

private struct ModePill: View {
    let mode: GameMode

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: mode.icon)
                .font(.system(size: 12, weight: .bold))
            Text(mode.rawValue)
                .lineLimit(1)
        }
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .foregroundStyle(ListeningPalette.cream)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(ListeningPalette.cream.opacity(0.16), lineWidth: 1)
        )
    }
}

private struct ToolCapsuleButton: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(ListeningPalette.cream)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(tint.opacity(0.22))
            )
            .overlay(
                Capsule()
                    .stroke(tint.opacity(0.42), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct WavePulseRow: View {
    let accent: Color
    @State private var animate = false

    private let heights: [CGFloat] = [16, 24, 34, 22, 14]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(heights.enumerated()), id: \.offset) { index, height in
                Capsule()
                    .fill(accent.opacity(index == 2 ? 1 : 0.82))
                    .frame(width: 8, height: animate ? height : max(12, height * 0.62))
                    .animation(
                        .easeInOut(duration: 0.85)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.08),
                        value: animate
                    )
            }
        }
        .frame(height: 36)
        .onAppear {
            animate = true
        }
    }
}

private struct VanGoghListeningBackground: View {
    let answerState: AnswerState
    @State private var drift = false
    @State private var twinkle = false

    private let stars: [CGPoint] = [
        CGPoint(x: 0.12, y: 0.11),
        CGPoint(x: 0.34, y: 0.18),
        CGPoint(x: 0.62, y: 0.09),
        CGPoint(x: 0.82, y: 0.16),
        CGPoint(x: 0.18, y: 0.36),
        CGPoint(x: 0.76, y: 0.33),
        CGPoint(x: 0.58, y: 0.52),
        CGPoint(x: 0.14, y: 0.61),
        CGPoint(x: 0.87, y: 0.58),
        CGPoint(x: 0.28, y: 0.77),
        CGPoint(x: 0.66, y: 0.83),
        CGPoint(x: 0.91, y: 0.74)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        ListeningPalette.navy,
                        ListeningPalette.indigo,
                        ListeningPalette.ink
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(ListeningPalette.skyGlow.opacity(answerState == .waiting ? 0.22 : 0.14))
                    .frame(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7)
                    .blur(radius: 90)
                    .offset(x: drift ? -120 : -50, y: drift ? -180 : -110)

                Circle()
                    .fill(ListeningPalette.sunflower.opacity(answerState == .wrong ? 0.22 : 0.16))
                    .frame(width: proxy.size.width * 0.56, height: proxy.size.width * 0.56)
                    .blur(radius: 90)
                    .offset(x: drift ? 110 : 70, y: drift ? 180 : 120)

                Circle()
                    .fill(ListeningPalette.cypress.opacity(answerState == .correct ? 0.22 : 0.1))
                    .frame(width: proxy.size.width * 0.48, height: proxy.size.width * 0.48)
                    .blur(radius: 82)
                    .offset(x: drift ? 40 : 100, y: drift ? 30 : -40)

                ZStack {
                    Circle()
                        .trim(from: 0.08, to: 0.7)
                        .stroke(ListeningPalette.sunflower.opacity(0.18), style: StrokeStyle(lineWidth: 28, lineCap: .round))
                        .frame(width: proxy.size.width * 1.05, height: proxy.size.width * 1.05)
                        .offset(x: proxy.size.width * 0.32, y: -proxy.size.height * 0.08)
                        .rotationEffect(.degrees(drift ? 14 : -4))

                    Circle()
                        .trim(from: 0.2, to: 0.88)
                        .stroke(ListeningPalette.skyGlow.opacity(0.14), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                        .frame(width: proxy.size.width * 0.92, height: proxy.size.width * 0.92)
                        .offset(x: -proxy.size.width * 0.22, y: proxy.size.height * 0.16)
                        .rotationEffect(.degrees(drift ? -26 : -8))
                }
                .blur(radius: 1.2)

                ForEach(Array(stars.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(ListeningPalette.cream.opacity(index.isMultiple(of: 3) ? 0.92 : 0.58))
                        .frame(width: index.isMultiple(of: 4) ? 6 : 4, height: index.isMultiple(of: 4) ? 6 : 4)
                        .blur(radius: index.isMultiple(of: 4) ? 0.5 : 0)
                        .position(x: proxy.size.width * point.x, y: proxy.size.height * point.y)
                        .scaleEffect(twinkle ? 1.18 : 0.86)
                        .animation(
                            .easeInOut(duration: 1.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.11),
                            value: twinkle
                        )
                }

                VStack {
                    Spacer()

                    HStack {
                        Circle()
                            .fill(ListeningPalette.ink.opacity(0.48))
                            .frame(width: 240, height: 120)
                            .blur(radius: 42)
                            .offset(x: -40, y: 60)

                        Spacer()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    drift.toggle()
                }

                withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) {
                    twinkle.toggle()
                }
            }
        }
    }
}
