import SwiftUI

struct ReferenceView: View {
    struct NumberEntry: Identifiable {
        let number: Int
        let isInfinity: Bool

        var id: String {
            isInfinity ? "infinity" : "\(number)"
        }
    }

    struct NumberGroup: Identifiable {
        let id = UUID()
        let frenchTitle: String
        let cnSubtitle: String
        let entries: [NumberEntry]
    }

    private let groups: [NumberGroup] = [
        NumberGroup(
            frenchTitle: "Les Bases",
            cnSubtitle: "基础数字 0-20",
            entries: Array(0...20).map { NumberEntry(number: $0, isInfinity: false) }
        ),
        NumberGroup(
            frenchTitle: "Les Dizaines",
            cnSubtitle: "完整十位与复合数 21-69",
            entries: Array(21...69).map { NumberEntry(number: $0, isInfinity: false) }
        ),
        NumberGroup(
            frenchTitle: "Les Complexes",
            cnSubtitle: "完整复杂数 70-100 · 1000 · 无限",
            entries: Array(70...100).map { NumberEntry(number: $0, isInfinity: false) }
                + [NumberEntry(number: 1000, isInfinity: false), NumberEntry(number: -1, isInfinity: true)]
        )
    ]

    var body: some View {
        ZStack {
            SurrealTheme.mainBackground

            VStack(spacing: 0) {
                Text("Référence")
                    .font(SurrealTheme.Typography.title(48))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                    .padding(.top, 60)
                    .padding(.bottom, 4)

                Text("完整数字写法 · 点击即可朗读")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.4))
                    .tracking(0.3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 34) {
                        ForEach(groups) { group in
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(group.frenchTitle)
                                        .font(.custom("Didot", size: 30))
                                        .foregroundStyle(SurrealTheme.colors.deepIndigo)

                                    Text(group.cnSubtitle)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.5))
                                        .tracking(1)
                                }

                                VStack(spacing: 10) {
                                    ForEach(group.entries) { entry in
                                        ReferenceNumberRow(entry: entry)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

struct ReferenceNumberRow: View {
    let entry: ReferenceView.NumberEntry
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @State private var isPressed = false

    private var spokenText: String {
        if entry.isInfinity {
            return lm.currentLanguage == .french ? "L'infini" : "El infinito"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: lm.currentLanguage.localeIdentifier)
        return formatter.string(from: NSNumber(value: entry.number)) ?? "\(entry.number)"
    }

    private var numeralText: String {
        entry.isInfinity ? "∞" : "\(entry.number)"
    }

    var body: some View {
        Button {
            SpeechManager.shared.speak(spokenText)

            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.26, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.easeOut(duration: 0.16)) {
                    isPressed = false
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                Text(numeralText)
                    .font(.custom("Didot", size: entry.isInfinity ? 34 : (entry.number >= 100 ? 28 : 30)))
                    .foregroundStyle(isPressed ? SurrealTheme.colors.coral : SurrealTheme.colors.deepIndigo)
                    .frame(width: 54, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(spokenText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo)
                        .multilineTextAlignment(.leading)

                    Text(lm.currentLanguage == .french ? "点击朗读" : "Tocar para escuchar")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.38))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.34 : 0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(SurrealTheme.colors.deepIndigo.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(numeralText)，\(spokenText)")
        .accessibilityHint("点击播放读音")
    }
}
