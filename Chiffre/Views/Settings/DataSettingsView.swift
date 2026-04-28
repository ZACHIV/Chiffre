import SwiftUI

struct DataSettingsView: View {
    @ObservedObject var trainer: NumberTrainer
    @State private var showResetAlert = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("总练习次数")
                        .foregroundStyle(ListeningCanvasTheme.title)
                    Spacer()
                    Text("\(trainer.lifetimePracticeCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.water)
                        .monospacedDigit()
                }
                .padding(.vertical, 4)
            } header: {
                Text("练习总计")
            } footer: {
                Text("每次点击揭晓答案计数一次，数据会持久保留。")
            }

            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重置计数")
                    }
                }
            } footer: {
                Text("将累计练习次数归零，此操作不可撤销。")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("数据")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认重置", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    trainer.lifetimePracticeCount = 0
                }
            }
        } message: {
            Text("累计练习次数将被清空，此操作不可撤销。")
        }
    }
}
