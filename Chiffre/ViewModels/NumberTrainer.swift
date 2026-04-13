import SwiftUI
import Combine

// MARK: - 游戏模式
enum GameMode: String, CaseIterable, Identifiable {
    case number      = "Chiffres (数字)"
    case phoneNumber = "Tél (电话)"
    case price       = "Prix (价格)"
    case time        = "Heure (时间)"
    case year        = "Année (年份)"
    case month       = "Mois (月份)"
    case trainNumber = "Train (火车号)"
    case flightNumber = "Vol (航班号)"
    case address     = "Adresse (地址)"
    case reservation = "Réservation (预约)"
    case cafeOrder   = "Commande (点单)"
    case directions  = "Trajet (问路)"
    case smallTalk   = "Conversation (寒暄)"
    case service     = "Service (生活)"
    case shopping    = "Courses (购物)"
    case transport   = "Transports (出行)"
    case health      = "Santé (健康)"
    case workday     = "Travail (工作)"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .number:       return "number"
        case .phoneNumber:  return "phone.fill"
        case .price:        return "eurosign.circle.fill"
        case .time:         return "clock.fill"
        case .year:         return "calendar"
        case .month:        return "calendar.circle.fill"
        case .trainNumber:  return "tram.fill"
        case .flightNumber: return "airplane"
        case .address:      return "map.fill"
        case .reservation:  return "bookmark.circle.fill"
        case .cafeOrder:    return "cup.and.saucer.fill"
        case .directions:   return "location.north.line.fill"
        case .smallTalk:    return "message.fill"
        case .service:      return "bell.badge.fill"
        case .shopping:     return "bag.fill"
        case .transport:    return "bus.fill"
        case .health:       return "cross.case.fill"
        case .workday:      return "briefcase.fill"
        }
    }

    var summary: String {
        switch self {
        case .number:
            return "基础数字与口头报数"
        case .phoneNumber:
            return "联系电话与号码分组"
        case .price:
            return "价格、金额与付款表达"
        case .time:
            return "时间、约会与开门时段"
        case .year:
            return "年份、年代与历史时间点"
        case .month:
            return "日期、月份与日程安排"
        case .trainNumber:
            return "列车编号与站台广播"
        case .flightNumber:
            return "航班号与登机广播"
        case .address:
            return "门牌、楼层与地址信息"
        case .reservation:
            return "订位、人数与预约时间"
        case .cafeOrder:
            return "咖啡馆点单与日常购买"
        case .directions:
            return "问路、转弯与距离表达"
        case .smallTalk:
            return "寒暄、近况与轻社交"
        case .service:
            return "药店、商店与生活服务"
        case .shopping:
            return "超市、尺码与结账对话"
        case .transport:
            return "地铁、公交与出租出行"
        case .health:
            return "症状、药品与就诊沟通"
        case .workday:
            return "会议、同事与工作安排"
        }
    }

    var isRangeConfigurable: Bool {
        self == .number
    }

    var isScenarioBased: Bool {
        switch self {
        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            return true
        default:
            return false
        }
    }
}

struct ListeningScenario {
    let display: String
    let speakable: String
    let sentence: String
    let annotation: String
}

// MARK: - 答题状态
enum AnswerState: Equatable {
    case waiting   // 等待用户输入
    case revealed  // 直接查看答案（未输入，不计分）
    case correct   // 验证正确
    case wrong     // 验证错误
}

// MARK: - 渐进提示阶段（P1）
enum HintStage: Int {
    case none
    case replayFull
    case replayFocused
    case structure
    case scaffold
    case partialReveal
    case fullReveal
}

// MARK: - 核心 ViewModel
class NumberTrainer: ObservableObject {
    @Published var currentDisplay: String = ""
    @Published var userInput: String = ""
    @Published var answerState: AnswerState = .waiting
    @Published var hintStage: HintStage = .none
    @Published var hintMessage: String = ""
    @Published var hintVisual: String = ""
    @Published var revealedHintDigits: Int = 0

    // 会话统计（P1: 错误跟踪）
    @Published var sessionCorrect: Int = 0
    @Published var sessionTotal: Int = 0
    @Published var currentStreak: Int = 0

    @AppStorage("gameMode") var mode: GameMode = .number
    @AppStorage("maxRange") var maxRange: Int = 100
    @AppStorage("listeningPlaybackRate") var playbackRate: Double = 0.56

    private(set) var speakableContent: String = ""
    private(set) var sentenceContext: String = ""
    private(set) var displayAnnotation: String = ""

    private var cancellables = Set<AnyCancellable>()

    var dataProvider: LanguageDataProvider {
        switch LanguageVoiceManager.shared.currentLanguage {
        case .french:  return FrenchDataProvider()
        case .spanish: return SpanishDataProvider()
        }
    }

    var currentRate: Float {
        Float(playbackRate)
    }

    var speedLevel: Int {
        switch playbackRate {
        case ..<0.45: return 1
        case ..<0.53: return 2
        case ..<0.61: return 3
        default: return 4
        }
    }

    var speedLabel: String {
        switch playbackRate {
        case ..<0.45: return "慢速"
        case ..<0.53: return "适中"
        case ..<0.61: return "较快"
        default: return "自然"
        }
    }

    var canVerify: Bool {
        !userInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var hasHintContent: Bool {
        !hintMessage.isEmpty || !hintVisual.isEmpty
    }

    var structureHintText: String {
        dataProvider.structureHint(for: mode)
    }

    var revealAnnotation: String {
        if !displayAnnotation.isEmpty {
            return displayAnnotation
        }

        if let spelled = spelledOutDisplay {
            return spelled
        }

        return speakableContent
            .replacingOccurrences(of: ",", with: " ·")
            .replacingOccurrences(of: "  ", with: " ")
    }

    var hintActionText: String {
        "提示一位"
    }

    // 给 SettingsSheet 中的键盘类型提示
    var preferredKeyboardType: UIKeyboardType {
        switch mode {
        case .number, .year: return .numberPad
        case .price:         return .decimalPad
        default:             return .default
        }
    }

    init() {
        generateNew(speakNow: false)

        // 语言切换时自动刷新题目
        LanguageVoiceManager.shared.$currentLanguage
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.generateNew(speakNow: false)
            }
            .store(in: &cancellables)
    }

    // MARK: - 生成新题目
    func generateNew(speakNow: Bool = true) {
        withAnimation(.spring()) {
            answerState = .waiting
            userInput = ""
            hintStage = .none
            hintMessage = ""
            hintVisual = ""
            revealedHintDigits = 0
            currentDisplay = ""
            speakableContent = ""
            sentenceContext = ""
            displayAnnotation = ""
            let provider = dataProvider

            switch mode {
            case .number:
                let num = Int.random(in: 0...maxRange)
                currentDisplay = "\(num)"
                speakableContent = "\(num)"

            case .phoneNumber:
                let prefix = provider.formatPhonePrefix()
                let parts = (0..<4).map { _ in String(format: "%02d", Int.random(in: 0...99)) }
                currentDisplay = "\(prefix) \(parts.joined(separator: " "))"
                speakableContent = "\(prefix), \(parts.joined(separator: ", "))"

            case .price:
                let euro = Int.random(in: 1...100)
                let cent = Int.random(in: 0...99)
                let formatted = provider.formatPrice(euro: euro, cent: cent)
                currentDisplay = formatted.display
                speakableContent = formatted.speakable

            case .time:
                let hour = Int.random(in: 0...23)
                let minute = Int.random(in: 0...59)
                let formatted = provider.formatTime(hour: hour, minute: minute)
                currentDisplay = formatted.display
                speakableContent = formatted.speakable

            case .year:
                let year = Int.random(in: 1950...2030)
                currentDisplay = "\(year)"
                speakableContent = "\(year)"

            case .month:
                let monthData = provider.months.randomElement()!
                let day = Int.random(in: 1...monthData.days)
                let formatted = provider.formatMonth(day: day, month: monthData.name)
                currentDisplay = formatted.display
                speakableContent = formatted.speakable

            case .trainNumber:
                let trainType = provider.trainTypes.randomElement()!
                let number = Int.random(in: 1000...9999)
                currentDisplay = "\(trainType) \(number)"
                speakableContent = "\(trainType), \(number)"

            case .flightNumber:
                let airline = provider.airlines.randomElement()!
                let flightNum = Int.random(in: 10...9999)
                currentDisplay = "\(airline.0) \(flightNum)"
                let code = airline.0.map { String($0) }.joined(separator: ", ")
                speakableContent = "\(code), \(flightNum)"

            case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
                if let scenario = provider.scenarioPrompt(for: mode) {
                    currentDisplay = scenario.display
                    speakableContent = scenario.speakable
                    sentenceContext = scenario.sentence
                    displayAnnotation = scenario.annotation
                    break
                }
                currentDisplay = ""
                speakableContent = ""
                sentenceContext = ""
            }

            if sentenceContext.isEmpty {
                let template = provider.sentenceTemplate(for: mode)
                sentenceContext = template.replacingOccurrences(of: "{X}", with: speakableContent)
            }
        }

        if speakNow {
            replayFull()
        }
    }

    // MARK: - 分层重放（P0）
    func replay() {
        replayFull()
    }

    func replayFull() {
        SpeechManager.shared.speak(sentenceContext, rate: currentRate)
    }

    func replayFocused() {
        SpeechManager.shared.speak(speakableContent, rate: currentRate)
    }

    func replaySlow() {
        let slowRate = max(0.36, currentRate - 0.1)
        SpeechManager.shared.speak(sentenceContext, rate: slowRate)
    }

    // MARK: - 渐进提示（P1）
    func requestHint() {
        guard answerState == .waiting else { return }
        let totalDigits = currentDisplay.filter(\.isNumber).count
        guard totalDigits > 0 else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            revealedHintDigits = min(totalDigits, revealedHintDigits + 1)
            hintStage = revealedHintDigits >= totalDigits ? .fullReveal : .partialReveal
            hintMessage = "已显示 \(revealedHintDigits) 位数字"
            hintVisual = buildDigitRevealHint()
        }
    }

    // MARK: - 验证答案
    func verify() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            answerState = .revealed
        }

        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    // MARK: - 答案比对（宽松匹配）
    private func checkAnswer(_ input: String, against target: String) -> Bool {
        let normInput  = normalize(input)
        let normTarget = normalize(target)
        if normInput == normTarget { return true }
        // 去空格比较（兼容电话号码、航班号不同分隔习惯）
        let strip = { (s: String) in s.replacingOccurrences(of: " ", with: "") }
        return strip(normInput) == strip(normTarget)
    }

    private func normalize(_ s: String) -> String {
        var r = s.lowercased().trimmingCharacters(in: .whitespaces)

        // 去冠词
        for prefix in ["le ", "la ", "el "] {
            if r.hasPrefix(prefix) { r = String(r.dropFirst(prefix.count)); break }
        }

        // 去货币符号
        r = r.replacingOccurrences(of: "€", with: "")
        r = r.replacingOccurrences(of: "$", with: "")

        // 小数点统一
        r = r.replacingOccurrences(of: ",", with: ".")

        // 时间格式：14h30 → 14:30（仅替换数字间的 h）
        r = r.replacingOccurrences(of: "(\\d)h(\\d)", with: "$1:$2", options: .regularExpression)

        // 西班牙语日期连词：15 de enero → 15 enero
        r = r.replacingOccurrences(of: " de ", with: " ")

        // 合并多余空格
        r = r.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")

        return r
    }

    private func buildDigitRevealHint() -> String {
        var visibleDigits = revealedHintDigits
        return String(currentDisplay.map { char in
            guard char.isNumber else { return char }
            if visibleDigits > 0 {
                visibleDigits -= 1
                return char
            }
            return "•"
        })
    }

    private var spelledOutDisplay: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: LanguageVoiceManager.shared.currentLanguage.localeIdentifier)

        switch mode {
        case .number, .year:
            guard let value = Int(currentDisplay) else { return nil }
            return formatter.string(from: NSNumber(value: value))
        default:
            return nil
        }
    }

    // MARK: - 视觉支架
    private func buildScaffold() -> String {
        switch mode {
        case .number:
            return String(repeating: "_", count: max(2, currentDisplay.filter { $0.isNumber }.count))

        case .phoneNumber:
            let segments = currentDisplay.split(separator: " ")
            guard let prefix = segments.first else { return "__ __ __ __ __" }
            return "\(prefix) __ __ __ __"

        case .price:
            return "__,__ €"

        case .time:
            if currentDisplay.contains("h") { return "__h__" }
            return "__:__"

        case .year:
            return "____"

        case .month:
            let parts = currentDisplay.split(separator: " ")
            if let last = parts.last {
                return "__ \(last)"
            }
            return "__ ____"

        case .trainNumber, .flightNumber:
            let segments = currentDisplay.split(separator: " ")
            guard let prefix = segments.first else { return "____" }
            return "\(prefix) ____"

        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            return "先听关键词，再听整句。"
        }
    }

    private func buildPartialReveal() -> String {
        switch mode {
        case .number:
            return maskDigits(in: currentDisplay, visibleCount: max(1, currentDisplay.filter { $0.isNumber }.count / 2))

        case .phoneNumber:
            let segments = currentDisplay.split(separator: " ")
            if segments.count >= 2 {
                return "\(segments[0]) \(segments[1]) __ __ __"
            }
            return currentDisplay

        case .price:
            let parts = currentDisplay.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
            if let integerPart = parts.first {
                return "\(integerPart),__ €"
            }
            return "__,__ €"

        case .time:
            if let hIndex = currentDisplay.firstIndex(of: "h") {
                let hour = String(currentDisplay[..<hIndex])
                return "\(hour)h__"
            }
            if let cIndex = currentDisplay.firstIndex(of: ":") {
                let hour = String(currentDisplay[..<cIndex])
                return "\(hour):__"
            }
            return "__:__"

        case .year:
            return maskDigits(in: currentDisplay, visibleCount: 2)

        case .month:
            let parts = currentDisplay.split(separator: " ")
            if parts.count >= 3 {
                return "\(parts[0]) \(parts[1]) ____"
            }
            if parts.count == 2 {
                return "\(parts[0]) ____"
            }
            return currentDisplay

        case .trainNumber, .flightNumber:
            let segments = currentDisplay.split(separator: " ")
            guard segments.count >= 2 else { return currentDisplay }
            let prefix = String(segments[0])
            let number = String(segments[1])
            let visible = max(1, min(2, number.filter { $0.isNumber }.count - 1))
            return "\(prefix) \(maskDigits(in: number, visibleCount: visible))"

        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            let words = currentDisplay.split(separator: " ")
            let visibleWords = words.prefix(2).joined(separator: " ")
            return words.count > 2 ? "\(visibleWords) ..." : visibleWords
        }
    }

    private func maskDigits(in text: String, visibleCount: Int) -> String {
        var visible = visibleCount
        return String(text.map { char in
            guard char.isNumber else { return char }
            if visible > 0 {
                visible -= 1
                return char
            }
            return "_"
        })
    }
}
