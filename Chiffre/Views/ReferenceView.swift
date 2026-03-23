import SwiftUI

struct ReferenceView: View {
    struct NumberGroup: Identifiable {
        let id = UUID()
        let frenchTitle: String
        let cnSubtitle: String
        let numbers: [Int]
    }

    @ObservedObject private var lm = LanguageVoiceManager.shared

    private let groups: [NumberGroup] = [
        NumberGroup(frenchTitle: "Les Bases", cnSubtitle: "基础数字 1-20", numbers: Array(1...20)),
        NumberGroup(frenchTitle: "Les Dizaines", cnSubtitle: "整十进位", numbers: [30, 40, 50, 60]),
        NumberGroup(
            frenchTitle: "Les Complexes",
            cnSubtitle: "进位 · 大数 · 无限",
            numbers: Array(70...79) + [80] + Array(90...99) + [100, 1000, -1]
        )
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 12)
    ]

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection

                    ForEach(groups) { group in
                        ChiffreCard {
                            ChiffreSectionHeader(
                                eyebrow: group.frenchTitle,
                                title: group.cnSubtitle,
                                caption: "点击任一卡片即可朗读；拼写会根据当前语言即时切换。"
                            )

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(group.numbers, id: \.self) { number in
                                    ReferenceNumberCell(number: number, text: spokenText(for: number))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Référence")
                .font(SurrealTheme.Typography.title(34))
                .foregroundStyle(SurrealTheme.colors.deepIndigo)

            Text("把高频数字和复杂结构做成可点击的速查卡，减少被动翻找。")
                .font(SurrealTheme.Typography.body(15))
                .foregroundStyle(SurrealTheme.colors.textSecondary)

            HStack(spacing: 10) {
                ChiffreBadge(title: lm.currentLanguage.displayName, systemImage: "globe")
                ChiffreBadge(title: "点击朗读", systemImage: "speaker.wave.2.fill", tint: SurrealTheme.colors.coral)
            }
        }
    }

    private func spokenText(for number: Int) -> String {
        if number == -1 {
            return lm.currentLanguage == .french ? "L'infini" : "El infinito"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: lm.currentLanguage.localeIdentifier)
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

private struct ReferenceNumberCell: View {
    let number: Int
    let text: String

    var body: some View {
        Button {
            SpeechManager.shared.speak(text)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text(number == -1 ? "∞" : "\(number)")
                    .font(SurrealTheme.Typography.number(number >= 1000 ? 30 : 36))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)

                Text(text)
                    .font(SurrealTheme.Typography.body(14))
                    .foregroundStyle(SurrealTheme.colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(SurrealTheme.colors.surfaceStrong)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(SurrealTheme.colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
