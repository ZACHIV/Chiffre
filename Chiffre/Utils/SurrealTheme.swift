import SwiftUI

struct SurrealTheme {
    struct Colors {
        let background = Color(red: 0.95, green: 0.94, blue: 0.90)
        let backgroundSecondary = Color(red: 0.98, green: 0.97, blue: 0.95)
        let surface = Color.white.opacity(0.90)
        let surfaceStrong = Color(red: 0.99, green: 0.98, blue: 0.97)
        let surfaceMuted = Color(red: 0.93, green: 0.91, blue: 0.88)
        let deepIndigo = Color(red: 0.12, green: 0.16, blue: 0.25)
        let waterBlue = Color(red: 0.42, green: 0.55, blue: 0.68)
        let lavenderMist = Color(red: 0.82, green: 0.82, blue: 0.88)
        let coral = Color(red: 0.90, green: 0.45, blue: 0.34)
        let skyDawn = Color(red: 0.97, green: 0.84, blue: 0.72)
        let lilyPad = Color(red: 0.41, green: 0.59, blue: 0.50)
        let textSecondary = Color(red: 0.35, green: 0.39, blue: 0.47)
        let border = Color(red: 0.17, green: 0.20, blue: 0.27).opacity(0.10)
        let shadow = Color(red: 0.10, green: 0.12, blue: 0.17).opacity(0.12)
        let danger = Color(red: 0.76, green: 0.25, blue: 0.22)
    }

    static let colors = Colors()

    struct Typography {
        static func title(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func header(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }

        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }

        static func label(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func number(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
    }

    static var mainBackground: some View {
        ChiffreBackground()
    }
}

private struct ChiffreBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SurrealTheme.colors.backgroundSecondary,
                    SurrealTheme.colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(SurrealTheme.colors.skyDawn.opacity(0.45))
                .frame(width: 260, height: 260)
                .blur(radius: 48)
                .offset(x: 120, y: -220)

            Circle()
                .fill(SurrealTheme.colors.waterBlue.opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 72)
                .offset(x: -150, y: 260)

            Circle()
                .fill(SurrealTheme.colors.lilyPad.opacity(0.10))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: 140, y: 320)
        }
    }
}
