import AVFoundation
import SwiftUI
import Combine

// MARK: - 支持的语言
enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case spanish = "es"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .french: return "Français"
        case .spanish: return "Español"
        }
    }
    
    var localeIdentifier: String {
        switch self {
        case .french: return "fr-FR"
        case .spanish: return "es-ES"
        }
    }
    
    var icon: String {
        switch self {
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        }
    }
}

// MARK: - 语音选项协议
protocol LanguageVoice {
    var displayName: String { get }
    var icon: String { get }
}

// MARK: - 法语语音
enum FrenchVoice: String, CaseIterable, Identifiable, LanguageVoice {
    case thomas = "Thomas"
    case amelie = "Amélie"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .thomas: return "Thomas (男声)"
        case .amelie: return "Amélie (女声·推荐)"
        }
    }
    
    var icon: String {
        switch self {
        case .thomas: return "person.fill"
        case .amelie: return "person.crop.circle.fill"
        }
    }
    
    func getVoice() -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        if let voice = allVoices.first(where: {
            $0.name == self.rawValue && $0.language.hasPrefix("fr")
        }) {
            return voice
        }
        
        if let voice = allVoices.first(where: { $0.name == self.rawValue }) {
            return voice
        }
        
        return AVSpeechSynthesisVoice(language: "fr-FR")
    }
}

// MARK: - 西班牙语语音
enum SpanishVoice: String, CaseIterable, Identifiable, LanguageVoice {
    case monica = "Monica"
    case diego = "Diego"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .monica: return "Monica (女声·推荐)"
        case .diego: return "Diego (男声)"
        }
    }
    
    var icon: String {
        switch self {
        case .monica: return "person.crop.circle.fill"
        case .diego: return "person.fill"
        }
    }
    
    func getVoice() -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        if let voice = allVoices.first(where: {
            $0.name == self.rawValue && $0.language.hasPrefix("es")
        }) {
            return voice
        }
        
        if let voice = allVoices.first(where: { $0.name == self.rawValue }) {
            return voice
        }
        
        return AVSpeechSynthesisVoice(language: "es-ES")
    }
}

// MARK: - 语言语音管理器 (ObservableObject 单例，确保语言切换即时刷新所有视图)
class LanguageVoiceManager: ObservableObject {
    static let shared = LanguageVoiceManager()
    private let settingsStore: VoiceSettingsStore

    @Published var currentLanguage: AppLanguage {
        didSet { settingsStore.save(language: currentLanguage) }
    }
    @Published var selectedFrenchVoice: FrenchVoice {
        didSet { settingsStore.save(frenchVoice: selectedFrenchVoice) }
    }
    @Published var selectedSpanishVoice: SpanishVoice {
        didSet { settingsStore.save(spanishVoice: selectedSpanishVoice) }
    }

    private init(settingsStore: VoiceSettingsStore = VoiceSettingsStore()) {
        self.settingsStore = settingsStore
        currentLanguage = settingsStore.loadLanguage()
        selectedFrenchVoice = settingsStore.loadFrenchVoice()
        selectedSpanishVoice = settingsStore.loadSpanishVoice()
    }

    func getCurrentVoice() -> AVSpeechSynthesisVoice? {
        switch currentLanguage {
        case .french:  return selectedFrenchVoice.getVoice()
        case .spanish: return selectedSpanishVoice.getVoice()
        }
    }

    func getTestPhrase() -> String {
        switch currentLanguage {
        case .french:  return "Bonjour, comment allez-vous?"
        case .spanish: return "Hola, ¿cómo estás?"
        }
    }
}
