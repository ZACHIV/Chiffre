import SwiftUI

struct ListeningStageView: View {
    let mode: GameMode
    let answerState: AnswerState
    let currentDisplay: String
    let footnote: String
    let accent: Color
    let textColor: Color
    let borderColor: Color
    let metrics: ListeningCanvasTheme.Metrics
    let replay: () -> Void

    var body: some View {
        Button(action: replay) {
            ZStack {
                RoundedRectangle(cornerRadius: metrics.stageCornerRadius, style: .continuous)
                    .fill(ListeningCanvasTheme.stageGradient)
                    .background(
                        RoundedRectangle(cornerRadius: metrics.stageCornerRadius, style: .continuous)
                            .fill(ListeningCanvasTheme.canvasFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: metrics.stageCornerRadius, style: .continuous)
                            .stroke(borderColor.opacity(0.72), lineWidth: 1.2)
                    )
                    .shadow(color: borderColor.opacity(0.18), radius: 24, y: 14)

                stageBrushwork

                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        ListeningModeBadge(mode: mode)
                        Spacer()
                        Text("轻点画布可重听")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.secondary)
                    }

                    Spacer(minLength: 0)

                    Group {
                        if answerState == .waiting {
                            ListeningSunriseGlyph(accent: accent)
                        } else {
                            Text(currentDisplay)
                                .font(stageFont(for: currentDisplay))
                                .foregroundStyle(textColor)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.42)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)

                    Text(footnote)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.body)
                }
                .padding(metrics.stagePadding)
            }
            .frame(height: metrics.stageHeight)
        }
        .buttonStyle(.plain)
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
        if text.count > 12 {
            return SurrealTheme.Typography.number(52)
        }
        if text.count > 6 {
            return SurrealTheme.Typography.number(70)
        }
        return SurrealTheme.Typography.number(90)
    }
}

struct ListeningModeBadge: View {
    let mode: GameMode

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: mode.icon)
            Text(mode.rawValue)
                .lineLimit(1)
        }
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .foregroundStyle(ListeningCanvasTheme.title)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.46))
        )
        .overlay(
            Capsule()
                .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
        )
    }
}
