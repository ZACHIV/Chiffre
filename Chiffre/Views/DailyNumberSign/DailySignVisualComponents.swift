import SwiftUI

struct DailySignGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let accent: Color
    let shimmerStrength: Double
    @ViewBuilder let content: Content

    @State private var rotateGlow = false
    @State private var sweepHighlight = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape
                .fill(.ultraThinMaterial)
                .background(
                    shape
                        .fill(ListeningCanvasTheme.canvasFill.opacity(0.76))
                )
                .overlay {
                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.16),
                                    Color.clear,
                                    accent.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.34),
                                    accent.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: 120
                            )
                        )
                        .frame(width: 180, height: 180)
                        .offset(x: -40, y: -55)
                        .blur(radius: 12)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accent.opacity(0.16),
                                    ListeningCanvasTheme.water.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 4,
                                endRadius: 110
                            )
                        )
                        .frame(width: 150, height: 150)
                        .offset(x: 44, y: 52)
                        .blur(radius: 14)
                        .allowsHitTesting(false)
                }

            content
        }
        .overlay {
            shape
                .stroke(Color.white.opacity(0.26), lineWidth: 0.8)
        }
        .overlay {
            shape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.06),
                            accent.opacity(0.16),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )
        }
        .overlay {
            shape
                .stroke(
                    AngularGradient(
                        colors: [
                            accent.opacity(0.05),
                            Color.white.opacity(0.8 * shimmerStrength),
                            ListeningCanvasTheme.water.opacity(0.54 * shimmerStrength),
                            Color.white.opacity(0.14),
                            accent.opacity(0.05)
                        ],
                        center: .center,
                        angle: .degrees(rotateGlow ? 360 : 0)
                    ),
                    lineWidth: 1.2
                )
                .blur(radius: 0.3)
        }
        .overlay {
            GeometryReader { proxy in
                let sweepWidth = max(proxy.size.width * 0.34, 120)

                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.04),
                        Color.white.opacity(0.8 * shimmerStrength),
                        accent.opacity(0.5 * shimmerStrength),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: sweepWidth)
                .blur(radius: 8)
                .rotationEffect(.degrees(18))
                .offset(x: sweepHighlight ? proxy.size.width + sweepWidth : -sweepWidth * 1.35)
                .mask(
                    shape
                        .stroke(lineWidth: 3.2)
                )
            }
            .allowsHitTesting(false)
        }
        .shadow(color: accent.opacity(0.1 + shimmerStrength * 0.08), radius: 30, y: 14)
        .shadow(color: ListeningCanvasTheme.water.opacity(0.16), radius: 12, x: -3, y: -4)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotateGlow = true
            }
            withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: false)) {
                sweepHighlight = true
            }
        }
    }
}

struct DailySignAmbientBackdrop: View {
    @State private var driftTop = false
    @State private var driftBottom = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ListeningCanvasTheme.sunrise.opacity(0.16),
                            ListeningCanvasTheme.sunrise.opacity(0.03),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 170
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: driftTop ? 130 : 84, y: driftTop ? -250 : -220)
                .blur(radius: 30)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ListeningCanvasTheme.water.opacity(0.18),
                            ListeningCanvasTheme.mist.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 14,
                        endRadius: 190
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: driftBottom ? -120 : -78, y: driftBottom ? 270 : 232)
                .blur(radius: 36)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(pulse ? 0.18 : 0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(y: -40)
                .blur(radius: 18)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                driftTop = true
            }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                driftBottom = true
            }
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct DailySignEntrance: ViewModifier {
    let visible: Bool
    let offset: CGFloat
    var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : offset)
            .scaleEffect(visible ? 1 : scale)
    }
}
