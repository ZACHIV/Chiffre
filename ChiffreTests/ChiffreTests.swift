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

}
