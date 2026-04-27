import Foundation

protocol ExerciseGenerating {
    func generate(settings: TrainingSettings, provider: LanguageDataProvider) -> Exercise
}

struct RandomExerciseGenerator: ExerciseGenerating {
    func generate(settings: TrainingSettings, provider: LanguageDataProvider) -> Exercise {
        var display = ""
        var speakable = ""
        var sentence = ""
        var annotation = ""

        switch settings.mode {
        case .number:
            let number = Int.random(in: 0...settings.maxRange)
            display = "\(number)"
            speakable = "\(number)"

        case .phoneNumber:
            let prefix = provider.formatPhonePrefix()
            let parts = (0..<4).map { _ in String(format: "%02d", Int.random(in: 0...99)) }
            display = "\(prefix) \(parts.joined(separator: " "))"
            speakable = "\(prefix), \(parts.joined(separator: ", "))"

        case .price:
            let formatted = provider.formatPrice(euro: Int.random(in: 1...100), cent: Int.random(in: 0...99))
            display = formatted.display
            speakable = formatted.speakable

        case .time:
            let formatted = provider.formatTime(hour: Int.random(in: 0...23), minute: Int.random(in: 0...59))
            display = formatted.display
            speakable = formatted.speakable

        case .year:
            let year = Int.random(in: 1950...2030)
            display = "\(year)"
            speakable = "\(year)"

        case .month:
            if let monthData = provider.months.randomElement() {
                let formatted = provider.formatMonth(day: Int.random(in: 1...monthData.days), month: monthData.name)
                display = formatted.display
                speakable = formatted.speakable
            }

        case .trainNumber:
            if let trainType = provider.trainTypes.randomElement() {
                let number = Int.random(in: 1000...9999)
                display = "\(trainType) \(number)"
                speakable = "\(trainType), \(number)"
            }

        case .flightNumber:
            if let airline = provider.airlines.randomElement() {
                let flightNumber = Int.random(in: 10...9999)
                display = "\(airline.code) \(flightNumber)"
                let code = airline.code.map { String($0) }.joined(separator: ", ")
                speakable = "\(code), \(flightNumber)"
            }

        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            if let scenario = provider.scenarioPrompt(for: settings.mode) {
                display = scenario.display
                speakable = scenario.speakable
                sentence = scenario.sentence
                annotation = scenario.annotation
            }
        }

        if sentence.isEmpty {
            sentence = provider
                .sentenceTemplate(for: settings.mode)
                .replacingOccurrences(of: "{X}", with: speakable)
        }

        return Exercise(display: display, speakable: speakable, sentence: sentence, annotation: annotation)
    }
}
