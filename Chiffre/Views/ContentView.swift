import SwiftUI

struct ContentView: View {
    // 定制 TabView 外观
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        // 增加一点点背景色，防止底部文字看不清
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // 去除顶部的分割线，让界面更通透
        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // 1. 听力 (输入)
            ChiffreHomeView()
                .tabItem {
                    Label("Écouter", systemImage: "ear.and.waveform")
                }
            
            // 2. 口语 (输出)
            SpeakingPracticeView()
                .tabItem {
                    Label("Parler", systemImage: "mic.fill")
                }
            
            // 3. 列表 (查阅)
            ReferenceView()
                .tabItem {
                    Label("Liste", systemImage: "square.grid.3x3.fill") // 使用网格图标
                }
        }
        .tint(SurrealTheme.colors.deepIndigo)
    }
}
