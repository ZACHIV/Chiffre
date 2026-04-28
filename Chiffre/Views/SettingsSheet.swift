import SwiftUI

struct SettingsView: View {
    @ObservedObject var trainer: NumberTrainer
    @ObservedObject private var lm = LanguageVoiceManager.shared
    @AppStorage("listeningAmbientMotionEnabled") private var ambientMotionEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsHeroCard(
                        languageName: lm.currentLanguage.displayName,
                        modeName: trainer.mode.rawValue,
                        modeSummary: trainer.mode.summary
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                Section {
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        SettingsNavigationRow(
                            title: "语言",
                            value: lm.currentLanguage.displayName
                        )
                    }

                    NavigationLink {
                        ModeSettingsView(trainer: trainer)
                    } label: {
                        SettingsNavigationRow(
                            title: "类别",
                            value: trainer.mode.rawValue
                        )
                    }

                    if trainer.mode.isRangeConfigurable {
                        NavigationLink {
                            RangeSettingsView(trainer: trainer)
                        } label: {
                            SettingsNavigationRow(
                                title: "数字范围",
                                value: "0 - \(trainer.maxRange)"
                            )
                        }
                    }
                } header: {
                    Text("Practice")
                }

                Section {
                    NavigationLink {
                        PlaybackSettingsView(trainer: trainer)
                    } label: {
                        SettingsNavigationRow(
                            title: "播放速度",
                            value: "\(trainer.speedLabel) · \(String(format: "%.2f", trainer.playbackRate))"
                        )
                    }

                    NavigationLink {
                        VoiceSettingsView()
                    } label: {
                        SettingsNavigationRow(
                            title: "语音",
                            value: currentVoiceName
                        )
                    }
                } header: {
                    Text("Audio")
                }

                Section {
                    NavigationLink {
                        InterfaceSettingsView(ambientMotionEnabled: $ambientMotionEnabled)
                    } label: {
                        SettingsNavigationRow(
                            title: "画面与动效",
                            value: ambientMotionEnabled ? "动态背景开启" : "动态背景关闭"
                        )
                    }
                } header: {
                    Text("Interface")
                }

                Section {
                    NavigationLink {
                        DataSettingsView(trainer: trainer)
                    } label: {
                        SettingsNavigationRow(
                            title: "数据",
                            value: "\(trainer.lifetimePracticeCount) 次"
                        )
                    }
                } header: {
                    Text("Data")
                }

                Section {
                    NavigationLink {
                        AboutSettingsView()
                    } label: {
                        SettingsNavigationRow(
                            title: "关于",
                            value: "Chiffre"
                        )
                    }
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ListeningCanvasTheme.background)
            .navigationTitle("Réglages")
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
