//
//  SurrealTheme.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
//  Updated: 2026-01-07 - Monet Impressionist Theme
//

import SwiftUI

struct MonetTheme {
    // MARK: - 1. Monet-Inspired Color Palette (莫奈印象派调色板)
    // Inspired by "Water Lilies", "Impression, Sunrise", "Poppies"
    static let colors = (
        // Sky & Water (天空与水面 - 背景色调)
        skyDawn: Color(red: 1.0, green: 0.898, blue: 0.851),      // #FFE5D9 - 晨曦粉
        waterBlue: Color(red: 0.722, green: 0.847, blue: 0.910),  // #B8D8E8 - 水面蓝
        lavenderMist: Color(red: 0.902, green: 0.902, blue: 0.980), // #E6E6FA - 薰衣草雾
        
        // Nature (自然色调)
        lilyPad: Color(red: 0.784, green: 0.835, blue: 0.725),    // #C8D5B9 - 睡莲绿
        
        // PRIMARY COLORS (主色调 - 恢复经典配色)
        deepIndigo: Color(red: 0.16, green: 0.21, blue: 0.58),    // #2A3594 - 深靛蓝 (文字/图标)
        coral: Color(red: 1.0, green: 0.54, blue: 0.40),          // #FF8A66 - 珊瑚橙 (强调色)
        
        // Supporting (辅助色调)
        softShadow: Color(red: 0.514, green: 0.565, blue: 0.678), // #8390AD - 柔和阴影
        
        // Glass & Light (玻璃与光)
        glassWhite: Color.white.opacity(0.65),
        glassStroke: Color.white.opacity(0.5),
        shimmer: Color.white.opacity(0.5)  // 增强亮度
    )
    
    // MARK: - 2. Typography System (排版系统)
    struct Typography {
        // Elegant serif for titles - with subtle shadow for depth
        static func title(_ size: CGFloat) -> Font {
            .custom("Didot", size: size).weight(.bold)
        }
        
        static func header(_ size: CGFloat) -> Font {
            .custom("Didot", size: size).weight(.semibold)
        }
        
        static func body(_ size: CGFloat) -> Font {
            .system(size: size, design: .rounded)
        }
        
        static func number(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
    }
    
    // MARK: - 3. Animated Impressionist Background (印象派动态背景)
    static var mainBackground: some View {
        MonetAnimatedBackground()
    }
}

// MARK: - Animated Background Component
struct MonetAnimatedBackground: View {
    @State private var animateGradient = false
    @State private var particleOffset1: CGFloat = 0
    @State private var particleOffset2: CGFloat = 0
    @State private var particleOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Base Layer: Dawn Sky Gradient (基础层：晨曦天空)
            LinearGradient(
                colors: animateGradient ? 
                    [MonetTheme.colors.skyDawn, MonetTheme.colors.waterBlue, MonetTheme.colors.lavenderMist] :
                    [MonetTheme.colors.waterBlue, MonetTheme.colors.lavenderMist, MonetTheme.colors.skyDawn],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
            
            // Mid Layer: Soft Color Clouds (中层：柔和色彩云)
            ZStack {
                // Lily pad green cloud
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MonetTheme.colors.lilyPad.opacity(0.2),
                                MonetTheme.colors.lilyPad.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -100, y: particleOffset1 - 150)
                
                // Coral cloud (replacing sunset orange)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MonetTheme.colors.coral.opacity(0.15),
                                MonetTheme.colors.coral.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 70)
                    .offset(x: 120, y: particleOffset2 + 200)
                
                // Lavender mist cloud
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MonetTheme.colors.lavenderMist.opacity(0.25),
                                MonetTheme.colors.lavenderMist.opacity(0.08),
                                .clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: particleOffset1 * 0.5, y: 100)
            }
            
            // Top Layer: Enhanced Shimmering Light Particles (顶层：增强闪烁光粒子)
            Canvas { context, size in
                let particles = createLightParticles(in: size)
                for particle in particles {
                    context.opacity = particle.opacity * particleOpacity
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: particle.x,
                            y: particle.y,
                            width: particle.size,
                            height: particle.size
                        )),
                        with: .color(MonetTheme.colors.shimmer)
                    )
                }
            }
            .blur(radius: 1.5)
            .allowsHitTesting(false)
        }
        .onAppear {
            animateGradient = true
            
            // Gentle floating animation for clouds
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                particleOffset1 = 30
            }
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                particleOffset2 = -25
            }
            
            // Pulsing animation for particles (呼吸动画)
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                particleOpacity = 0.6
            }
        }
    }
    
    // Generate enhanced light particles (增强光粒子 - 50个，更大更亮)
    private func createLightParticles(in size: CGSize) -> [LightParticle] {
        var particles: [LightParticle] = []
        for _ in 0..<50 {  // 从25增加到50
            particles.append(LightParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 4...12),  // 从3-8增加到4-12
                opacity: Double.random(in: 0.2...0.6)  // 从0.1-0.4增加到0.2-0.6
            ))
        }
        return particles
    }
}

struct LightParticle {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}

// MARK: - Backward Compatibility Alias
typealias SurrealTheme = MonetTheme
