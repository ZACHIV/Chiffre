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
                dailyCopy: "测试内容",
                numberStory: "测试逸闻",
                visualMotif: "测试视觉"
            ),
            DailyNumberSignEntry(
                day: 31,
                title: "三十一号盛装出门",
                subtitle: "测试副标题",
                dailyCopy: "测试内容",
                numberStory: "测试逸闻",
                visualMotif: "测试视觉"
            )
        ]

        let catalog = DailyNumberSignCatalog(entries: entries)
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 4, day: 14)))

        #expect(catalog.entry(for: date, calendar: calendar)?.title == "十四号半个月")
        #expect(catalog.entry(for: date, calendar: calendar)?.day == 14)
    }

}
