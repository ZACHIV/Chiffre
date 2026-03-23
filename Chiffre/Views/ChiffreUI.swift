import SwiftUI

struct ChiffreCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(SurrealTheme.colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(SurrealTheme.colors.border, lineWidth: 1)
        )
        .shadow(color: SurrealTheme.colors.shadow, radius: 20, x: 0, y: 10)
    }
}

struct ChiffreSectionHeader: View {
    let eyebrow: String
    let title: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(SurrealTheme.Typography.label(11))
                .tracking(1.1)
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            Text(title)
                .font(SurrealTheme.Typography.header(24))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)

            Text(caption)
                .font(SurrealTheme.Typography.body(14))
                .foregroundStyle(SurrealTheme.colors.textSecondary)
        }
    }
}

struct ChiffreBadge: View {
    let title: String
    let systemImage: String
    var tint: Color = SurrealTheme.colors.deepIndigo

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(SurrealTheme.Typography.label(12))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(tint.opacity(0.10))
            )
    }
}

struct ChiffreMetricCard: View {
    let title: String
    let value: String
    let caption: String
    var tint: Color = SurrealTheme.colors.deepIndigo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(SurrealTheme.Typography.label(12))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            Text(value)
                .font(SurrealTheme.Typography.header(24))
                .monospacedDigit()
                .foregroundStyle(tint)

            Text(caption)
                .font(SurrealTheme.Typography.body(12))
                .foregroundStyle(SurrealTheme.colors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(SurrealTheme.colors.surfaceStrong)
        )
    }
}

struct ChiffreActionButton: View {
    enum Style {
        case primary
        case secondary
        case quiet
    }

    let title: String
    let systemImage: String
    let style: Style
    var fullWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(SurrealTheme.Typography.label(16))
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: 54)
                .padding(.horizontal, 18)
                .background(background)
                .foregroundStyle(foreground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(border, lineWidth: borderLineWidth)
                )
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return SurrealTheme.colors.deepIndigo
        case .quiet:
            return SurrealTheme.colors.textSecondary
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(fillColor)
    }

    private var fillColor: Color {
        switch style {
        case .primary:
            return SurrealTheme.colors.deepIndigo
        case .secondary:
            return SurrealTheme.colors.surfaceStrong
        case .quiet:
            return Color.clear
        }
    }

    private var border: Color {
        switch style {
        case .primary:
            return .clear
        case .secondary:
            return SurrealTheme.colors.border
        case .quiet:
            return .clear
        }
    }

    private var borderLineWidth: CGFloat {
        switch style {
        case .secondary:
            return 1
        case .primary, .quiet:
            return 0
        }
    }
}

struct ChiffreOptionTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    var accent: Color = SurrealTheme.colors.deepIndigo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : accent)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? accent.opacity(0.25) : accent.opacity(0.10))
                    )

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Text(title)
                .font(SurrealTheme.Typography.header(17))
                .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)

            Text(subtitle)
                .font(SurrealTheme.Typography.body(13))
                .foregroundStyle(isSelected ? Color.white.opacity(0.82) : SurrealTheme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isSelected ? accent : SurrealTheme.colors.surfaceStrong)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? accent : SurrealTheme.colors.border, lineWidth: 1)
        )
    }
}

struct ChiffreStatusTag: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(SurrealTheme.Typography.label(12))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(tint.opacity(0.12))
            )
    }
}
