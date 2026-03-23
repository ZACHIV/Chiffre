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
    case waiting
    case revealed
    case correct
    case wrong
}

enum ReplayLayer {
    case fullSentence
    case focusSegment
    case slowSentence

    var shortTitle: String {
        switch self {
        case .fullSentence:
            return "整句"
        case .focusSegment:
            return "片段"
        case .slowSentence:
            return "慢速"
        }
    }

    var coachLine: String {
        switch self {
        case .fullSentence:
            return "先从整句里抓住场景，再决定要不要继续缩小范围。"
        case .focusSegment:
            return "这次先只盯住数字片段，不追其他词。"
        case .slowSentence:
            return "保持自然韵律，但把关键位重新落住。"
        }
    }
}

enum HintStage: Int {
    case none = 0
    case structure
    case scaffold
    case partial

    var stageLabel: String {
        switch self {
        case .none:
            return "先听整句"
        case .structure:
            return "结构提示"
        case .scaffold:
            return "结构支架"
        case .partial:
            return "关键位展开"
        }
    }

    var actionTitle: String {
        switch self {
        case .none:
            return "给我一点提示"
        case .structure:
            return "看结构"
        case .scaffold:
            return "再展开一点"
        case .partial:
            return "显示答案"
        }
    }
}

struct StructureSegment: Identifiable {
    let label: String
    let value: String

    var id: String { "\(label)-\(value)" }
}

// MARK: - 核心 ViewModel
class NumberTrainer: ObservableObject {
    @Published var currentDisplay: String = ""
    @Published var userInput: String = ""
    @Published var answerState: AnswerState = .waiting

    // 会话统计仍保留给内部节奏控制，不再作为主界面核心反馈
    @Published var sessionCorrect: Int = 0
    @Published var sessionTotal: Int = 0
    @Published var currentStreak: Int = 0

    @Published private(set) var currentPrompt: DrillPrompt = FrenchDataProvider().drillPrompt(for: .number)
    @Published private(set) var hintStage: HintStage = .none
    @Published private(set) var lastReplayLayer: ReplayLayer = .fullSentence

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

    // MARK: - 自适应语速
    var currentRate: Float {
        switch currentStreak {
        case 0..<3:  return 0.42
        case 3..<7:  return 0.47
        case 7..<12: return 0.52
        default:     return 0.57
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

    var preferredKeyboardType: UIKeyboardType {
        switch mode {
        case .number, .year: return .numberPad
        case .price:         return .decimalPad
        default:             return .default
        }
    }

    var focusReplayTitle: String {
        currentPrompt.focusReplayLabel
    }

    var assistStageLabel: String {
        answerState == .waiting ? hintStage.stageLabel : "结构复盘"
    }

    var coachTitle: String {
        switch answerState {
        case .waiting:
            switch hintStage {
            case .none:
                return "先抓结构，不抢答案"
            case .structure:
                return "先判断结构类型"
            case .scaffold:
                return "先记骨架，再补内容"
            case .partial:
                return "还差最后几位"
            }
        case .revealed:
            return "先把这一类听顺"
        case .correct:
            return "已经抓住了关键位"
        case .wrong:
            return "先别急着给自己判错"
        }
    }

    var coachMessage: String {
        switch answerState {
        case .waiting:
            switch hintStage {
            case .none:
                return lastReplayLayer == .fullSentence ? currentPrompt.coachLine : lastReplayLayer.coachLine
            case .structure:
                return currentPrompt.structureHint
            case .scaffold:
                return "先照着结构骨架去听，不要一口气追完整答案。"
            case .partial:
                return "关键位已经揭开一部分了，再听一次把剩下的补上。"
            }
        case .revealed:
            return "这次先看结构，不计分也没关系，下一题继续。"
        case .correct:
            return "答对了，下一题会沿着当前节奏继续推进。"
        case .wrong:
            return "对照结构卡找差异，比盯着对错更有帮助。"
        }
    }

    var hintButtonTitle: String {
        hintStage.actionTitle
    }

    var shouldShowHintCard: Bool {
        answerState == .waiting && hintStage != .none
    }

    var hintCardTitle: String {
        switch hintStage {
        case .none:
            return ""
        case .structure:
            return "这是哪一类信息"
        case .scaffold:
            return "先看结构支架"
        case .partial:
            return "先揭开关键位"
        }
    }

    var hintCardMessage: String {
        switch hintStage {
        case .none:
            return ""
        case .structure:
            return currentPrompt.structureHint
        case .scaffold:
            return "先把这个结构框架记住，再回去听一遍会更容易落点。"
        case .partial:
            return "已经先帮你揭开一部分，再听的时候只需要补剩下的位。"
        }
    }

    var hintScaffold: String? {
        guard answerState == .waiting else { return nil }
        guard hintStage.rawValue >= HintStage.scaffold.rawValue else { return nil }
        return scaffoldText(for: currentDisplay)
    }

    var hintPartialReveal: String? {
        guard answerState == .waiting else { return nil }
        guard hintStage == .partial else { return nil }
        return partialRevealText(for: currentDisplay)
    }

    var structureSegments: [StructureSegment] {
        buildStructureSegments()
    }

    init() {
        generateNew(speakNow: false)

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
            lastReplayLayer = .fullSentence

            let provider = dataProvider
            currentPrompt = provider.drillPrompt(for: mode)

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

            sentenceContext = currentPrompt.sentenceTemplate.replacingOccurrences(of: "{X}", with: speakableContent)
        }

        if speakNow {
            replay()
        }
    }

    // MARK: - 分层重播
    func replay() {
        replayFullSentence()
    }

    func replayFullSentence() {
        lastReplayLayer = .fullSentence
        SpeechManager.shared.speak(sentenceContext, rate: currentRate)
    }

    func replayFocusedSegment() {
        lastReplayLayer = .focusSegment
        SpeechManager.shared.speak(speakableContent, rate: max(0.38, currentRate - 0.02))
    }

    func replaySlowSentence() {
        lastReplayLayer = .slowSentence
        SpeechManager.shared.speak(sentenceContext, rate: max(0.32, currentRate - 0.08))
    }

    // MARK: - 渐进提示
    func advanceHint() {
        guard answerState == .waiting else { return }

        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            switch hintStage {
            case .none:
                hintStage = .structure
            case .structure:
                hintStage = .scaffold
            case .scaffold:
                hintStage = .partial
            case .partial:
                answerState = .revealed
            }
        }
    }

    // MARK: - 验证答案
    func verify() {
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
        generator.notificationOccurred(isCorrect ? .success : .warning)
    }

    // MARK: - 答案比对
    private func checkAnswer(_ input: String, against target: String) -> Bool {
        let normInput  = normalize(input)
        let normTarget = normalize(target)
        if normInput == normTarget { return true }

        let strip = { (s: String) in s.replacingOccurrences(of: " ", with: "") }
        return strip(normInput) == strip(normTarget)
    }

    private func normalize(_ s: String) -> String {
        var r = s.lowercased().trimmingCharacters(in: .whitespaces)

        for prefix in ["le ", "la ", "el "] {
            if r.hasPrefix(prefix) {
                r = String(r.dropFirst(prefix.count))
                break
            }
        }

        r = r.replacingOccurrences(of: "€", with: "")
        r = r.replacingOccurrences(of: "$", with: "")
        r = r.replacingOccurrences(of: ",", with: ".")
        r = r.replacingOccurrences(of: "(\\d)h(\\d)", with: "$1:$2", options: .regularExpression)
        r = r.replacingOccurrences(of: " de ", with: " ")
        r = r.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.joined(separator: " ")

        return r
    }

    // MARK: - 结构提示文本
    private func scaffoldText(for display: String) -> String {
        switch mode {
        case .month:
            return maskMonthDisplay(display)
        default:
            return maskDigits(in: display)
        }
    }

    private func partialRevealText(for display: String) -> String {
        switch mode {
        case .number:
            return revealLeadingDigits(in: display, count: max(1, digitCount(in: display) / 2))
        case .phoneNumber:
            let groups = display.split(separator: " ")
            let revealDigits = groups.prefix(2).reduce(0) { $0 + $1.count }
            return revealLeadingDigits(in: display, count: max(1, revealDigits))
        case .price:
            let integerDigits = display.split(separator: ",").first?.filter { $0.isNumber }.count ?? 1
            return revealLeadingDigits(in: display, count: integerDigits)
        case .time:
            let separatorIndex = display.firstIndex(where: { $0 == "h" || $0 == ":" }) ?? display.endIndex
            let hourDigits = display[..<separatorIndex].filter { $0.isNumber }.count
            return revealLeadingDigits(in: display, count: max(1, hourDigits))
        case .year:
            return revealLeadingDigits(in: display, count: min(2, digitCount(in: display)))
        case .month:
            return revealMonthPartially(display)
        case .trainNumber, .flightNumber:
            return revealLeadingDigits(in: display, count: max(1, digitCount(in: display) / 2))
        }
    }

    private func buildStructureSegments() -> [StructureSegment] {
        switch mode {
        case .number:
            return [StructureSegment(label: "数字主体", value: currentDisplay)]
        case .phoneNumber:
            let groups = currentDisplay.split(separator: " ").map(String.init)
            guard let first = groups.first else { return [] }
            var segments = [StructureSegment(label: "前缀", value: first)]
            for (index, group) in groups.dropFirst().enumerated() {
                segments.append(StructureSegment(label: "第\(index + 1)组", value: group))
            }
            return segments
        case .price:
            let trimmed = currentDisplay.replacingOccurrences(of: " €", with: "")
            let parts = trimmed.split(separator: ",").map(String.init)
            guard parts.count == 2 else { return [StructureSegment(label: "价格", value: currentDisplay)] }
            return [
                StructureSegment(label: "整数位", value: parts[0]),
                StructureSegment(label: "小数位", value: parts[1]),
                StructureSegment(label: "货币", value: "€")
            ]
        case .time:
            let parts = currentDisplay.split(whereSeparator: { $0 == "h" || $0 == ":" }).map(String.init)
            guard parts.count == 2 else { return [StructureSegment(label: "时间", value: currentDisplay)] }
            return [
                StructureSegment(label: "小时", value: parts[0]),
                StructureSegment(label: "分钟", value: parts[1])
            ]
        case .year:
            let prefix = String(currentDisplay.prefix(2))
            let suffix = String(currentDisplay.dropFirst(2))
            return [
                StructureSegment(label: "前半段", value: prefix),
                StructureSegment(label: "后半段", value: suffix)
            ]
        case .month:
            let tokens = currentDisplay.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let day = tokens.first(where: { token in token.contains(where: { $0.isNumber }) }) ?? currentDisplay
            let month = tokens.last ?? currentDisplay
            return [
                StructureSegment(label: "日期", value: day),
                StructureSegment(label: "月份", value: month)
            ]
        case .trainNumber:
            let tokens = currentDisplay.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard tokens.count >= 2 else { return [StructureSegment(label: "车次", value: currentDisplay)] }
            return [
                StructureSegment(label: "车次类型", value: tokens.dropLast().joined(separator: " ")),
                StructureSegment(label: "编号", value: tokens.last ?? "")
            ]
        case .flightNumber:
            let tokens = currentDisplay.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard tokens.count >= 2 else { return [StructureSegment(label: "航班号", value: currentDisplay)] }
            return [
                StructureSegment(label: "字母代码", value: tokens.first ?? ""),
                StructureSegment(label: "数字主体", value: tokens.dropFirst().joined(separator: " "))
            ]
        }
    }

    private func digitCount(in text: String) -> Int {
        text.filter { $0.isNumber }.count
    }

    private func maskDigits(in text: String) -> String {
        String(text.map { $0.isNumber ? "_" : $0 })
    }

    private func revealLeadingDigits(in text: String, count: Int) -> String {
        var revealed = 0
        var output = ""

        for character in text {
            if character.isNumber {
                if revealed < count {
                    output.append(character)
                    revealed += 1
                } else {
                    output.append("_")
                }
            } else {
                output.append(character)
            }
        }

        return output
    }

    private func maskMonthDisplay(_ text: String) -> String {
        var output = ""

        for character in text {
            if character.isNumber || character.isLetter {
                output.append("_")
            } else {
                output.append(character)
            }
        }

        return output
    }

    private func revealMonthPartially(_ text: String) -> String {
        var revealedDigits = 0
        var revealedLetters = 0
        var output = ""

        for character in text {
            if character.isNumber {
                if revealedDigits < 2 {
                    output.append(character)
                    revealedDigits += 1
                } else {
                    output.append("_")
                }
            } else if character.isLetter {
                if revealedLetters < 2 {
                    output.append(character)
                    revealedLetters += 1
                } else {
                    output.append("_")
                }
            } else {
                output.append(character)
            }
        }

        return output
    }
}
