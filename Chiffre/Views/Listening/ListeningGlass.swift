import SwiftUI

struct ImpressionistGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content
    @State private var borderRotation: Double = 0

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
                        .stroke(
                            AngularGradient(
                                colors: [
                                    ListeningCanvasTheme.water.opacity(0.2),
                                    ListeningCanvasTheme.dawn.opacity(0.95),
                                    Color.white.opacity(0.85),
                                    ListeningCanvasTheme.mist.opacity(0.4),
                                    ListeningCanvasTheme.water.opacity(0.2)
                                ],
                                center: .center,
                                angle: .degrees(borderRotation)
                            ),
                            lineWidth: 1.4
                        )
                )

            content
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                borderRotation = 360
            }
        }
    }
}
