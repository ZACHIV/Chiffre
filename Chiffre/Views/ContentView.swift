import SwiftUI

struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(SurrealTheme.colors.surfaceStrong)
        appearance.shadowColor = UIColor(SurrealTheme.colors.border)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(SurrealTheme.colors.textSecondary)
    }

    var body: some View {
        TabView {
            ChiffreHomeView()
                .tabItem {
                    Label("Écouter", systemImage: "ear.and.waveform")
                }

            SpeakingPracticeView()
                .tabItem {
                    Label("Parler", systemImage: "mic.fill")
                }

            ReferenceView()
                .tabItem {
                    Label("Référence", systemImage: "square.grid.2x2.fill")
                }
        }
        .tint(SurrealTheme.colors.deepIndigo)
    }
}
