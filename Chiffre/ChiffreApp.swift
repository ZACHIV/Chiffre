import SwiftUI

@main
struct ChiffreApp: App {
    var body: some Scene {
        WindowGroup {
            ChiffreHomeView()
                .preferredColorScheme(.light) // 强制浅色模式以适配梦幻风格
        }
    }
}
