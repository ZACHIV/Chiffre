import Foundation

protocol SpeechPlaying {
    func speak(_ text: String, rate: Float)
}

extension SpeechManager: SpeechPlaying {}
