import SwiftUI

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

private struct PlaybackHero: View {
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

private struct PlaybackRibbonControl: View {
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

private struct PlaybackRibbonVisual: View {
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

private struct PlaybackWaveLines: View {
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

private struct SpeedPresetRow: View {
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

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
