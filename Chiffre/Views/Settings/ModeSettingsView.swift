import SwiftUI

struct ModeSettingsView: View {
    @ObservedObject var trainer: NumberTrainer

    private let numberModes: [GameMode] = [
        .number, .phoneNumber, .price, .time, .year, .month
    ]
    private let travelModes: [GameMode] = [
        .trainNumber, .flightNumber, .address, .directions, .transport
    ]
    private let lifeModes: [GameMode] = [
        .reservation, .cafeOrder, .smallTalk, .service, .shopping, .health, .workday
    ]

    var body: some View {
        Form {
            Section("数字类") {
                modeRows(for: numberModes)
            }

            Section("交通出行") {
                modeRows(for: travelModes)
            }

            Section("日常生活") {
                modeRows(for: lifeModes)
            }
        }
        .scrollContentBackground(.hidden)
        .background(ListeningCanvasTheme.background)
        .navigationTitle("类别")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func modeRows(for modes: [GameMode]) -> some View {
        ForEach(modes) { mode in
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    trainer.mode = mode
                }
                trainer.generateNew(speakNow: false)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ListeningCanvasTheme.secondary)
                        .frame(width: 24)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.rawValue)
                            .foregroundStyle(ListeningCanvasTheme.title)
                        Text(mode.summary)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(ListeningCanvasTheme.secondary)
                    }

                    Spacer()

                    if trainer.mode == mode {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(ListeningCanvasTheme.water)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(trainer.mode == mode ? .isSelected : [])
        }
    }
}
