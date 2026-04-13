import SwiftUI

struct ListeningSupportPanel: View {
    let feedbackIcon: String
    let feedbackTitle: String
    let feedbackColor: Color
    let sentenceView: Text
    let sentenceAccessibilityLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                sentenceView
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)

                HStack(spacing: 8) {
                    Image(systemName: feedbackIcon)
                        .accessibilityHidden(true)
                        .foregroundStyle(feedbackColor)
                    Text(feedbackTitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(feedbackTitle)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .layoutPriority(1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("句子提示")
            .accessibilityValue(sentenceAccessibilityLabel)
            .accessibilityHint(feedbackTitle)
        }
        .accessibilityElement(children: .contain)
    }
}

struct ListeningBottomActionRow: View {
    let primaryTitle: String
    let primaryIcon: String
    let primaryGradient: LinearGradient
    let primaryAction: () -> Void

    var body: some View {
        Button(action: primaryAction) {
            HStack(spacing: 12) {
                Text(primaryTitle)
                    .font(SurrealTheme.Typography.header(22))
                Spacer()
                Image(systemName: primaryIcon)
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(primaryGradient)
            .clipShape(Capsule())
            .shadow(color: ListeningCanvasTheme.water.opacity(0.26), radius: 18, y: 12)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("显示当前题目的答案，或进入下一题")
    }
}
