import SwiftUI
import Combine

// 1. 定义扩展后的游戏模式
enum GameMode: String, CaseIterable, Identifiable {
    case number = "Chiffres (数字)"
    case phoneNumber = "Tél (电话)"
    case price = "Prix (价格)"
    case time = "Heure (时间)"
    case year = "Année (年份)"
    case month = "Mois (月份)"
    case trainNumber = "Train (火车号)"
    case flightNumber = "Vol (航班号)"
    
    var id: String { self.rawValue }
    
    // 对应图标，用于 UI 展示
    var icon: String {
        switch self {
        case .number: return "number"
        case .phoneNumber: return "phone.fill"
        case .price: return "eurosign.circle.fill"
        case .time: return "clock.fill"
        case .year: return "calendar"
        case .month: return "calendar.circle.fill"
        case .trainNumber: return "tram.fill"
        case .flightNumber: return "airplane"
        }
    }
}

class NumberTrainer: ObservableObject {
    @Published var currentDisplay: String = "Prêt"
    private var speakableContent: String = ""
    
    @Published var isRevealed: Bool = false
    
    @AppStorage("gameMode") var mode: GameMode = .number
    @AppStorage("maxRange") var maxRange: Int = 100
    
    // 根据当前语言返回对应的数据提供者
    var dataProvider: LanguageDataProvider {
        switch LanguageVoiceManager.currentLanguage {
        case .french:
            return FrenchDataProvider()
        case .spanish:
            return SpanishDataProvider()
        }
    }
    
    init() {
        generateNew(speakNow: false)
    }
    
    func generateNew(speakNow: Bool = true) {
        withAnimation(.spring()) {
            isRevealed = false
            let provider = dataProvider
            
            switch mode {
            case .number:
                let num = Int.random(in: 0...maxRange)
                currentDisplay = "\(num)"
                speakableContent = "\(num)"
                
            case .phoneNumber:
                let prefix = provider.formatPhonePrefix()
                let p1 = String(format: "%02d", Int.random(in: 0...99))
                let p2 = String(format: "%02d", Int.random(in: 0...99))
                let p3 = String(format: "%02d", Int.random(in: 0...99))
                let p4 = String(format: "%02d", Int.random(in: 0...99))
                
                currentDisplay = "\(prefix) \(p1) \(p2) \(p3) \(p4)"
                speakableContent = "\(prefix), \(p1), \(p2), \(p3), \(p4)"
                
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
        }
        
        if speakNow {
            replay()
        }
    }
    
    func replay() {
        SpeechManager.shared.speak(speakableContent)
    }
    
    func reveal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
        }
    }
}
