import AVFoundation
import SwiftUI

class SpeechManager: NSObject {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
    }
    
    func speak(_ text: String) {
        // 1. 如果正在发声，先停止
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 2.【关键修复】每次播放前，强制设置 AudioSession 为播放模式
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        // 3. 配置发音
        let utterance = AVSpeechUtterance(string: text)
        
        // 使用 LanguageVoiceManager 获取当前语音
        utterance.voice = LanguageVoiceManager.getCurrentVoice()
        
        utterance.rate = 0.42
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
}
