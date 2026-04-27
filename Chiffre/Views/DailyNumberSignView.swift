import SwiftUI

struct DailyNumberSignSheet: View {
    let entry: DailyNumberSignEntry
    @Environment(\.dismiss) private var dismiss
    @State private var revealHeader = false
    @State private var revealStory = false
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
                            eyebrow: "数字逸闻",
                            icon: "books.vertical.fill",
                            text: entry.numberStory,
                            accent: ListeningCanvasTheme.water.opacity(0.92)
                        )
                        .modifier(DailySignEntrance(visible: revealStory, offset: 22))
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
            withAnimation(.spring(response: 0.58, dampingFraction: 0.9).delay(0.08)) {
                revealStory = true
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
}
