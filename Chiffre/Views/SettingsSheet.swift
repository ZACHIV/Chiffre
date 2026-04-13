import SwiftUI

struct SettingsView: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @AppStorage("listeningAmbientMotionEnabled") private var ambientMotionEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsHeroCard(
                        languageName: lm.currentLanguage.displayName,
                        modeName: trainer.mode.rawValue,
                        modeSummary: trainer.mode.summary
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                Section {
                    SettingsSummaryRow(
                        title: "语言",
                        value: lm.currentLanguage.displayName,
                        detail: "在 Écouter 页左上角直接切换"
                    )

                    SettingsSummaryRow(
                        title: "类别",
                        value: trainer.mode.rawValue,
                        detail: trainer.mode.summary
                    )

                    if trainer.mode.isRangeConfigurable {
                        NavigationLink {
                            RangeSettingsView(trainer: trainer)
                        } label: {
                            SettingsNavigationRow(
                                title: "数字范围",
                                value: "0 - \(trainer.maxRange)"
                            )
                        }
                    }
                } header: {
                    Text("Practice")
                } footer: {
                    Text("语言和类别保持在首页直改，设置页只保留需要沉下来的训练参数。")
                }

                Section {
                    NavigationLink {
                        PlaybackSettingsView(trainer: trainer)
                    } label: {
                        SettingsNavigationRow(
                            title: "播放速度",
                            value: "\(trainer.speedLabel) · \(String(format: "%.2f", trainer.playbackRate))"
                        )
                    }

                    NavigationLink {
                        VoiceSettingsView()
                    } label: {
                        SettingsNavigationRow(
                            title: "语音",
                            value: currentVoiceName
                        )
                    }
                } header: {
                    Text("Audio")
                }

                Section {
                    NavigationLink {
                        InterfaceSettingsView(ambientMotionEnabled: $ambientMotionEnabled)
                    } label: {
                        SettingsNavigationRow(
                            title: "画面与动效",
                            value: ambientMotionEnabled ? "动态背景开启" : "动态背景关闭"
                        )
                    }
                } header: {
                    Text("Interface")
                } footer: {
                    Text("保持更轻的视觉层次，把复杂设置放到二级页面里。")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ListeningCanvasTheme.background)
            .navigationTitle("Réglages")
        }
    }

    private var currentVoiceName: String {
        switch lm.currentLanguage {
        case .french:
            lm.selectedFrenchVoice.displayName
        case .spanish:
            lm.selectedSpanishVoice.displayName
        }
    }
}

struct SettingsHeroCard: View {
    let languageName: String
    let modeName: String
    let modeSummary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Écoute du quotidien")
                .font(SurrealTheme.Typography.header(28))
                .foregroundStyle(ListeningCanvasTheme.title)

            Text("把语言、场景和语速压在同一套安静的节奏里，让训练更像真实生活。")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)

            Rectangle()
                .fill(ListeningCanvasTheme.canvasStroke.opacity(0.6))
                .frame(height: 1)

            SettingsHeroLine(title: "Langue", value: languageName)
            SettingsHeroLine(title: "Focus", value: modeName)

            Text(modeSummary)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.water)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

struct SettingsHeroLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .textCase(.uppercase)
                .tracking(1)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.title)
                .lineLimit(1)
        }
    }
}

struct SettingsSummaryRow: View {
    let title: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .multilineTextAlignment(.trailing)
            }

            Text(detail)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(ListeningCanvasTheme.title)

            Spacer(minLength: 16)

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

struct RangeSettingsView: View {
    @ObservedObject var trainer: NumberTrainer

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("当前范围")
                            .foregroundStyle(ListeningCanvasTheme.secondary)
                        Spacer()
                        Text("0 - \(trainer.maxRange)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.title)
                            .monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(trainer.maxRange) },
                            set: { trainer.maxRange = Int($0) }
                        ),
                        in: 10...9999,
                        step: 10
                    )
                    .tint(ListeningCanvasTheme.water)
                }
                .padding(.vertical, 6)
            } footer: {
                Text("仅在数字模式下生效，方便控制训练难度。")
            }

            Section("快捷范围") {
                PresetButton(label: "简单", value: 10, trainer: trainer)
                PresetButton(label: "中等", value: 100, trainer: trainer)
                PresetButton(label: "困难", value: 1000, trainer: trainer)
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("数字范围")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlaybackSettingsView: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 18) {
                    PlaybackHero(trainer: trainer)

                    PlaybackRibbonControl(playbackRate: $trainer.playbackRate)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("播放速度")
                        .accessibilityValue("\(trainer.speedLabel)，\(String(format: "%.2f", trainer.playbackRate))")
                        .accessibilityHint("左右滑动调整语速")
                        .accessibilityRepresentation {
                            Slider(
                                value: $trainer.playbackRate,
                                in: 0.38...0.68,
                                step: 0.01
                            ) {
                                Text("播放速度")
                            } minimumValueLabel: {
                                Text("慢")
                            } maximumValueLabel: {
                                Text("快")
                            }
                        }
                }
                .padding(.vertical, 10)
            } footer: {
                Text("拖动光点时，波纹会跟着语速变化；目标是接近自然语流，而不是越快越好。")
            }

            Section("预设") {
                SpeedPresetRow(title: "慢一点", subtitle: "更清晰", value: 0.44, trainer: trainer)
                SpeedPresetRow(title: "推荐", subtitle: "平衡训练", value: 0.56, trainer: trainer)
                SpeedPresetRow(title: "自然", subtitle: "接近日常", value: 0.64, trainer: trainer)
            }

            Section {
                Button {
                    SpeechManager.shared.speak(lm.getTestPhrase(), rate: trainer.currentRate)
                } label: {
                    Label("试听当前语速", systemImage: "speaker.wave.2.fill")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("播放速度")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlaybackHero: View {
    @ObservedObject var trainer: NumberTrainer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vitesse")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.2)

            HStack(alignment: .firstTextBaseline) {
                Text(trainer.speedLabel)
                    .font(SurrealTheme.Typography.header(28))
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                Text(String(format: "%.2f", trainer.playbackRate))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.water)
                    .monospacedDigit()
            }

            Text("让耳朵先适应节奏，再一点点提速。")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
        }
    }
}

struct PlaybackRibbonControl: View {
    @Binding var playbackRate: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lowerBound = 0.38
    private let upperBound = 0.68

    private var progress: Double {
        ((playbackRate - lowerBound) / (upperBound - lowerBound)).clamped(to: 0...1)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let markerX = CGFloat(progress) * width

            TimelineView(.animation(minimumInterval: reduceMotion ? 0.55 : 0.035)) { context in
                let phase = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate * (0.9 + progress * 1.4)
                PlaybackRibbonVisual(
                    progress: progress,
                    markerX: markerX,
                    width: width,
                    phase: phase
                )
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let nextProgress = min(max(value.location.x / width, 0), 1)
                        playbackRate = lowerBound + ((upperBound - lowerBound) * nextProgress)
                    }
            )
        }
        .frame(height: 96)
    }
}

struct PlaybackRibbonVisual: View {
    let progress: Double
    let markerX: CGFloat
    let width: CGFloat
    let phase: Double

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.42))

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.7), lineWidth: 1)

            PlaybackWaveLines(progress: progress, markerX: markerX, phase: phase)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            ListeningCanvasTheme.water.opacity(0.88),
                            ListeningCanvasTheme.title.opacity(0.76)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(markerX, 34), height: 4)
                .offset(x: 18)

            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(ListeningCanvasTheme.canvasStroke, lineWidth: 1)
                )
                .shadow(color: ListeningCanvasTheme.title.opacity(0.14), radius: 14, y: 8)
                .overlay {
                    Circle()
                        .fill(ListeningCanvasTheme.water.opacity(0.2))
                        .padding(7)
                }
                .offset(x: min(max(markerX - 16, 0), width - 32))
        }
    }
}

struct PlaybackWaveLines: View {
    let progress: Double
    let markerX: CGFloat
    let phase: Double

    var body: some View {
        Canvas { graphicsContext, size in
            let centerY = size.height / 2
            let activeX = max(markerX, 44)
            let gradient = Gradient(colors: [
                ListeningCanvasTheme.mist.opacity(0.5),
                ListeningCanvasTheme.water.opacity(0.95),
                ListeningCanvasTheme.title.opacity(0.78)
            ])

            for index in 0..<3 {
                let amplitude = (8.0 - Double(index) * 2.0) + (progress * 6)
                let verticalOffset = CGFloat(index - 1) * 11
                let path = ribbonPath(
                    in: size,
                    centerY: centerY,
                    activeX: activeX,
                    verticalOffset: verticalOffset,
                    amplitude: amplitude,
                    phase: phase,
                    index: index
                )

                graphicsContext.stroke(
                    path,
                    with: .linearGradient(
                        gradient,
                        startPoint: CGPoint(x: 0, y: centerY),
                        endPoint: CGPoint(x: size.width, y: centerY)
                    ),
                    style: StrokeStyle(lineWidth: index == 1 ? 3.2 : 1.8, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func ribbonPath(
        in size: CGSize,
        centerY: CGFloat,
        activeX: CGFloat,
        verticalOffset: CGFloat,
        amplitude: Double,
        phase: Double,
        index: Int
    ) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: centerY + verticalOffset))

        for x in stride(from: 0.0, through: Double(size.width), by: 2.0) {
            let relativeX = x / Double(size.width)
            let wave = sin((relativeX * .pi * (2.2 + Double(index) * 0.34)) + phase + Double(index) * 0.75)
            let taper = min(max(x / Double(activeX), 0.18), 1.0)
            let y = centerY + verticalOffset + CGFloat(wave * amplitude * taper)
            path.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }

        return path
    }
}

struct SpeedPresetRow: View {
    let title: String
    let subtitle: String
    let value: Double
    @ObservedObject var trainer: NumberTrainer

    private var isSelected: Bool {
        abs(trainer.playbackRate - value) < 0.011
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                trainer.playbackRate = value
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundStyle(ListeningCanvasTheme.title)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ListeningCanvasTheme.water)
                } else {
                    Text(String(format: "%.2f", value))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                        .monospacedDigit()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct VoiceSettingsView: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        Form {
            Section {
                Button {
                    SpeechManager.shared.speak(lm.getTestPhrase())
                } label: {
                    Label("试听当前语音", systemImage: "speaker.wave.2.fill")
                }
            }

            if lm.currentLanguage == .french {
                Section("French Voices") {
                    ForEach(FrenchVoice.allCases) { voice in
                        VoiceRow(
                            title: voice.displayName,
                            icon: voice.icon,
                            isSelected: lm.selectedFrenchVoice == voice
                        ) {
                            lm.selectedFrenchVoice = voice
                            SpeechManager.shared.speak("Bonjour, je m'appelle \(voice.rawValue)")
                        }
                    }
                }
            } else {
                Section("Spanish Voices") {
                    ForEach(SpanishVoice.allCases) { voice in
                        VoiceRow(
                            title: voice.displayName,
                            icon: voice.icon,
                            isSelected: lm.selectedSpanishVoice == voice
                        ) {
                            lm.selectedSpanishVoice = voice
                            SpeechManager.shared.speak("Hola, me llamo \(voice.rawValue)")
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("语音")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VoiceRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .accessibilityHidden(true)

                Text(title)
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ListeningCanvasTheme.water)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct InterfaceSettingsView: View {
    @Binding var ambientMotionEnabled: Bool

    var body: some View {
        Form {
            Section {
                Toggle("动态背景", isOn: $ambientMotionEnabled)
            } footer: {
                Text("关闭后会保留静态光感和留白，但不再让背景和光点持续漂移。")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("画面与动效")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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
            HStack {
                Text(label)
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ListeningCanvasTheme.water)
                } else {
                    Text("\(value)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                        .monospacedDigit()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
