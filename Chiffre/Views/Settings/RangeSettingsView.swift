import SwiftUI

struct RangeSettingsView: View {
    @ObservedObject var trainer: NumberTrainer

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("当前范围")
                            .foregroundStyle(ListeningCanvasTheme.secondary)
                        Spacer()
                        Text("0 - \(trainer.maxRange)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.title)
                            .monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(trainer.maxRange) },
                            set: { trainer.maxRange = Int($0) }
                        ),
                        in: 10...9999,
                        step: 10
                    )
                    .tint(ListeningCanvasTheme.water)
                }
                .padding(.vertical, 6)
            } footer: {
                Text("仅在数字模式下生效，方便控制训练难度。")
            }

            Section("快捷范围") {
                RangePresetButton(label: "简单", value: 10, trainer: trainer)
                RangePresetButton(label: "中等", value: 100, trainer: trainer)
                RangePresetButton(label: "困难", value: 1000, trainer: trainer)
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("数字范围")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RangePresetButton: View {
    let label: String
    let value: Int
    @ObservedObject var trainer: NumberTrainer

    var isSelected: Bool { trainer.maxRange == value }

    var body: some View {
        Button {
            trainer.maxRange = value
            trainer.generateNew(speakNow: false)
        } label: {
            HStack {
                Text(label)
                    .foregroundStyle(ListeningCanvasTheme.title)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ListeningCanvasTheme.water)
                } else {
                    Text("\(value)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                        .monospacedDigit()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
