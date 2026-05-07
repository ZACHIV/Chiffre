import SwiftUI

struct SettingsView: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @AppStorage("listeningAmbientMotionEnabled") private var ambientMotionEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                ListeningBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        SettingsHeroCard(
                            languageName: lm.currentLanguage.displayName,
                            modeName: trainer.mode.rawValue,
                            modeSummary: trainer.mode.summary
                        )
                        .padding(.horizontal, 20)

                        SettingsSection(title: "Practice") {
                            NavigationLink {
                                LanguageSettingsView()
                            } label: {
                                SettingsNavigationRow(title: "语言", value: lm.currentLanguage.displayName)
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)

                            SettingsDivider()

                            NavigationLink {
                                ModeSettingsView(trainer: trainer)
                            } label: {
                                SettingsNavigationRow(title: "类别", value: trainer.mode.rawValue)
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)

                            if trainer.mode.isRangeConfigurable {
                                SettingsDivider()
                                NavigationLink {
                                    RangeSettingsView(trainer: trainer)
                                } label: {
                                    SettingsNavigationRow(title: "数字范围", value: "0 - \(trainer.maxRange)")
                                        .padding(.vertical, 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        SettingsSection(title: "Audio") {
                            NavigationLink {
                                PlaybackSettingsView(trainer: trainer)
                            } label: {
                                SettingsNavigationRow(title: "播放速度", value: "\(trainer.speedLabel) · \(String(format: "%.2f", trainer.playbackRate))")
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)

                            SettingsDivider()

                            NavigationLink {
                                VoiceSettingsView()
                            } label: {
                                SettingsNavigationRow(title: "语音", value: currentVoiceName)
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)
                        }

                        SettingsSection(title: "Interface") {
                            NavigationLink {
                                InterfaceSettingsView(ambientMotionEnabled: $ambientMotionEnabled)
                            } label: {
                                SettingsNavigationRow(title: "画面与动效", value: ambientMotionEnabled ? "动态背景开启" : "动态背景关闭")
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)
                        }

                        SettingsSection(title: "Data") {
                            NavigationLink {
                                DataSettingsView(trainer: trainer)
                            } label: {
                                SettingsNavigationRow(title: "数据", value: "\(trainer.lifetimePracticeCount) 次")
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)
                        }

                        SettingsSection(title: "About") {
                            NavigationLink {
                                AboutSettingsView()
                            } label: {
                                SettingsNavigationRow(title: "关于", value: "Chiffre")
                                    .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var currentVoiceName: String {
        switch lm.currentLanguage {
        case .french:
            lm.selectedFrenchVoice.displayName
        case .spanish:
            lm.selectedSpanishVoice.displayName
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .padding(.horizontal, 36)

            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ListeningCanvasTheme.canvasStroke.opacity(0.6), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(ListeningCanvasTheme.canvasStroke.opacity(0.35))
            .frame(height: 1)
            .padding(.leading, 4)
    }
}
