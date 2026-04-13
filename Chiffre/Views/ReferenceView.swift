import SwiftUI

struct ReferenceView: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

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
            ListeningBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Text("Liste")
                            .font(SurrealTheme.Typography.title(48))
                            .foregroundStyle(SurrealTheme.colors.deepIndigo)
                            .shadow(color: SurrealTheme.colors.lavenderMist.opacity(0.5), radius: 8, y: 4)
                            .padding(.top, 60)

                        Text("Les nombres utiles du quotidien")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.secondary)

                        Text(lm.currentLanguage == .french ? "完整数字写法 · 点击即可朗读" : "Números completos · toca para escuchar")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.secondary)
                            .tracking(0.6)
                    }

                    ReferenceHeroCard(languageName: lm.currentLanguage.displayName)
                        .padding(.horizontal, 20)

                    VStack(spacing: 18) {
                        ForEach(groups) { group in
                            ReferenceGroupCard(group: group)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

struct ReferenceHeroCard: View {
    let languageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Numbers")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
                Text(languageName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.water)
            }

            Text("保留完整数字写法，让 Liste 的气质和首页一样安静、清晰、耐看。")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.body)
                .lineSpacing(3)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.7), lineWidth: 1)
        )
    }
}

struct ReferenceGroupCard: View {
    let group: ReferenceView.NumberGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.frenchTitle)
                    .font(.custom("Didot", size: 28))
                    .foregroundStyle(ListeningCanvasTheme.title)

                Text(group.cnSubtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .tracking(0.8)
            }

            VStack(spacing: 10) {
                ForEach(group.entries) { entry in
                    ReferenceNumberRow(entry: entry)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.22))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.62), lineWidth: 1)
        )
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
                    .foregroundStyle(isPressed ? ListeningCanvasTheme.sunrise : ListeningCanvasTheme.title)
                    .frame(width: 54, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(spokenText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.title)
                        .multilineTextAlignment(.leading)

                    Text(lm.currentLanguage == .french ? "点击朗读" : "Tocar para escuchar")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                }

                Spacer()

                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.38 : 0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ListeningCanvasTheme.panelStroke.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(numeralText)，\(spokenText)")
        .accessibilityHint("点击播放读音")
    }
}
