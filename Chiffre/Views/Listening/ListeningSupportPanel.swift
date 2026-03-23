import SwiftUI

struct ListeningSupportPanel: View {
    let hasHintContent: Bool
    let hintMessage: String
    let hintVisual: String
    let answerState: AnswerState
    let feedbackIcon: String
    let feedbackTitle: String
    let feedbackColor: Color
    let sentenceView: Text
    let hintTitle: String
    let replay: () -> Void
    let replayFocused: () -> Void
    let requestHint: () -> Void

    var body: some View {
        ImpressionistGlassCard(cornerRadius: 26) {
            VStack(spacing: 14) {
                if answerState == .waiting {
                    if hasHintContent {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(hintMessage)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(ListeningCanvasTheme.body)

                            if !hintVisual.isEmpty {
                                Text(hintVisual)
                                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(ListeningCanvasTheme.sunrise)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.2))
                        )
                    }

                    HStack(spacing: 10) {
                        SupportActionPill(title: "重听", icon: "speaker.wave.2.fill", tint: ListeningCanvasTheme.dawn, action: replay)
                        SupportActionPill(title: "聚焦", icon: "waveform", tint: ListeningCanvasTheme.leaf, action: replayFocused)
                        SupportActionPill(title: hintTitle, icon: "sparkles", tint: ListeningCanvasTheme.water, action: requestHint)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        sentenceView
                            .font(.system(size: 21, weight: .medium, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.body)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(5)
                            .minimumScaleFactor(0.78)

                        HStack(spacing: 8) {
                            Image(systemName: feedbackIcon)
                                .foregroundStyle(feedbackColor)
                            Text(feedbackTitle)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(ListeningCanvasTheme.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
    }
}

struct SupportActionPill: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(ListeningCanvasTheme.title)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.46),
                                tint.opacity(0.22),
                                ListeningCanvasTheme.mist.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(tint.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ListeningBottomActionRow: View {
    let primaryTitle: String
    let primaryIcon: String
    let primaryGradient: LinearGradient
    let primaryAction: () -> Void
    let settingsAction: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: settingsAction) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                    Circle()
                        .fill(Color.white.opacity(0.18))
                    Circle()
                        .stroke(ListeningCanvasTheme.panelStroke, lineWidth: 1)
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ListeningCanvasTheme.title)
                }
                .frame(width: 58, height: 58)
            }
            .buttonStyle(.plain)

            Button(action: primaryAction) {
                HStack(spacing: 12) {
                    Text(primaryTitle)
                        .font(SurrealTheme.Typography.header(20))
                    Spacer()
                    Image(systemName: primaryIcon)
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 22)
                .frame(height: 58)
                .background(primaryGradient)
                .clipShape(Capsule())
                .shadow(color: ListeningCanvasTheme.sunrise.opacity(0.32), radius: 18, y: 10)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
