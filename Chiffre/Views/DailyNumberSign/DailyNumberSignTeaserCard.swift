import SwiftUI

struct DailyNumberSignTeaserCard: View {
    let entry: DailyNumberSignEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text("每日数字解读")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(ListeningCanvasTheme.canvasFill.opacity(0.42))
                        .clipShape(Capsule())

                    Spacer(minLength: 8)

                    HStack(spacing: 4) {
                        Text("\(entry.day)")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                }

                Text(entry.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.title.opacity(0.88))
                    .multilineTextAlignment(.leading)

                Text(entry.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body.opacity(0.82))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ListeningCanvasTheme.canvasFill.opacity(0.36))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ListeningCanvasTheme.panelStroke.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.08), radius: 8, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .accessibilityLabel("每日数字解读，\(entry.day) 号，\(entry.title)")
            .accessibilityHint("点开查看今天的数字逸闻")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
            .opacity(0.9)
            .overlay(alignment: .topLeading) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ListeningCanvasTheme.water.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .offset(y: -1)
            }
        }
        .buttonStyle(.plain)
    }
}
