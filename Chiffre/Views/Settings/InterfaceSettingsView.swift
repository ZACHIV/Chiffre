import SwiftUI

struct InterfaceSettingsView: View {
    @Binding var ambientMotionEnabled: Bool

    var body: some View {
        Form {
            Section {
                Toggle("动态背景", isOn: $ambientMotionEnabled)
            } footer: {
                Text("关闭后会保留静态光感和留白，但不再让背景和光点持续漂移。")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("画面与动效")
        .navigationBarTitleDisplayMode(.inline)
    }
}
