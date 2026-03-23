import SwiftUI

struct ListeningBackground: View {
    @State private var drift = false
    @State private var shimmer = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ListeningCanvasTheme.background

                Circle()
                    .fill(ListeningCanvasTheme.dawn.opacity(0.22))
                    .frame(width: proxy.size.width * 0.72, height: proxy.size.width * 0.72)
                    .blur(radius: 70)
                    .offset(x: drift ? -90 : -30, y: drift ? -180 : -130)

                Circle()
                    .fill(ListeningCanvasTheme.water.opacity(0.22))
                    .frame(width: proxy.size.width * 0.7, height: proxy.size.width * 0.7)
                    .blur(radius: 80)
                    .offset(x: drift ? 70 : 120, y: drift ? 140 : 90)

                Circle()
                    .trim(from: 0.08, to: 0.74)
                    .stroke(ListeningCanvasTheme.dawn.opacity(0.16), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .frame(width: proxy.size.width * 1.08, height: proxy.size.width * 1.08)
                    .offset(x: proxy.size.width * 0.28, y: proxy.size.height * 0.14)
                    .rotationEffect(.degrees(drift ? 10 : -8))

                Circle()
                    .trim(from: 0.18, to: 0.84)
                    .stroke(ListeningCanvasTheme.water.opacity(0.16), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .frame(width: proxy.size.width * 0.84, height: proxy.size.width * 0.84)
                    .offset(x: -proxy.size.width * 0.22, y: proxy.size.height * 0.3)
                    .rotationEffect(.degrees(drift ? -16 : -3))

                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(index.isMultiple(of: 3) ? 0.62 : 0.38))
                        .frame(width: index.isMultiple(of: 4) ? 5 : 3, height: index.isMultiple(of: 4) ? 5 : 3)
                        .position(starPosition(in: proxy.size, index: index))
                        .scaleEffect(shimmer ? 1.14 : 0.86)
                        .animation(
                            .easeInOut(duration: 1.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.09),
                            value: shimmer
                        )
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    drift.toggle()
                }
                withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) {
                    shimmer.toggle()
                }
            }
        }
    }

    private func starPosition(in size: CGSize, index: Int) -> CGPoint {
        let points: [CGPoint] = [
            CGPoint(x: 0.12, y: 0.14), CGPoint(x: 0.34, y: 0.18), CGPoint(x: 0.62, y: 0.12),
            CGPoint(x: 0.82, y: 0.16), CGPoint(x: 0.18, y: 0.38), CGPoint(x: 0.76, y: 0.34),
            CGPoint(x: 0.58, y: 0.54), CGPoint(x: 0.12, y: 0.62), CGPoint(x: 0.88, y: 0.58),
            CGPoint(x: 0.28, y: 0.76), CGPoint(x: 0.66, y: 0.82), CGPoint(x: 0.9, y: 0.74)
        ]
        let point = points[index]
        return CGPoint(x: size.width * point.x, y: size.height * point.y)
    }
}

struct ListeningSunriseGlyph: View {
    let accent: Color
    @State private var rise = false
    private let tallBars: [CGFloat] = [14, 22, 34, 20, 12]
    private let shortBars: [CGFloat] = [10, 16, 22, 16, 10]

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(accent.opacity(0.92), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 58, height: 58)
                    .scaleEffect(rise ? 1 : 0.92)

                Circle()
                    .trim(from: 0.05, to: 0.82)
                    .stroke(ListeningCanvasTheme.water.opacity(0.78), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 82, height: 82)
                    .rotationEffect(.degrees(rise ? 4 : -6))

                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 28, height: 28)
                    .offset(y: 8)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(index == 2 ? accent : ListeningCanvasTheme.water.opacity(0.9))
                        .frame(width: 8, height: rise ? tallBars[index] : shortBars[index])
                        .animation(
                            .easeInOut(duration: 0.9)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.08),
                            value: rise
                        )
                }
            }
        }
        .onAppear {
            rise = true
        }
    }
}
