//
//  ContentView.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/26.
//


import SwiftUI

struct ContentView: View {
    // 定制 TabView 外观
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.3) // 玻璃质感底色
        
        // 毛玻璃效果
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
        }
        .tint(SurrealTheme.colors.deepIndigo) // 选中态颜色
    }
}