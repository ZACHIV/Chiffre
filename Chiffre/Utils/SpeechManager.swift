import AVFoundation
import SwiftUI

class SpeechManager: NSObject {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
    }

    func speak(_ text: String, rate: Float = 0.42) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = LanguageVoiceManager.getCurrentVoice()
        utterance.rate = rate
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }
}
