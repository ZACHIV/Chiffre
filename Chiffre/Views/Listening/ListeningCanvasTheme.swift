import SwiftUI

enum ListeningCanvasTheme {
    static var background: some View { SurrealTheme.mainBackground }

    static let canvasFill = Color.white.opacity(0.16)
    static let canvasStroke = Color.white.opacity(0.34)
    static let panelFill = Color.white.opacity(0.12)
    static let panelStroke = SurrealTheme.colors.deepIndigo.opacity(0.1)

    static let title = SurrealTheme.colors.deepIndigo
    static let body = SurrealTheme.colors.deepIndigo.opacity(0.76)
    static let secondary = SurrealTheme.colors.deepIndigo.opacity(0.46)

    static let sunrise = SurrealTheme.colors.coral
    static let dawn = SurrealTheme.colors.skyDawn
    static let water = SurrealTheme.colors.waterBlue
    static let mist = SurrealTheme.colors.lavenderMist
    static let leaf = SurrealTheme.colors.lilyPad

    static let stageGradient = LinearGradient(
        colors: [
            SurrealTheme.colors.skyDawn.opacity(0.46),
            SurrealTheme.colors.lavenderMist.opacity(0.38),
            SurrealTheme.colors.waterBlue.opacity(0.32),
            Color.white.opacity(0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.50, green: 0.56, blue: 0.79),
            Color(red: 0.73, green: 0.80, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pillGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.42),
            SurrealTheme.colors.lavenderMist.opacity(0.24),
            SurrealTheme.colors.skyDawn.opacity(0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [
            Color(red: 0.57, green: 0.73, blue: 0.71),
            Color(red: 0.78, green: 0.88, blue: 0.84)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    struct Metrics {
        let size: CGSize

        var horizontalPadding: CGFloat { size.width > 430 ? 30 : 22 }
        var topPadding: CGFloat { size.height < 760 ? 24 : 34 }
        var bottomPadding: CGFloat { size.height < 760 ? 24 : 30 }
        var sectionSpacing: CGFloat { size.height < 760 ? 22 : 34 }
        var brandSize: CGFloat { size.width > 430 ? 64 : 58 }
        var stageHeight: CGFloat { min(max(size.height * 0.31, 254), 322) }
        var stageCornerRadius: CGFloat { size.height < 760 ? 30 : 36 }
        var panelCornerRadius: CGFloat { 26 }
        var stagePadding: CGFloat { size.height < 760 ? 24 : 30 }
        var actionRowSpacing: CGFloat { 14 }
        var headerSpacing: CGFloat { size.height < 760 ? 18 : 22 }
        var modeControlHeight: CGFloat { size.height < 760 ? 42 : 48 }
    }
}
