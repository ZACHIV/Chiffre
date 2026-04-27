import Foundation

struct HintResult {
    let stage: HintStage
    let message: String
    let visual: String
    let revealedDigits: Int
}

struct HintEngine {
    func nextDigitHint(display: String, revealedDigits: Int) -> HintResult? {
        let totalDigits = display.filter(\.isNumber).count
        guard totalDigits > 0 else { return nil }

        let nextRevealedDigits = min(totalDigits, revealedDigits + 1)
        return HintResult(
            stage: nextRevealedDigits >= totalDigits ? .fullReveal : .partialReveal,
            message: "已显示 \(nextRevealedDigits) 位数字",
            visual: digitRevealHint(display: display, visibleCount: nextRevealedDigits),
            revealedDigits: nextRevealedDigits
        )
    }

    func revealAnnotation(
        display: String,
        speakable: String,
        annotation: String,
        mode: GameMode,
        localeIdentifier: String
    ) -> String {
        if !annotation.isEmpty {
            return annotation
        }

        if let spelled = spelledOutDisplay(display: display, mode: mode, localeIdentifier: localeIdentifier) {
            return spelled
        }

        return speakable
            .replacingOccurrences(of: ",", with: " ·")
            .replacingOccurrences(of: "  ", with: " ")
    }

    func scaffold(display: String, mode: GameMode) -> String {
        switch mode {
        case .number:
            return String(repeating: "_", count: max(2, display.filter(\.isNumber).count))
        case .phoneNumber:
            let segments = display.split(separator: " ")
            guard let prefix = segments.first else { return "__ __ __ __ __" }
            return "\(prefix) __ __ __ __"
        case .price:
            return "__,__ €"
        case .time:
            return display.contains("h") ? "__h__" : "__:__"
        case .year:
            return "____"
        case .month:
            let parts = display.split(separator: " ")
            if let last = parts.last {
                return "__ \(last)"
            }
            return "__ ____"
        case .trainNumber, .flightNumber:
            let segments = display.split(separator: " ")
            guard let prefix = segments.first else { return "____" }
            return "\(prefix) ____"
        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            return "先听关键词，再听整句。"
        }
    }

    func partialReveal(display: String, mode: GameMode) -> String {
        switch mode {
        case .number:
            return maskDigits(in: display, visibleCount: max(1, display.filter(\.isNumber).count / 2))
        case .phoneNumber:
            let segments = display.split(separator: " ")
            if segments.count >= 2 {
                return "\(segments[0]) \(segments[1]) __ __ __"
            }
            return display
        case .price:
            let parts = display.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
            if let integerPart = parts.first {
                return "\(integerPart),__ €"
            }
            return "__,__ €"
        case .time:
            if let hourIndex = display.firstIndex(of: "h") {
                return "\(display[..<hourIndex])h__"
            }
            if let colonIndex = display.firstIndex(of: ":") {
                return "\(display[..<colonIndex]):__"
            }
            return "__:__"
        case .year:
            return maskDigits(in: display, visibleCount: 2)
        case .month:
            let parts = display.split(separator: " ")
            if parts.count >= 3 {
                return "\(parts[0]) \(parts[1]) ____"
            }
            if parts.count == 2 {
                return "\(parts[0]) ____"
            }
            return display
        case .trainNumber, .flightNumber:
            let segments = display.split(separator: " ")
            guard segments.count >= 2 else { return display }
            let prefix = String(segments[0])
            let number = String(segments[1])
            let visible = max(1, min(2, number.filter(\.isNumber).count - 1))
            return "\(prefix) \(maskDigits(in: number, visibleCount: visible))"
        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            let words = display.split(separator: " ")
            let visibleWords = words.prefix(2).joined(separator: " ")
            return words.count > 2 ? "\(visibleWords) ..." : visibleWords
        }
    }

    private func digitRevealHint(display: String, visibleCount: Int) -> String {
        var visibleDigits = visibleCount
        return String(display.map { char in
            guard char.isNumber else { return char }
            if visibleDigits > 0 {
                visibleDigits -= 1
                return char
            }
            return "•"
        })
    }

    private func spelledOutDisplay(display: String, mode: GameMode, localeIdentifier: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: localeIdentifier)

        switch mode {
        case .number, .year:
            guard let value = Int(display) else { return nil }
            return formatter.string(from: NSNumber(value: value))
        default:
            return nil
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
