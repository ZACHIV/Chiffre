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

    @Published var currentLanguage: AppLanguage {
        didSet { UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage") }
    }
    @Published var selectedFrenchVoice: FrenchVoice {
        didSet { UserDefaults.standard.set(selectedFrenchVoice.rawValue, forKey: "selectedFrenchVoice") }
    }
    @Published var selectedSpanishVoice: SpanishVoice {
        didSet { UserDefaults.standard.set(selectedSpanishVoice.rawValue, forKey: "selectedSpanishVoice") }
    }

    private init() {
        let langRaw = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.french.rawValue
        currentLanguage = AppLanguage(rawValue: langRaw) ?? .french

        let frRaw = UserDefaults.standard.string(forKey: "selectedFrenchVoice") ?? FrenchVoice.amelie.rawValue
        selectedFrenchVoice = FrenchVoice(rawValue: frRaw) ?? .amelie

        let esRaw = UserDefaults.standard.string(forKey: "selectedSpanishVoice") ?? SpanishVoice.monica.rawValue
        selectedSpanishVoice = SpanishVoice(rawValue: esRaw) ?? .monica
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

struct DrillPrompt {
    let sceneTag: String
    let taskTitle: String
    let coachLine: String
    let structureLabel: String
    let structureHint: String
    let focusReplayLabel: String
    let sentenceTemplate: String
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
    func drillPrompt(for mode: GameMode) -> DrillPrompt

    var successText: String { get }
    var listenText: String { get }
    var nextText: String { get }
    var revealText: String { get }
    var inputPlaceholder: String { get }
    var wrongAnswerPrefix: String { get }
    var appName: String { get }
    // 口语练习界面
    var speakTapHint: String { get }
    var speakIdlePrompt: String { get }
    var speakListeningPrompt: String { get }
    var speakCorrectPrompt: String { get }
    var speakWrongPrompt: String { get }
    var showTextLabel: String { get }
    var hideTextLabel: String { get }
    var skipLabel: String { get }
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
    
    func drillPrompt(for mode: GameMode) -> DrillPrompt {
        let prompts: [DrillPrompt]

        switch mode {
        case .number:
            prompts = [
                DrillPrompt(sceneTag: "前台确认", taskTitle: "先抓住房号或编号", coachLine: "这题只需要抓住数字主体，不用试图记住整句里的每个词。", structureLabel: "数字 / 编号", structureHint: "这是一个独立数字，先判断位数，再落每一位。", focusReplayLabel: "只听编号", sentenceTemplate: "Chambre numéro {X}."),
                DrillPrompt(sceneTag: "柜台确认", taskTitle: "先听清关键数字", coachLine: "如果整句太快，先把注意力缩到数字本体。", structureLabel: "数字 / 编号", structureHint: "先确认它不是时间、价格或电话，只是一组数字。", focusReplayLabel: "只听数字", sentenceTemplate: "Le code est le {X}.")
            ]
        case .phoneNumber:
            prompts = [
                DrillPrompt(sceneTag: "电话留言", taskTitle: "抓住回拨号码", coachLine: "不要一口气追整串，先按分组去听。", structureLabel: "电话号码", structureHint: "这是一串电话号码，先抓前缀，再按组补全。", focusReplayLabel: "只听号码", sentenceTemplate: "Appelez le {X}."),
                DrillPrompt(sceneTag: "联系人确认", taskTitle: "把号码分组听稳", coachLine: "数字边界比整句更重要，按组落点会更稳。", structureLabel: "电话号码", structureHint: "先判断这是电话号码，再抓每组的节奏。", focusReplayLabel: "只听电话", sentenceTemplate: "Son numéro est le {X}.")
            ]
        case .price:
            prompts = [
                DrillPrompt(sceneTag: "收银台", taskTitle: "听清总价金额", coachLine: "先抓整数位，再确认小数位，不用被其他礼貌用语干扰。", structureLabel: "价格", structureHint: "这是一个价格，先分开听整数位和小数位。", focusReplayLabel: "只听价格", sentenceTemplate: "Ça fait {X}, s'il vous plaît."),
                DrillPrompt(sceneTag: "餐厅结账", taskTitle: "先锁定金额结构", coachLine: "如果第一次没落住，第二次先只盯住金额片段。", structureLabel: "价格", structureHint: "这题是金额信息，欧元和小数位是两层结构。", focusReplayLabel: "只听金额", sentenceTemplate: "Votre total est de {X}.")
            ]
        case .time:
            prompts = [
                DrillPrompt(sceneTag: "车站广播", taskTitle: "抓住出发时间", coachLine: "先判断小时，再补分钟，不需要完整复述整句。", structureLabel: "24 小时制时间", structureHint: "这是一个 24 小时制时间，重点抓小时和分钟边界。", focusReplayLabel: "只听时间", sentenceTemplate: "Le prochain train part à {X}."),
                DrillPrompt(sceneTag: "预约时间", taskTitle: "听清具体时刻", coachLine: "如果分钟总是糊掉，先把注意力留给后半段。", structureLabel: "24 小时制时间", structureHint: "先判断它是不是时间，再分开听小时和分钟。", focusReplayLabel: "只听时刻", sentenceTemplate: "Le rendez-vous est à {X}.")
            ]
        case .year:
            prompts = [
                DrillPrompt(sceneTag: "年份信息", taskTitle: "先锁定年份框架", coachLine: "年份只要抓住前后两段，不需要逐词记忆句子。", structureLabel: "年份", structureHint: "这是一组年份信息，先抓前两位，再补最后两位。", focusReplayLabel: "只听年份", sentenceTemplate: "Ça s'est passé en {X}."),
                DrillPrompt(sceneTag: "历史讲解", taskTitle: "把年份听完整", coachLine: "年份常常被句子吞掉，先盯住数字，不追整句。", structureLabel: "年份", structureHint: "先把它当成四位年份，而不是普通大数字。", focusReplayLabel: "只听年份", sentenceTemplate: "Cette œuvre date de {X}.")
            ]
        case .month:
            prompts = [
                DrillPrompt(sceneTag: "日程安排", taskTitle: "抓住日期和月份", coachLine: "先判断是日期，再把日和月分开听。", structureLabel: "日期", structureHint: "这是一个日期，先抓日，再确认月份。", focusReplayLabel: "只听日期", sentenceTemplate: "La réunion est prévue {X}."),
                DrillPrompt(sceneTag: "行程提醒", taskTitle: "把日期结构听稳", coachLine: "日期的关键不是整句，而是日和月的连接。", structureLabel: "日期", structureHint: "先确定这是日期表达，再分别听数字和月份。", focusReplayLabel: "只听日期", sentenceTemplate: "Le colis arrive {X}.")
            ]
        case .trainNumber:
            prompts = [
                DrillPrompt(sceneTag: "火车站", taskTitle: "抓住车次编号", coachLine: "先听清车次类型，再补数字主体。", structureLabel: "车次编号", structureHint: "这是一个车次号，先分开听类型和数字。", focusReplayLabel: "只听车次", sentenceTemplate: "Votre train est le {X}."),
                DrillPrompt(sceneTag: "站台广播", taskTitle: "先锁定列车编号", coachLine: "如果整句信息多，先只抓车次这一段。", structureLabel: "车次编号", structureHint: "先判断这是车次信息，再抓数字主体。", focusReplayLabel: "只听编号", sentenceTemplate: "Prenez le {X}, quai cinq.")
            ]
        case .flightNumber:
            prompts = [
                DrillPrompt(sceneTag: "机场登机", taskTitle: "抓住航班号", coachLine: "先分清字母代码，再补数字编号。", structureLabel: "航班号", structureHint: "这是一个航班号，先听字母，再听后面的数字。", focusReplayLabel: "只听航班", sentenceTemplate: "Votre vol est le {X}."),
                DrillPrompt(sceneTag: "值机柜台", taskTitle: "先听稳字母和数字边界", coachLine: "先抓结构边界，别让整句把代码吞掉。", structureLabel: "航班号", structureHint: "先判断前面是字母代码，后面才是数字主体。", focusReplayLabel: "只听代码", sentenceTemplate: "Le vol {X} est annoncé.")
            ]
        }

        return prompts.randomElement() ?? DrillPrompt(sceneTag: "练习", taskTitle: "先听整句，再抓关键信息", coachLine: "把注意力缩到结构化信息上。", structureLabel: "数字信息", structureHint: "先判断结构，再决定怎么写。", focusReplayLabel: "只听数字", sentenceTemplate: "{X}")
    }

    var successText: String { "Correct !" }
    var listenText: String { "Écoutez..." }
    var nextText: String { "Suivant" }
    var revealText: String { "Vérifier" }
    var inputPlaceholder: String { "Tapez ce que vous avez entendu..." }
    var wrongAnswerPrefix: String { "Vous avez tapé :" }
    var appName: String { "Chiffre" }
    var speakTapHint: String { "Toucher pour écouter" }
    var speakIdlePrompt: String { "Appuyez pour parler" }
    var speakListeningPrompt: String { "Je vous écoute..." }
    var speakCorrectPrompt: String { "Parfait !" }
    var speakWrongPrompt: String { "Essayez encore" }
    var showTextLabel: String { "Afficher le texte" }
    var hideTextLabel: String { "Masquer le texte" }
    var skipLabel: String { "Passer" }
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
    
    func drillPrompt(for mode: GameMode) -> DrillPrompt {
        let prompts: [DrillPrompt]

        switch mode {
        case .number:
            prompts = [
                DrillPrompt(sceneTag: "前台确认", taskTitle: "先抓住房号或编号", coachLine: "这题只要抓住数字主体，不需要追整句的所有词。", structureLabel: "数字 / 编号", structureHint: "这是一个独立数字，先判断位数，再补每一位。", focusReplayLabel: "只听编号", sentenceTemplate: "Habitación número {X}."),
                DrillPrompt(sceneTag: "柜台确认", taskTitle: "先听清关键数字", coachLine: "如果整句太快，先把注意力缩到数字本体。", structureLabel: "数字 / 编号", structureHint: "先确认它不是时间或价格，只是一组数字。", focusReplayLabel: "只听数字", sentenceTemplate: "El código es el {X}.")
            ]
        case .phoneNumber:
            prompts = [
                DrillPrompt(sceneTag: "电话留言", taskTitle: "抓住回拨号码", coachLine: "不要试图一次追完整串，先按分组落点。", structureLabel: "电话号码", structureHint: "这是一串电话号码，先抓前缀，再按组补全。", focusReplayLabel: "只听号码", sentenceTemplate: "Llame al {X}."),
                DrillPrompt(sceneTag: "联系人确认", taskTitle: "把号码分组听稳", coachLine: "数字边界比整句更重要，按组去听会更稳。", structureLabel: "电话号码", structureHint: "先判断这是电话号码，再抓每组的节奏。", focusReplayLabel: "只听电话", sentenceTemplate: "Su número es el {X}.")
            ]
        case .price:
            prompts = [
                DrillPrompt(sceneTag: "收银台", taskTitle: "听清总价金额", coachLine: "先抓整数位，再确认小数位，不用被其他词带跑。", structureLabel: "价格", structureHint: "这是一个价格，先分开听整数位和小数位。", focusReplayLabel: "只听价格", sentenceTemplate: "Son {X}, por favor."),
                DrillPrompt(sceneTag: "餐厅结账", taskTitle: "先锁定金额结构", coachLine: "如果第一次没落住，第二次只盯金额那一段。", structureLabel: "价格", structureHint: "这题是金额信息，欧元和小数位是两层结构。", focusReplayLabel: "只听金额", sentenceTemplate: "El total es {X}.")
            ]
        case .time:
            prompts = [
                DrillPrompt(sceneTag: "车站广播", taskTitle: "抓住出发时间", coachLine: "先判断小时，再补分钟，不需要完整复述整句。", structureLabel: "24 小时制时间", structureHint: "这是一个时间，重点抓小时和分钟边界。", focusReplayLabel: "只听时间", sentenceTemplate: "El tren sale a las {X}."),
                DrillPrompt(sceneTag: "预约时间", taskTitle: "听清具体时刻", coachLine: "如果分钟总是糊掉，第二次就只抓后半段。", structureLabel: "24 小时制时间", structureHint: "先判断它是不是时间，再分开听小时和分钟。", focusReplayLabel: "只听时刻", sentenceTemplate: "La cita es a las {X}.")
            ]
        case .year:
            prompts = [
                DrillPrompt(sceneTag: "年份信息", taskTitle: "先锁定年份框架", coachLine: "年份只要抓住前后两段，不需要逐词记忆句子。", structureLabel: "年份", structureHint: "这是一组年份信息，先抓前两位，再补最后两位。", focusReplayLabel: "只听年份", sentenceTemplate: "Ocurrió en {X}."),
                DrillPrompt(sceneTag: "历史讲解", taskTitle: "把年份听完整", coachLine: "年份常常被句子吞掉，先盯住数字本体。", structureLabel: "年份", structureHint: "先把它当成四位年份，而不是普通大数字。", focusReplayLabel: "只听年份", sentenceTemplate: "Esta obra es de {X}.")
            ]
        case .month:
            prompts = [
                DrillPrompt(sceneTag: "日程安排", taskTitle: "抓住日期和月份", coachLine: "先判断是日期，再把日和月分开听。", structureLabel: "日期", structureHint: "这是一个日期，先抓日，再确认月份。", focusReplayLabel: "只听日期", sentenceTemplate: "La reunión es {X}."),
                DrillPrompt(sceneTag: "行程提醒", taskTitle: "把日期结构听稳", coachLine: "日期的关键不是整句，而是日和月的连接。", structureLabel: "日期", structureHint: "先确定这是日期表达，再分别听数字和月份。", focusReplayLabel: "只听日期", sentenceTemplate: "El paquete llega {X}.")
            ]
        case .trainNumber:
            prompts = [
                DrillPrompt(sceneTag: "火车站", taskTitle: "抓住车次编号", coachLine: "先听清车次类型，再补数字主体。", structureLabel: "车次编号", structureHint: "这是一个车次号，先分开听类型和数字。", focusReplayLabel: "只听车次", sentenceTemplate: "Su tren es el {X}."),
                DrillPrompt(sceneTag: "站台广播", taskTitle: "先锁定列车编号", coachLine: "如果整句信息多，先只抓车次这一段。", structureLabel: "车次编号", structureHint: "先判断这是车次信息，再抓数字主体。", focusReplayLabel: "只听编号", sentenceTemplate: "Tome el {X} en el andén cinco.")
            ]
        case .flightNumber:
            prompts = [
                DrillPrompt(sceneTag: "机场登机", taskTitle: "抓住航班号", coachLine: "先分清字母代码，再补数字编号。", structureLabel: "航班号", structureHint: "这是一个航班号，先听字母，再听后面的数字。", focusReplayLabel: "只听航班", sentenceTemplate: "Su vuelo es el {X}."),
                DrillPrompt(sceneTag: "值机柜台", taskTitle: "先听稳字母和数字边界", coachLine: "先抓结构边界，别让整句把代码吞掉。", structureLabel: "航班号", structureHint: "先判断前面是字母代码，后面才是数字主体。", focusReplayLabel: "只听代码", sentenceTemplate: "Anuncian el vuelo {X}.")
            ]
        }

        return prompts.randomElement() ?? DrillPrompt(sceneTag: "练习", taskTitle: "先听整句，再抓关键信息", coachLine: "把注意力缩到结构化信息上。", structureLabel: "数字信息", structureHint: "先判断结构，再决定怎么写。", focusReplayLabel: "只听数字", sentenceTemplate: "{X}")
    }

    var successText: String { "¡Correcto!" }
    var listenText: String { "Escucha..." }
    var nextText: String { "Siguiente" }
    var revealText: String { "Verificar" }
    var inputPlaceholder: String { "Escriba lo que ha escuchado..." }
    var wrongAnswerPrefix: String { "Usted escribió:" }
    var appName: String { "Cifra" }
    var speakTapHint: String { "Toca para escuchar" }
    var speakIdlePrompt: String { "Pulsa para hablar" }
    var speakListeningPrompt: String { "Te escucho..." }
    var speakCorrectPrompt: String { "¡Perfecto!" }
    var speakWrongPrompt: String { "Inténtalo de nuevo" }
    var showTextLabel: String { "Mostrar texto" }
    var hideTextLabel: String { "Ocultar texto" }
    var skipLabel: String { "Saltar" }
}
