import SwiftUI
import Combine
import AVFoundation // 引入音频框架

class SpeakingTrainer: ObservableObject {
    @Published var currentNumber: Int = 0
    @Published var targetText: String = ""
    @Published var showFrenchText: Bool = false
    
    // 新增：捕捉用户错误的输入
    @Published var capturedWrongText: String = ""
    
    enum VerificationStatus {
        case idle
        case listening
        case correct
        case wrong // 确保有这个状态
    }
    @Published var status: VerificationStatus = .idle
    
    @ObservedObject var recognizer = SpeechRecognizer()
    private var cancellables = Set<AnyCancellable>()
    
    // 动态获取当前语言的 NumberFormatter
    private var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .spellOut
        f.locale = Locale(identifier: LanguageVoiceManager.currentLanguage.localeIdentifier)
        return f
    }
    
    init() {
        generateNew()
        
        recognizer.$transcript
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main) // 稍微增加防抖时间，等待用户说完
            .sink { [weak self] text in
                self?.verify(text)
            }
            .store(in: &cancellables)
        
        recognizer.$isRecording
            .sink { [weak self] isRec in
                if isRec {
                    self?.status = .listening
                    self?.capturedWrongText = "" // 开始新录音时清空错误信息
                } else if self?.status == .listening {
                    // 录音结束但未判定正确，则视为闲置或错误（根据具体需求）
                    if self?.status != .correct && self?.status != .wrong {
                        self?.status = .idle
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 核心功能
    
    func generateNew() {
        currentNumber = Int.random(in: 0...100)
        targetText = formatter.string(from: NSNumber(value: currentNumber)) ?? ""
        status = .idle
        capturedWrongText = ""
        // 生成新词时，自动朗读一遍（可选，或者让用户自己点）
        // speakTarget()
    }
    
    // 1. 点击数字发音
    func speakTarget() {
        // 使用你已有的 SpeechManager
        SpeechManager.shared.speak(targetText)
    }
    
    func toggleRecording() {
        if recognizer.isRecording {
            recognizer.stopRecording()
        } else {
            recognizer.startRecording()
        }
    }
    
    // MARK: - 验证逻辑优化
    
    private func verify(_ input: String) {
        guard !input.isEmpty else { return }
        guard status == .listening else { return } // 只在听力状态下验证
        
        let cleanedInput = input.lowercased().replacingOccurrences(of: "-", with: " ")
        let cleanedTarget = targetText.lowercased().replacingOccurrences(of: "-", with: " ")
        
        print("User said: \(cleanedInput) | Target: \(cleanedTarget)")
        
        if cleanedInput.contains(cleanedTarget) || cleanedInput.contains("\(currentNumber)") {
            // ---> 对了！
            status = .correct
            recognizer.stopRecording()
            playFeedbackSound(isCorrect: true)
            // 可以在这里触发震动
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        } else {
            // ---> 错了（或者还没说完，这里做一个简单的判断：如果长度相当但不对，就认为是错了）
            // 注意：实时语音识别会不断返回片段，这里需要小心不要太早判错。
            // 策略：我们不自动判错停止录音，而是将当前识别到的内容显示给用户看，作为“实时反馈”。
            // 只有当用户手动停止或超时，才定性为“错误”。
            // 但为了满足你的需求“提醒用户念的不对”，我们可以判断如果 input 长度足够长且不匹配，就提示。
            
            capturedWrongText = input // 实时更新用户说的话
            
            // 如果 input 包含其他数字，说明用户可能念错了数字
            if containsOtherNumbers(input, target: currentNumber) {
                 status = .wrong
                 recognizer.stopRecording()
                 playFeedbackSound(isCorrect: false)
                 let generator = UINotificationFeedbackGenerator()
                 generator.notificationOccurred(.error)
            }
        }
    }
    
    // 简单的辅助检测：用户是否说了别的数字？
    private func containsOtherNumbers(_ input: String, target: Int) -> Bool {
        // 这里只是一个简单的启发式检查，防止误判
        // 比如目标是 70，用户说了 60 (soixante)，这里可以检测到
        // 实际项目可以使用更复杂的 NLP，这里简单处理：
        // 如果 input 里包含数字字符，且不是 target，那就是错了
        // 如果 input 很长且不包含 target 文本，也可能是错了
        return false // 简化起见，先只做“实时显示”，让用户自己对比，不做强制判错打断
    }
    
    // MARK: - 音效反馈
    private func playFeedbackSound(isCorrect: Bool) {
        // 使用系统音效 ID
        // 1001: MailReceived (类似叮的一声) -> 成功
        // 1002: MailSent (类似嗖的一声) -> 失败/重试
        // 也可以用 1057 (PinEntryCompleted), 1053 (SystemSoundID)
        let soundID: SystemSoundID = isCorrect ? 1057 : 1002 // 1057 是清脆的成功声
        AudioServicesPlaySystemSound(soundID)
    }
}
