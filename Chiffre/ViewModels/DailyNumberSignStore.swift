import Foundation

struct DailyNumberSignEntry: Codable, Identifiable, Equatable {
    let day: Int
    let title: String
    let subtitle: String
    let dailyCopy: String
    let numberStory: String
    let visualMotif: String

    var id: Int { day }

    private enum CodingKeys: String, CodingKey {
        case day
        case title
        case subtitle
        case dailyCopy = "daily_copy"
        case numberStory = "number_story"
        case visualMotif = "visual_motif"
    }
}

struct DailyNumberSignCatalog {
    private let entriesByDay: [Int: DailyNumberSignEntry]

    init(entries: [DailyNumberSignEntry]) {
        entriesByDay = Dictionary(uniqueKeysWithValues: entries.map { ($0.day, $0) })
    }

    init(bundle: Bundle = .main) {
        do {
            let entries = try Self.loadEntries(bundle: bundle)
            self.init(entries: entries)
        } catch {
            assertionFailure("Failed to load daily number signs: \(error)")
            self.init(entries: [])
        }
    }

    func entry(for date: Date, calendar: Calendar = .current) -> DailyNumberSignEntry? {
        let day = calendar.component(.day, from: date)
        return entriesByDay[day]
    }

    private static func loadEntries(bundle: Bundle) throws -> [DailyNumberSignEntry] {
        let resourceName = "daily-number-sign-1-31"
        let url = bundle.url(forResource: resourceName, withExtension: "json")
            ?? bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Content")
            ?? bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Resources/Content")

        guard let url else {
            throw DailyNumberSignError.missingResource
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DailyNumberSignEntry].self, from: data)
    }
}

final class DailyNumberSignStore: ObservableObject {
    @Published private(set) var todaysEntry: DailyNumberSignEntry?

    private let catalog: DailyNumberSignCatalog
    private let calendar: Calendar
    private let dateProvider: () -> Date

    init(
        catalog: DailyNumberSignCatalog = DailyNumberSignCatalog(),
        calendar: Calendar = .current,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.catalog = catalog
        self.calendar = calendar
        self.dateProvider = dateProvider
        refresh()
    }

    func refresh() {
        todaysEntry = catalog.entry(for: dateProvider(), calendar: calendar)
    }
}

private enum DailyNumberSignError: Error {
    case missingResource
}
