//
//  ChiffreHomeView.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
//


import SwiftUI

struct ChiffreHomeView: View {
    @StateObject private var trainer = NumberTrainer()
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // 1. 背景
            SurrealTheme.mainBackground
            
            VStack(spacing: 0) {
                // 2. 标题
                Text("Chiffre")
                    .font(SurrealTheme.Typography.title(48))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                    .padding(.top, 60)
                
                Spacer()
                
                // 3. 核心卡片 (悬浮玻璃)
                ZStack {
                    // 底座
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .background(Color.white.opacity(0.2))
                        .frame(width: 280, height: 280)
                        .shadow(color: SurrealTheme.colors.deepIndigo.opacity(0.1), radius: 30, y: 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                    
                    // 内容
                    if trainer.isRevealed {
                        Text("\(trainer.currentNumber)")
                            .font(SurrealTheme.Typography.number(96))
                            .foregroundStyle(SurrealTheme.colors.deepIndigo)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "ear.and.waveform")
                            .font(.system(size: 80))
                            .foregroundStyle(SurrealTheme.colors.coral.opacity(0.8))
                            .transition(.scale.combined(with: .opacity))
                            .onTapGesture {
                                trainer.replay() // 点击图标重听
                            }
                    }
                }
                .onTapGesture {
                    // 点击卡片区域：如果在隐藏状态，则重听
                    if !trainer.isRevealed { trainer.replay() }
                }
                
                // 提示文字
                Text(trainer.isRevealed ? "C'est ça!" : "Écoutez...")
                    .font(SurrealTheme.Typography.body(18))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo.opacity(0.6))
                    .padding(.top, 30)
                
                Spacer()
                
                // 4. 底部控制栏
                HStack(spacing: 30) {
                    // 重听按钮
                    CircleButton(icon: "speaker.wave.2.fill") {
                        trainer.replay()
                    }
                    
                    // 主操作按钮 (揭晓/下一个)
                    Button {
                        if trainer.isRevealed {
                            trainer.generateNew()
                        } else {
                            trainer.reveal()
                        }
                    } label: {
                        Text(trainer.isRevealed ? "Suivant" : "Révéler")
                            .font(SurrealTheme.Typography.header(20))
                            .foregroundStyle(.white)
                            .frame(width: 150, height: 64)
                            .background(trainer.isRevealed ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.coral)
                            .clipShape(Capsule())
                            .shadow(color: (trainer.isRevealed ? SurrealTheme.colors.deepIndigo : SurrealTheme.colors.coral).opacity(0.4), radius: 10, y: 5)
                    }
                    
                    // 设置按钮
                    CircleButton(icon: "slider.horizontal.3") {
                        showSettings = true
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(trainer: trainer)
                .presentationDetents([.height(350)])
                .presentationCornerRadius(30)
        }
    }
}

// 辅助组件：圆形按钮
struct CircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(SurrealTheme.colors.deepIndigo)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .background(Color.white.opacity(0.4))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        }
    }
}