import SwiftUI

enum ListeningCanvasTheme {
    static var background: some View { SurrealTheme.mainBackground }

    static let canvasFill = Color.white.opacity(0.12)
    static let canvasStroke = Color.white.opacity(0.28)
    static let panelFill = Color.white.opacity(0.1)
    static let panelStroke = SurrealTheme.colors.deepIndigo.opacity(0.12)

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
            SurrealTheme.colors.skyDawn.opacity(0.42),
            SurrealTheme.colors.waterBlue.opacity(0.28),
            SurrealTheme.colors.lavenderMist.opacity(0.38)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryGradient = LinearGradient(
        colors: [
            SurrealTheme.colors.skyDawn,
            SurrealTheme.colors.coral
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let successGradient = LinearGradient(
        colors: [
            SurrealTheme.colors.lilyPad,
            SurrealTheme.colors.waterBlue.opacity(0.8)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    struct Metrics {
        let size: CGSize

        var horizontalPadding: CGFloat { size.width > 430 ? 28 : 20 }
        var topPadding: CGFloat { size.height < 760 ? 18 : 28 }
        var bottomPadding: CGFloat { size.height < 760 ? 14 : 22 }
        var sectionSpacing: CGFloat { size.height < 760 ? 16 : 22 }
        var brandSize: CGFloat { size.width > 430 ? 56 : 48 }
        var stageHeight: CGFloat { min(max(size.height * 0.3, 240), 320) }
        var stageCornerRadius: CGFloat { size.height < 760 ? 30 : 36 }
        var panelCornerRadius: CGFloat { 26 }
        var stagePadding: CGFloat { size.height < 760 ? 20 : 24 }
        var actionRowSpacing: CGFloat { 14 }
    }
}
