import AVFoundation
import SwiftUI

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

// MARK: - 语言语音管理器
class LanguageVoiceManager {
    static var currentLanguage: AppLanguage {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.french.rawValue
            return AppLanguage(rawValue: rawValue) ?? .french
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
        }
    }
    
    static var selectedFrenchVoice: FrenchVoice {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "selectedFrenchVoice") ?? FrenchVoice.amelie.rawValue
            return FrenchVoice(rawValue: rawValue) ?? .amelie
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedFrenchVoice")
        }
    }
    
    static var selectedSpanishVoice: SpanishVoice {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "selectedSpanishVoice") ?? SpanishVoice.monica.rawValue
            return SpanishVoice(rawValue: rawValue) ?? .monica
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedSpanishVoice")
        }
    }
    
    static func getCurrentVoice() -> AVSpeechSynthesisVoice? {
        switch currentLanguage {
        case .french:
            return selectedFrenchVoice.getVoice()
        case .spanish:
            return selectedSpanishVoice.getVoice()
        }
    }
    
    static func getTestPhrase() -> String {
        switch currentLanguage {
        case .french:
            return "Bonjour, comment allez-vous?"
        case .spanish:
            return "Hola, ¿cómo estás?"
        }
    }
}

// MARK: - 语言数据提供者协议
protocol LanguageDataProvider {
    var months: [(name: String, days: Int)] { get }
    var trainTypes: [String] { get }
    var airlines: [(code: String, fullName: String)] { get }
    func formatPhonePrefix() -> String
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String)
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String)
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String)
    func sentenceTemplate(for mode: GameMode) -> String

    var successText: String { get }
    var listenText: String { get }
    var nextText: String { get }
    var revealText: String { get }
    var inputPlaceholder: String { get }
    var wrongAnswerPrefix: String { get }
    var appName: String { get }
}

// MARK: - 法语数据提供者
struct FrenchDataProvider: LanguageDataProvider {
    let months: [(name: String, days: Int)] = [
        ("janvier", 31), ("février", 28), ("mars", 31), ("avril", 30),
        ("mai", 31), ("juin", 30), ("juillet", 31), ("août", 31),
        ("septembre", 30), ("octobre", 31), ("novembre", 30), ("décembre", 31)
    ]
    
    let trainTypes = ["TGV", "Intercités", "TER"]
    
    let airlines: [(code: String, fullName: String)] = [
        ("AF", "Air France"),
        ("EK", "Emirates"),
        ("BA", "British Airways"),
        ("LH", "Lufthansa"),
        ("KL", "KLM")
    ]
    
    func formatPhonePrefix() -> String {
        Bool.random() ? "06" : "07"
    }
    
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String) {
        let display = String(format: "%d,%02d €", euro, cent)
        let speakable = cent == 0 ? "\(euro) euros" : "\(euro) euros \(cent)"
        return (display, speakable)
    }
    
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String) {
        let display = String(format: "%02dh%02d", hour, minute)
        let speakable: String
        if minute == 0 {
            speakable = "\(hour) heures pile"
        } else if minute == 30 {
            speakable = "\(hour) heures et demie"
        } else {
            speakable = "\(hour) heures \(minute)"
        }
        return (display, speakable)
    }
    
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String) {
        let display = "le \(day) \(month)"
        let speakable = day == 1 ? "le premier \(month)" : "le \(day) \(month)"
        return (display, speakable)
    }
    
    func sentenceTemplate(for mode: GameMode) -> String {
        let templates: [GameMode: [String]] = [
            .number:       ["Il y a {X} personnes.", "Chambre numéro {X}.", "Le code est le {X}.", "Composez le {X}."],
            .phoneNumber:  ["Appelez le {X}.", "Son numéro est le {X}.", "Enregistrez le {X}."],
            .price:        ["Ça fait {X}, s'il vous plaît.", "Le ticket coûte {X}.", "Votre total est de {X}."],
            .time:         ["Le prochain train part à {X}.", "Le rendez-vous est à {X}.", "Le film commence à {X}."],
            .year:         ["Il est né en {X}.", "Ça s'est passé en {X}.", "Cette œuvre date de {X}."],
            .month:        ["La réunion est prévue {X}.", "Nous partons {X}.", "Le colis arrive {X}."],
            .trainNumber:  ["Votre train est le {X}.", "Prenez le {X}, quai cinq.", "Le {X} est retardé."],
            .flightNumber: ["Votre vol est le {X}.", "L'embarquement du vol {X} commence.", "Le vol {X} est annoncé."],
        ]
        return templates[mode]?.randomElement() ?? "{X}"
    }

    var successText: String { "Correct !" }
    var listenText: String { "Écoutez..." }
    var nextText: String { "Suivant" }
    var revealText: String { "Vérifier" }
    var inputPlaceholder: String { "Tapez ce que vous avez entendu..." }
    var wrongAnswerPrefix: String { "Vous avez tapé :" }
    var appName: String { "Chiffre" }
}

// MARK: - 西班牙语数据提供者
struct SpanishDataProvider: LanguageDataProvider {
    let months: [(name: String, days: Int)] = [
        ("enero", 31), ("febrero", 28), ("marzo", 31), ("abril", 30),
        ("mayo", 31), ("junio", 30), ("julio", 31), ("agosto", 31),
        ("septiembre", 30), ("octubre", 31), ("noviembre", 30), ("diciembre", 31)
    ]
    
    let trainTypes = ["AVE", "Renfe", "Cercanías", "Media Distancia"]
    
    let airlines: [(code: String, fullName: String)] = [
        ("IB", "Iberia"),
        ("UX", "Air Europa"),
        ("VY", "Vueling"),
        ("AF", "Air France"),
        ("LH", "Lufthansa")
    ]
    
    func formatPhonePrefix() -> String {
        ["6", "7"].randomElement()!
    }
    
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String) {
        let display = String(format: "%d,%02d €", euro, cent)
        let speakable: String
        if cent == 0 {
            speakable = "\(euro) euros"
        } else {
            speakable = "\(euro) euros con \(cent) céntimos"
        }
        return (display, speakable)
    }
    
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String) {
        // 24小时制
        let display = String(format: "%02d:%02d", hour, minute)
        let speakable: String
        if minute == 0 {
            speakable = "las \(hour) en punto"
        } else if minute == 30 {
            speakable = "las \(hour) y media"
        } else {
            speakable = "las \(hour) \(minute)"
        }
        return (display, speakable)
    }
    
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String) {
        let display = "el \(day) de \(month)"
        let speakable = day == 1 ? "el primero de \(month)" : "el \(day) de \(month)"
        return (display, speakable)
    }
    
    func sentenceTemplate(for mode: GameMode) -> String {
        let templates: [GameMode: [String]] = [
            .number:       ["Hay {X} personas.", "Habitación número {X}.", "El código es el {X}."],
            .phoneNumber:  ["Llame al {X}.", "Su número es el {X}.", "Anote el {X}."],
            .price:        ["Son {X}, por favor.", "El billete cuesta {X}.", "El total es {X}."],
            .time:         ["El tren sale a las {X}.", "La cita es a las {X}.", "La película empieza a las {X}."],
            .year:         ["Nació en {X}.", "Ocurrió en {X}.", "Esta obra es de {X}."],
            .month:        ["La reunión es {X}.", "Salimos {X}.", "El paquete llega {X}."],
            .trainNumber:  ["Su tren es el {X}.", "Tome el {X} en el andén cinco.", "El {X} lleva retraso."],
            .flightNumber: ["Su vuelo es el {X}.", "El embarque del vuelo {X} ha comenzado.", "Anuncian el vuelo {X}."],
        ]
        return templates[mode]?.randomElement() ?? "{X}"
    }

    var successText: String { "¡Correcto!" }
    var listenText: String { "Escucha..." }
    var nextText: String { "Siguiente" }
    var revealText: String { "Verificar" }
    var inputPlaceholder: String { "Escriba lo que ha escuchado..." }
    var wrongAnswerPrefix: String { "Usted escribió:" }
    var appName: String { "Cifra" }
}
