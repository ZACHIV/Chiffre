//
//  SpeechManager.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
//


import AVFoundation

class SpeechManager: NSObject {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    private override init() {
        super.init()
        // 配置音频会话，确保静音模式下也能播放
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func speak(_ number: Int) {
        // 防止重叠播放
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: "\(number)")
        // 关键：指定法语
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = 0.45 // 稍慢语速，适合听力训练
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
}