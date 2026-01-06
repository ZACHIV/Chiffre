import AVFoundation
import SwiftUI

// 法语语音选项
enum FrenchVoice: String, CaseIterable, Identifiable {
    case thomas = "Thomas"           // 男声
    case amelie = "Amélie"           // 女声（推荐）
    
    var id: String { self.rawValue }
    
    // 显示名称（带性别标识）
    var displayName: String {
        switch self {
        case .thomas: return "Thomas (男声)"
        case .amelie: return "Amélie (女声·推荐)"
        }
    }
    
    // 图标
    var icon: String {
        switch self {
        case .thomas: return "person.fill"
        case .amelie: return "person.crop.circle.fill"
        }
    }
    
    // 获取对应的系统语音
    func getVoice() -> AVSpeechSynthesisVoice? {
        // 方法1: 尝试通过名称查找（最可靠）
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // 先尝试精确匹配法语语音
        if let voice = allVoices.first(where: { 
            $0.name == self.rawValue && $0.language.hasPrefix("fr")
        }) {
            return voice
        }
        
        // 如果找不到，尝试只匹配名称
        if let voice = allVoices.first(where: { $0.name == self.rawValue }) {
            return voice
        }
        
        // 最后回退到默认法语语音
        return AVSpeechSynthesisVoice(language: "fr-FR")
    }
}

class SpeechManager: NSObject {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    // 从 UserDefaults 读取选择的语音
    @AppStorage("selectedVoice") private var selectedVoiceRaw: String = FrenchVoice.amelie.rawValue
    
    private var selectedVoice: FrenchVoice {
        FrenchVoice(rawValue: selectedVoiceRaw) ?? .amelie
    }
    
    private override init() {
        super.init()
        // 初始化时不强制占用，等到真正播放时再设置
    }
    
    func speak(_ text: String) {
        // 1. 如果正在发声，先停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 2.【关键修复】每次播放前，强制设置 AudioSession 为播放模式
        // 这会打断 SpeechRecognizer 的录音状态，防止冲突
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        // 3. 配置发音
        let utterance = AVSpeechUtterance(string: text)
        
        // 使用选中的语音
        utterance.voice = selectedVoice.getVoice()
        
        utterance.rate = 0.42
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    // 获取所有可用的法语语音（用于调试）
    static func getAvailableFrenchVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("fr") }
    }
    
    // 打印所有可用的法语语音信息（调试用）
    static func printAvailableFrenchVoices() {
        print("=== 可用的法语语音 ===")
        let voices = getAvailableFrenchVoices()
        for (index, voice) in voices.enumerated() {
            print("[\(index + 1)] \(voice.name)")
            print("    ID: \(voice.identifier)")
            print("    语言: \(voice.language)")
            print("    性别: \(voice.gender.rawValue)")
            print("")
        }
        print("总计: \(voices.count) 个")
    }
}
