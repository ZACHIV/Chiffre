import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        Form {
            Section {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                            lm.currentLanguage = language
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(language.icon)
                                .font(.system(size: 20))
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(language.displayName)
                                    .foregroundStyle(ListeningCanvasTheme.title)
                                Text(language.localeIdentifier)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(ListeningCanvasTheme.secondary)
                            }

                            Spacer()

                            if lm.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(ListeningCanvasTheme.water)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(lm.currentLanguage == language ? .isSelected : [])
                }
            } footer: {
                Text("切换语言后，语音和题目都会自动更新。")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("语言")
        .navigationBarTitleDisplayMode(.inline)
    }
}
