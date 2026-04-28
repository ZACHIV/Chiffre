import SwiftUI
import Combine

final class NumberTrainer: ObservableObject {
    @Published var currentDisplay: String = ""
    @Published var userInput: String = ""
    @Published var answerState: AnswerState = .waiting
    @Published var hintStage: HintStage = .none
    @Published var hintMessage: String = ""
    @Published var hintVisual: String = ""
    @Published var revealedHintDigits: Int = 0

    @AppStorage("lifetimePracticeCount") var lifetimePracticeCount: Int = 0

    @AppStorage("gameMode") var mode: GameMode = .number
    @AppStorage("maxRange") var maxRange: Int = 100
    @AppStorage("listeningPlaybackRate") var playbackRate: Double = 0.56

    private(set) var speakableContent: String = ""
    private(set) var sentenceContext: String = ""
    private(set) var displayAnnotation: String = ""

    private let exerciseGenerator: ExerciseGenerating
    private let answerNormalizer: AnswerNormalizing
    private let hintEngine: HintEngine
    private let speechPlayer: SpeechPlaying
    private var cancellables = Set<AnyCancellable>()

    var settings: TrainingSettings {
        TrainingSettings(mode: mode, maxRange: maxRange, playbackRate: playbackRate)
    }

    var dataProvider: LanguageDataProvider {
        LanguagePack(language: LanguageVoiceManager.shared.currentLanguage).provider
    }

    var currentRate: Float {
        settings.currentRate
    }

    var speedLevel: Int {
        settings.speedLevel
    }

    var speedLabel: String {
        settings.speedLabel
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
        hintEngine.revealAnnotation(
            display: currentDisplay,
            speakable: speakableContent,
            annotation: displayAnnotation,
            mode: mode,
            localeIdentifier: LanguageVoiceManager.shared.currentLanguage.localeIdentifier
        )
    }

    var hintActionText: String {
        "提示一位"
    }

    var preferredKeyboardType: UIKeyboardType {
        switch mode {
        case .number, .year: return .numberPad
        case .price:         return .decimalPad
        default:             return .default
        }
    }

    init(
        exerciseGenerator: ExerciseGenerating = RandomExerciseGenerator(),
        answerNormalizer: AnswerNormalizing = AnswerNormalizer(),
        hintEngine: HintEngine = HintEngine(),
        speechPlayer: SpeechPlaying = SpeechManager.shared
    ) {
        self.exerciseGenerator = exerciseGenerator
        self.answerNormalizer = answerNormalizer
        self.hintEngine = hintEngine
        self.speechPlayer = speechPlayer

        generateNew(speakNow: false)

        LanguageVoiceManager.shared.$currentLanguage
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.generateNew(speakNow: false)
            }
            .store(in: &cancellables)
    }

    func generateNew(speakNow: Bool = true) {
        let exercise = exerciseGenerator.generate(settings: settings, provider: dataProvider)

        withAnimation(.spring()) {
            answerState = .waiting
            userInput = ""
            hintStage = .none
            hintMessage = ""
            hintVisual = ""
            revealedHintDigits = 0
            currentDisplay = exercise.display
            speakableContent = exercise.speakable
            sentenceContext = exercise.sentence
            displayAnnotation = exercise.annotation
        }

        if speakNow {
            replayFull()
        }
    }

    func replay() {
        replayFull()
    }

    func replayFull() {
        speechPlayer.speak(sentenceContext, rate: currentRate)
    }

    func replayFocused() {
        speechPlayer.speak(speakableContent, rate: currentRate)
    }

    func replaySlow() {
        speechPlayer.speak(sentenceContext, rate: max(0.36, currentRate - 0.1))
    }

    func requestHint() {
        guard answerState == .waiting else { return }
        guard let hint = hintEngine.nextDigitHint(display: currentDisplay, revealedDigits: revealedHintDigits) else {
            return
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            revealedHintDigits = hint.revealedDigits
            hintStage = hint.stage
            hintMessage = hint.message
            hintVisual = hint.visual
        }
    }

    func verify() {
        _ = answerNormalizer.matches(userInput, target: currentDisplay)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            answerState = .revealed
        }

        lifetimePracticeCount += 1

        if UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    }
}
