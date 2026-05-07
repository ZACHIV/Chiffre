import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            glyph: AnyView(ListeningSunriseGlyph(accent: ListeningCanvasTheme.sunrise)),
            title: "听",
            headline: "先完整听一句",
            body: "每个句子都来自真实生活场景，\n像在对话中一样自然接收。"
        ),
        OnboardingPage(
            glyph: AnyView(OnboardingRevealGlyph()),
            title: "认",
            headline: "确认后揭晓答案",
            body: "检查你是否正确听出了数字。\n答对答错都是进步。"
        ),
        OnboardingPage(
            glyph: AnyView(OnboardingPracticeGlyph()),
            title: "练",
            headline: "反复训练，形成直觉",
            body: "从日常对话到航班号、咖啡订单，\n17 种场景让数字在耳边自动浮现。"
        )
    ]

    var body: some View {
        ZStack {
            ListeningBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("跳过") {
                        finish()
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .padding(.top, 8)

                Spacer(minLength: 0)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, p in
                        OnboardingCard(page: p)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? ListeningCanvasTheme.title : ListeningCanvasTheme.canvasStroke.opacity(0.5))
                            .frame(width: index == page ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: page)
                    }
                }
                .padding(.bottom, 28)

                Button(action: advance) {
                    Text(page < pages.count - 1 ? "继续" : "开始训练")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(ListeningCanvasTheme.primaryGradient)
                        )
                        .shadow(color: ListeningCanvasTheme.water.opacity(0.25), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
                .padding(.bottom, 44)
            }
        }
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                page += 1
            }
        } else {
            finish()
        }
    }

    private func finish() {
        withAnimation(.easeOut(duration: 0.3)) {
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Page Model

struct OnboardingPage {
    let glyph: AnyView
    let title: String
    let headline: String
    let body: String
}

// MARK: - Card

struct OnboardingCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            page.glyph
                .frame(height: 120)

            Text(page.title)
                .font(SurrealTheme.Typography.title(72))
                .foregroundStyle(ListeningCanvasTheme.title)
                .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.45), radius: 10, y: 5)

            Text(page.headline)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.title)
                .multilineTextAlignment(.center)

            Text(page.body)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.body)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 28)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: ListeningCanvasTheme.water.opacity(0.14), radius: 24, y: 12)
        .shadow(color: Color.white.opacity(0.4), radius: 6, x: -3, y: -3)
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }
}

// MARK: - Screen 2 Glyph: Reveal

struct OnboardingRevealGlyph: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.92)
                .stroke(ListeningCanvasTheme.leaf.opacity(0.7), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: 64, height: 64)
                .scaleEffect(appear ? 1 : 0.85)
                .opacity(appear ? 1 : 0.4)

            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(ListeningCanvasTheme.leaf)
                .scaleEffect(appear ? 1 : 0.6)
                .opacity(appear ? 1 : 0.3)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Screen 3 Glyph: Practice

struct OnboardingPracticeGlyph: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.05, to: 0.95)
                .stroke(ListeningCanvasTheme.sunrise.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 72, height: 72)

            Circle()
                .trim(from: appear ? 0 : 0.82, to: appear ? 0.78 : 0.8)
                .stroke(ListeningCanvasTheme.water.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 88, height: 88)
                .rotationEffect(.degrees(appear ? 360 : 0))
                .animation(
                    .linear(duration: 6).repeatForever(autoreverses: false),
                    value: appear
                )

            Text("∞")
                .font(.custom("Didot", size: 26))
                .foregroundStyle(ListeningCanvasTheme.title)
        }
        .onAppear {
            appear = true
        }
    }
}
