import SwiftUI

struct VoiceSettingsView: View {
    @ObservedObject private var lm = LanguageVoiceManager.shared

    var body: some View {
        Form {
            Section {
                Button {
                    SpeechManager.shared.speak(lm.getTestPhrase())
                } label: {
                    Label("试听当前语音", systemImage: "speaker.wave.2.fill")
                }
            }

            if lm.currentLanguage == .french {
                Section("French Voices") {
                    ForEach(FrenchVoice.allCases) { voice in
                        VoiceRow(
                            title: voice.displayName,
                            icon: voice.icon,
                            isSelected: lm.selectedFrenchVoice == voice
                        ) {
                            lm.selectedFrenchVoice = voice
                            SpeechManager.shared.speak("Bonjour, je m'appelle \(voice.rawValue)")
                        }
                    }
                }
            } else {
                Section("Spanish Voices") {
                    ForEach(SpanishVoice.allCases) { voice in
                        VoiceRow(
                            title: voice.displayName,
                            icon: voice.icon,
                            isSelected: lm.selectedSpanishVoice == voice
                        ) {
                            lm.selectedSpanishVoice = voice
                            SpeechManager.shared.speak("Hola, me llamo \(voice.rawValue)")
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("语音")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct VoiceRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(ListeningCanvasTheme.secondary)
                    .accessibilityHidden(true)

                Text(title)
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ListeningCanvasTheme.water)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
