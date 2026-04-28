import SwiftUI

struct InterfaceSettingsView: View {
    @Binding var ambientMotionEnabled: Bool
    @AppStorage("hapticFeedbackEnabled") private var hapticEnabled = true

    var body: some View {
        Form {
            Section {
                Toggle("动态背景", isOn: $ambientMotionEnabled)
            } footer: {
                Text("关闭后会保留静态光感和留白，但不再让背景和光点持续漂移。")
            }

            Section {
                Toggle("触感反馈", isOn: $hapticEnabled)
            } footer: {
                Text("揭晓答案和切换题目时提供轻柔的触感确认。")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("画面与动效")
        .navigationBarTitleDisplayMode(.inline)
    }
}
