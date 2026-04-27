import SwiftUI

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

private struct SettingsHeroLine: View {
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
