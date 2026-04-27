//
//  ChiffreTests.swift
//  ChiffreTests
//
//  Created by zachmacmini on 2025/12/25.
//

import Foundation
import Testing
@testable import Chiffre

struct ChiffreTests {

    @Test func dailySignCatalogResolvesEntryByCalendarDay() async throws {
        let entries = [
            DailyNumberSignEntry(
                day: 14,
                title: "十四号半个月",
                subtitle: "测试副标题",
                numberStory: "测试逸闻"
            ),
            DailyNumberSignEntry(
                day: 31,
                title: "三十一号盛装出门",
                subtitle: "测试副标题",
                numberStory: "测试逸闻"
            )
        ]

        let catalog = DailyNumberSignCatalog(entries: entries)
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 4, day: 14)))

        #expect(catalog.entry(for: date, calendar: calendar)?.title == "十四号半个月")
        #expect(catalog.entry(for: date, calendar: calendar)?.day == 14)
    }

    @Test func dailySignStoreRefreshesUsingInjectedDateProvider() async throws {
        let entries = [
            DailyNumberSignEntry(
                day: 14,
                title: "十四号半个月",
                subtitle: "测试副标题",
                numberStory: "测试逸闻"
            ),
            DailyNumberSignEntry(
                day: 15,
                title: "十五号月圆",
                subtitle: "测试副标题",
                numberStory: "测试逸闻"
            )
        ]

        let calendar = Calendar(identifier: .gregorian)
        let firstDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 4, day: 14)))
        let secondDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 4, day: 15)))
        var currentDate = firstDate

        let store = DailyNumberSignStore(
            catalog: DailyNumberSignCatalog(entries: entries),
            calendar: calendar,
            dateProvider: { currentDate }
        )

        #expect(store.todaysEntry?.day == 14)
        #expect(store.todaysEntry?.title == "十四号半个月")

        currentDate = secondDate
        store.refresh()

        #expect(store.todaysEntry?.day == 15)
        #expect(store.todaysEntry?.title == "十五号月圆")
    }

    @Test func answerNormalizerMatchesCommonListeningFormats() {
        let normalizer = AnswerNormalizer()

        #expect(normalizer.matches("14h30", target: "14:30"))
        #expect(normalizer.matches("06 12 34 56 78", target: "0612345678"))
        #expect(normalizer.matches("le 15 de enero", target: "15 enero"))
        #expect(normalizer.matches("12,50 €", target: "12.50"))
    }

    @Test func hintEngineRevealsDigitsProgressively() throws {
        let engine = HintEngine()

        let firstHint = try #require(engine.nextDigitHint(display: "AF 2048", revealedDigits: 0))
        #expect(firstHint.stage == .partialReveal)
        #expect(firstHint.visual == "AF 2•••")
        #expect(firstHint.revealedDigits == 1)

        let finalHint = try #require(engine.nextDigitHint(display: "42", revealedDigits: 1))
        #expect(finalHint.stage == .fullReveal)
        #expect(finalHint.visual == "42")
    }

    @Test func exerciseGeneratorProducesConfiguredNumberExercise() {
        let generator = RandomExerciseGenerator()
        let settings = TrainingSettings(mode: .number, maxRange: 9, playbackRate: 0.56)
        let exercise = generator.generate(settings: settings, provider: FrenchDataProvider())

        #expect(Int(exercise.display) != nil)
        #expect((0...9).contains(Int(exercise.display) ?? -1))
        #expect(exercise.speakable == exercise.display)
        #expect(exercise.sentence.contains(exercise.display))
    }

    @Test func voiceSettingsStorePersistsPreferences() {
        let suiteName = "ChiffreTests.VoiceSettingsStore"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = VoiceSettingsStore(userDefaults: defaults)
        store.save(language: .spanish)
        store.save(frenchVoice: .thomas)
        store.save(spanishVoice: .diego)

        #expect(store.loadLanguage() == .spanish)
        #expect(store.loadFrenchVoice() == .thomas)
        #expect(store.loadSpanishVoice() == .diego)

        defaults.removePersistentDomain(forName: suiteName)
    }

}
