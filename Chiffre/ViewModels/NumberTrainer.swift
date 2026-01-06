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
    private var speakableContent: String = "" // 专门用于朗读的字符串
    
    @Published var isRevealed: Bool = false
    
    @AppStorage("gameMode") var mode: GameMode = .number
    @AppStorage("maxRange") var maxRange: Int = 100 // 仅用于数字模式
    
    init() {
            // 修复点 2: 不再显示 "Prêt"，初始化直接生成题目
            generateNew(speakNow: false)
        }
    
    func generateNew(speakNow: Bool = true) {
        withAnimation(.spring()) {
            isRevealed = false
            
            switch mode {
            case .number:
                let num = Int.random(in: 0...maxRange)
                currentDisplay = "\(num)"
                speakableContent = "\(num)"
                
            case .phoneNumber:
                // 电话：06 12 34 56 78
                let prefix = Bool.random() ? "06" : "07"
                let p1 = String(format: "%02d", Int.random(in: 0...99))
                let p2 = String(format: "%02d", Int.random(in: 0...99))
                let p3 = String(format: "%02d", Int.random(in: 0...99))
                let p4 = String(format: "%02d", Int.random(in: 0...99))
                
                currentDisplay = "\(prefix) \(p1) \(p2) \(p3) \(p4)"
                // 语音：加逗号制造停顿
                speakableContent = "\(prefix), \(p1), \(p2), \(p3), \(p4)"
                
            case .price:
                // 价格：12,50 €
                let euro = Int.random(in: 1...100)
                let cent = Int.random(in: 0...99)
                // 法语习惯用逗号做小数点
                currentDisplay = String(format: "%d,%02d €", euro, cent)
                // 语音：TTS 能够识别 "euros"，但最好明确写出格式
                // 比如 "12 euros 50"
                speakableContent = "\(euro) euros \(cent)"
                
            case .time:
                // 时间：14h30
                let hour = Int.random(in: 0...23)
                let minute = Int.random(in: 0...59)
                currentDisplay = String(format: "%02dh%02d", hour, minute)
                
                if minute == 0 {
                    speakableContent = "\(hour) heures pile" // 整点
                } else if minute == 30 {
                    speakableContent = "\(hour) heures et demie" // 半点
                } else {
                    speakableContent = "\(hour) heures \(minute)"
                }
                
            case .year:
                // 年份：1950 - 2030
                let year = Int.random(in: 1950...2030)
                currentDisplay = "\(year)"
                speakableContent = "\(year)"
                
            case .month:
                // 日期+月份：le 15 janvier
                // 定义每个月份及其对应的天数
                let monthsWithDays: [(name: String, days: Int)] = [
                    ("janvier", 31),    // 1月
                    ("février", 28),    // 2月（简化处理，不考虑闰年）
                    ("mars", 31),       // 3月
                    ("avril", 30),      // 4月
                    ("mai", 31),        // 5月
                    ("juin", 30),       // 6月
                    ("juillet", 31),    // 7月
                    ("août", 31),       // 8月
                    ("septembre", 30),  // 9月
                    ("octobre", 31),    // 10月
                    ("novembre", 30),   // 11月
                    ("décembre", 31)    // 12月
                ]
                
                // 随机选择一个月份
                let selectedMonth = monthsWithDays.randomElement()!
                let monthName = selectedMonth.name
                let maxDay = selectedMonth.days
                
                // 根据该月份的实际天数生成日期
                let day = Int.random(in: 1...maxDay)
                
                // 显示格式：le 15 janvier
                currentDisplay = "le \(day) \(monthName)"
                // 语音格式：le 15 janvier (或 le premier janvier 对于1号)
                if day == 1 {
                    speakableContent = "le premier \(monthName)"
                } else {
                    speakableContent = "le \(day) \(monthName)"
                }
                
            case .trainNumber:
                // 火车号：TGV 6523 或 Intercités 4521
                let trainTypes = ["TGV", "Intercités", "TER"]
                let trainType = trainTypes.randomElement()!
                let number = Int.random(in: 1000...9999)
                
                currentDisplay = "\(trainType) \(number)"
                // 语音：分开读，让数字更清晰
                speakableContent = "\(trainType), \(number)"
                
            case .flightNumber:
                // 航班号：AF 1234 (法航), EK 73 (阿联酋航空)
                let airlines = [
                    ("AF", "Air France"),      // 法国航空
                    ("EK", "Emirates"),        // 阿联酋航空
                    ("BA", "British Airways"), // 英国航空
                    ("LH", "Lufthansa"),       // 汉莎航空
                    ("KL", "KLM")              // 荷兰皇家航空
                ]
                let airline = airlines.randomElement()!
                let flightNum = Int.random(in: 10...9999)
                
                currentDisplay = "\(airline.0) \(flightNum)"
                // 语音：逐字母读航空公司代码，然后读数字
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
