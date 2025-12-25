import SwiftUI
import Combine // <--- 关键！必须添加这一行

class NumberTrainer: ObservableObject {
    // 当前数字
    @Published var currentNumber: Int = 0
    // 是否显示答案
    @Published var isRevealed: Bool = false
    
    // 难度设置 (持久化存储) - @AppStorage 是 SwiftUI 的，所以 import SwiftUI 也要保留
    @AppStorage("maxRange") var maxRange: Int = 100
    
    init() {
        // 初始化时生成第一个数字但不自动播放
        generateNew(speakNow: false)
    }
    
    // 生成新数字
    func generateNew(speakNow: Bool = true) {
        let minRange = 0
        var newNum = 0
        // 简单的防重复
        repeat {
            newNum = Int.random(in: minRange...maxRange)
        } while newNum == currentNumber && maxRange > minRange
        
        withAnimation(.spring()) {
            currentNumber = newNum
            isRevealed = false
        }
        
        if speakNow {
            replay()
        }
    }
    
    // 播放发音
    func replay() {
        SpeechManager.shared.speak(currentNumber)
    }
    
    // 揭晓答案
    func reveal() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
        }
    }
}
