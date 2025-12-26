import SwiftUI

@main
struct ChiffreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // 替换原来的 ChiffreHomeView()
                .preferredColorScheme(.light)
        }
    }
}
