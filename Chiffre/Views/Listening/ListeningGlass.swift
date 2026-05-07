import SwiftUI

struct ImpressionistGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(ListeningCanvasTheme.canvasFill)
                )
                .shadow(color: ListeningCanvasTheme.water.opacity(0.18), radius: 26, y: 14)
                .shadow(color: Color.white.opacity(0.5), radius: 8, x: -4, y: -4)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.45), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.28),
                                    ListeningCanvasTheme.dawn.opacity(0.10),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.16, y: 0.10),
                                startRadius: 6,
                                endRadius: cornerRadius * 1.5
                            )
                        )
                        .blendMode(.plusLighter)
                )

            content
        }
    }
}
