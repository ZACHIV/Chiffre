import SwiftUI

struct ListeningStageView: View {
    let answerState: AnswerState
    let currentDisplay: String
    let annotation: String
    let footnote: String
    let accent: Color
    let textColor: Color
    let metrics: ListeningCanvasTheme.Metrics
    let replay: () -> Void

    var body: some View {
        Button(action: replay) {
            ImpressionistGlassCard(cornerRadius: metrics.stageCornerRadius) {
                stageBrushwork

                VStack(alignment: .leading, spacing: 18) {
                    Spacer(minLength: 0)

                    Group {
                        if answerState == .waiting {
                            ListeningSunriseGlyph(accent: accent)
                        } else {
                            VStack(spacing: 16) {
                                Text(currentDisplay)
                                    .font(stageFont(for: currentDisplay))
                                    .foregroundStyle(textColor)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.42)
                                    .lineLimit(3)

                                Text(annotation)
                                    .font(.system(size: 17, weight: .semibold, design: .serif))
                                    .foregroundStyle(ListeningCanvasTheme.title.opacity(0.82))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 11)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.28))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(ListeningCanvasTheme.dawn.opacity(0.4), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .offset(y: -metrics.stageContentLift)

                    Spacer(minLength: 0)

                    Text(footnote)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.body)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(metrics.stagePadding)
            }
            .frame(height: metrics.stageHeight)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(answerState == .waiting ? "重听当前题目" : "重听当前题目并再次查看答案")
        .accessibilityHint("双击可再次播放当前内容")
    }

    private var stageBrushwork: some View {
        ZStack {
            Circle()
                .trim(from: 0.16, to: 0.68)
                .stroke(ListeningCanvasTheme.water.opacity(0.22), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .frame(width: 200, height: 200)
                .offset(x: -92, y: 44)

            Circle()
                .trim(from: 0.06, to: 0.72)
                .stroke(ListeningCanvasTheme.dawn.opacity(0.18), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .frame(width: 236, height: 236)
                .offset(x: 86, y: 22)
        }
    }

    private func stageFont(for text: String) -> Font {
        if text.count > 14 {
            return SurrealTheme.Typography.number(46)
        }
        if text.count > 8 {
            return SurrealTheme.Typography.number(60)
        }
        return SurrealTheme.Typography.number(78)
    }
}
