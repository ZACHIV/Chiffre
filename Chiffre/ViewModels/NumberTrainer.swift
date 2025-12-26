import SwiftUI
import Combine

// 1. 定义扩展后的游戏模式
enum GameMode: String, CaseIterable, Identifiable {
    case number = "Chiffres (数字)"
    case phoneNumber = "Tél (电话)"
    case price = "Prix (价格)"
    case time = "Heure (时间)"
    case year = "Année (年份)"
    
    var id: String { self.rawValue }
    
    // 对应图标，用于 UI 展示
    var icon: String {
        switch self {
        case .number: return "number"
        case .phoneNumber: return "phone.fill"
        case .price: return "eurosign.circle.fill"
        case .time: return "clock.fill"
        case .year: return "calendar"
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
        // 初始不发声
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
