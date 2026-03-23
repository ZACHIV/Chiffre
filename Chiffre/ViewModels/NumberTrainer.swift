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

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .number:       return "number.square.fill"
        case .phoneNumber:  return "phone.fill"
        case .price:        return "eurosign.circle.fill"
        case .time:         return "clock.fill"
        case .year:         return "calendar"
        case .month:        return "calendar.circle.fill"
        case .trainNumber:  return "tram.fill"
        case .flightNumber: return "airplane"
        }
    }
}

// MARK: - 答题状态
enum AnswerState: Equatable {
    case waiting   // 等待用户输入
    case revealed  // 直接查看答案（未输入，不计分）
    case correct   // 验证正确
    case wrong     // 验证错误
}

// MARK: - 核心 ViewModel
class NumberTrainer: ObservableObject {
    @Published var currentDisplay: String = ""
    @Published var userInput: String = ""
    @Published var answerState: AnswerState = .waiting

    // 会话统计（P1: 错误跟踪）
    @Published var sessionCorrect: Int = 0
    @Published var sessionTotal: Int = 0
    @Published var currentStreak: Int = 0

    @AppStorage("gameMode") var mode: GameMode = .number
    @AppStorage("maxRange") var maxRange: Int = 100

    private(set) var speakableContent: String = ""
    private(set) var sentenceContext: String = ""

    private var cancellables = Set<AnyCancellable>()

    var dataProvider: LanguageDataProvider {
        switch LanguageVoiceManager.shared.currentLanguage {
        case .french:  return FrenchDataProvider()
        case .spanish: return SpanishDataProvider()
        }
    }

    // MARK: - 自适应语速（P0: 根据连对数提速）
    // 0-2连对: 0.42慢速 → 3-6: 0.47中速 → 7-11: 0.52较快 → 12+: 0.57接近自然语速
    var currentRate: Float {
        switch currentStreak {
        case 0..<3:  return 0.42
        case 3..<7:  return 0.47
        case 7..<12: return 0.52
        default:     return 0.57
        }
    }

    var speedLevel: Int {
        switch currentStreak {
        case 0..<3:  return 1
        case 3..<7:  return 2
        case 7..<12: return 3
        default:     return 4
        }
    }

    var speedLabel: String {
        switch currentStreak {
        case 0..<3:  return "慢速"
        case 3..<7:  return "中速"
        case 7..<12: return "较快"
        default:     return "自然"
        }
    }

    var canVerify: Bool {
        !userInput.trimmingCharacters(in: .whitespaces).isEmpty
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
            }

            // P1: 构建句子语境（数字嵌入真实句子中播放）
            let template = provider.sentenceTemplate(for: mode)
            sentenceContext = template.replacingOccurrences(of: "{X}", with: speakableContent)
        }

        if speakNow {
            replay()
        }
    }

    // MARK: - 重放（使用当前自适应语速）
    func replay() {
        SpeechManager.shared.speak(sentenceContext, rate: currentRate)
    }

    // MARK: - 验证答案（若无输入则直接揭晓，不计分）
    func verify() {
        // 没有输入 → 直接揭晓，不影响统计
        guard canVerify else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                answerState = .revealed
            }
            return
        }

        let isCorrect = checkAnswer(userInput, against: currentDisplay)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if isCorrect {
                answerState = .correct
                sessionCorrect += 1
                currentStreak += 1
            } else {
                answerState = .wrong
                currentStreak = 0
            }
            sessionTotal += 1
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
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
}
