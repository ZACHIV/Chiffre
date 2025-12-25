//
//  SurrealTheme.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
//


import SwiftUI

struct SurrealTheme {
    // MARK: - 1. 配色盘 (梦幻粉彩)
    static let colors = (
        skyStart: Color(red: 0.88, green: 0.97, blue: 0.98), // 淡青
        skyEnd: Color(red: 0.97, green: 0.73, blue: 0.82),   // 晚霞粉
        deepIndigo: Color(red: 0.16, green: 0.21, blue: 0.58), // 深靛蓝 (文字/图标)
        coral: Color(red: 1.0, green: 0.54, blue: 0.40),       // 珊瑚橙 (强调)
        glassWhite: Color.white.opacity(0.6),                  // 玻璃白
        glassStroke: Color.white.opacity(0.4)                  // 玻璃边框
    )
    
    // MARK: - 2. 排版系统
    struct Typography {
        // 大标题：优雅衬线体 (Didot)
        static func title(_ size: CGFloat) -> Font {
            .custom("Didot", size: size).weight(.bold)
        }
        
        // 副标题/按钮：半粗衬线体
        static func header(_ size: CGFloat) -> Font {
            .custom("Didot", size: size).weight(.semibold)
        }
        
        // 正文：圆角现代字体
        static func body(_ size: CGFloat) -> Font {
            .system(size: size, design: .rounded)
        }
        
        // 数字：衬线体数字，更有复古感
        static func number(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
    }
    
    // MARK: - 3. 全局背景 (Moebius Sky)
    static var mainBackground: some View {
        LinearGradient(
            colors: [colors.skyStart, colors.skyEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            ZStack {
                // 增加一点光晕，营造梦境感
                Circle().fill(colors.coral.opacity(0.15)).blur(radius: 80).offset(x: -120, y: -200)
                Circle().fill(colors.deepIndigo.opacity(0.1)).blur(radius: 100).offset(x: 150, y: 300)
            }
        )
    }
}
