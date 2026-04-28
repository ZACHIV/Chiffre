import SwiftUI

struct AboutSettingsView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "ear.and.waveform")
                        .font(.system(size: 40))
                        .foregroundStyle(ListeningCanvasTheme.water)

                    Text("Chiffre / Cifra")
                        .font(SurrealTheme.Typography.header(24))
                        .foregroundStyle(ListeningCanvasTheme.title)

                    Text("版本 \(appVersion) (\(buildNumber))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("把最常见的生活口语，拆成可以反复训练的句子。")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.title)

                    Text("覆盖法语和西班牙语的数字、价格、时间、地址、点单等 17 个日常场景，通过听音辨数的方式帮耳朵适应真实语速。")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("简介")
            }

            Section {
                infoRow(title: "设计开发", value: "Zach")
                infoRow(title: "支持语言", value: "Français · Español")
                infoRow(title: "开源地址", value: "github.com/zach/chiffre")
            } header: {
                Text("信息")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(ListeningCanvasTheme.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(ListeningCanvasTheme.title)
        }
    }
}
