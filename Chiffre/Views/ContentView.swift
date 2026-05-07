import SwiftUI

struct ContentView: View {
    @StateObject private var trainer = NumberTrainer()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)

        appearance.shadowImage = UIImage()
        appearance.backgroundImage = UIImage()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else {
                mainTabs
            }
        }
    }

    private var mainTabs: some View {
        TabView {
            ChiffreHomeView(trainer: trainer)
                .tabItem {
                    Label("Écouter", systemImage: "ear.and.waveform")
                }

            ReferenceView()
                .tabItem {
                    Label("Liste", systemImage: "square.grid.3x3.fill")
                }

            SettingsView(trainer: trainer)
                .tabItem {
                    Label("Réglages", systemImage: "slider.horizontal.3")
                }
        }
        .tint(SurrealTheme.colors.deepIndigo)
    }
}
