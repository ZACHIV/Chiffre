import Foundation

final class VoiceSettingsStore {
    private enum Key {
        static let appLanguage = "appLanguage"
        static let selectedFrenchVoice = "selectedFrenchVoice"
        static let selectedSpanishVoice = "selectedSpanishVoice"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadLanguage() -> AppLanguage {
        let rawValue = userDefaults.string(forKey: Key.appLanguage) ?? AppLanguage.french.rawValue
        return AppLanguage(rawValue: rawValue) ?? .french
    }

    func save(language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: Key.appLanguage)
    }

    func loadFrenchVoice() -> FrenchVoice {
        let rawValue = userDefaults.string(forKey: Key.selectedFrenchVoice) ?? FrenchVoice.amelie.rawValue
        return FrenchVoice(rawValue: rawValue) ?? .amelie
    }

    func save(frenchVoice: FrenchVoice) {
        userDefaults.set(frenchVoice.rawValue, forKey: Key.selectedFrenchVoice)
    }

    func loadSpanishVoice() -> SpanishVoice {
        let rawValue = userDefaults.string(forKey: Key.selectedSpanishVoice) ?? SpanishVoice.monica.rawValue
        return SpanishVoice(rawValue: rawValue) ?? .monica
    }

    func save(spanishVoice: SpanishVoice) {
        userDefaults.set(spanishVoice.rawValue, forKey: Key.selectedSpanishVoice)
    }
}
