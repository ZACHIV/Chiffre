import SwiftUI

struct DailyNumberSignTeaserCard: View {
    let entry: DailyNumberSignEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ImpressionistGlassCard(cornerRadius: 28) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aujourd'hui \(entry.day)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(ListeningCanvasTheme.sunrise)

                            Text(entry.title)
                                .font(SurrealTheme.Typography.header(24))
                                .foregroundStyle(ListeningCanvasTheme.title)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer(minLength: 12)

                        Image(systemName: "calendar.badge.sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(ListeningCanvasTheme.water)
                            .padding(10)
                            .background(Color.white.opacity(0.22))
                            .clipShape(Circle())
                    }

                    Text(entry.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.body)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("点开读今天这则法式无用吐槽")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DailyNumberSignSheet: View {
    let entry: DailyNumberSignEntry
    @Environment(\.dismiss) private var dismiss
    @State private var revealHeader = false
    @State private var revealCopy = false
    @State private var revealStory = false
    @State private var revealMotif = false
    @State private var hasAnimatedIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                ListeningCanvasTheme.background
                    .ignoresSafeArea()

                DailySignAmbientBackdrop()
                    .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerCard
                            .modifier(DailySignEntrance(visible: revealHeader, offset: 18, scale: 0.98))

                        copyCard(
                            eyebrow: "今日废话",
                            icon: "text.quote",
                            text: entry.dailyCopy,
                            accent: ListeningCanvasTheme.sunrise.opacity(0.9)
                        )
                        .modifier(DailySignEntrance(visible: revealCopy, offset: 22))

                        copyCard(
                            eyebrow: "数字逸闻",
                            icon: "books.vertical.fill",
                            text: entry.numberStory,
                            accent: ListeningCanvasTheme.water.opacity(0.92)
                        )
                        .modifier(DailySignEntrance(visible: revealStory, offset: 24))

                        motifCard
                            .modifier(DailySignEntrance(visible: revealMotif, offset: 20))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            guard !hasAnimatedIn else { return }
            hasAnimatedIn = true

            withAnimation(.spring(response: 0.62, dampingFraction: 0.86)) {
                revealHeader = true
            }

            withAnimation(.spring(response: 0.58, dampingFraction: 0.88).delay(0.08)) {
                revealCopy = true
            }

            withAnimation(.spring(response: 0.58, dampingFraction: 0.9).delay(0.16)) {
                revealStory = true
            }

            withAnimation(.easeOut(duration: 0.42).delay(0.24)) {
                revealMotif = true
            }
        }
    }

    private var headerCard: some View {
        DailySignGlassCard(cornerRadius: 30, accent: ListeningCanvasTheme.sunrise, shimmerStrength: 1) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Aujourd'hui \(entry.day)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.sunrise)

                        Text(entry.title)
                            .font(SurrealTheme.Typography.title(34))
                            .foregroundStyle(ListeningCanvasTheme.title)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 12)

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ListeningCanvasTheme.dawn.opacity(0.95),
                                        ListeningCanvasTheme.water.opacity(0.34),
                                        Color.white.opacity(0.18)
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 38
                                )
                            )
                            .frame(width: 64, height: 64)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.46), lineWidth: 1)
                            )

                        Text("\(entry.day)")
                            .font(SurrealTheme.Typography.number(26))
                            .foregroundStyle(ListeningCanvasTheme.title)
                    }
                }

                Text(entry.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                ListeningCanvasTheme.sunrise.opacity(0.65),
                                Color.white.opacity(0.72),
                                ListeningCanvasTheme.water.opacity(0.48),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 160, height: 3)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
    }

    private func copyCard(eyebrow: String, icon: String, text: String, accent: Color) -> some View {
        DailySignGlassCard(cornerRadius: 26, accent: accent, shimmerStrength: 0.58) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                    Text(eyebrow)
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)

                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
    }

    private var motifCard: some View {
        DailySignGlassCard(cornerRadius: 24, accent: ListeningCanvasTheme.leaf, shimmerStrength: 0.38) {
            VStack(alignment: .leading, spacing: 10) {
                Text("视觉线索")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)

                Text(entry.visualMotif)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }
}

private struct DailySignGlassCard<Content: View>: View {
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

private struct DailySignAmbientBackdrop: View {
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

private struct DailySignEntrance: ViewModifier {
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
