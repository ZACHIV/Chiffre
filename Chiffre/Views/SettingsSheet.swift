//
//  SettingsSheet.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/25.
//


import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var trainer: NumberTrainer
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.98, blue: 0.97).ignoresSafeArea() // 米色纸张背景
            
            VStack(spacing: 30) {
                // 把手
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 15)
                
                Text("Difficulté")
                    .font(SurrealTheme.Typography.header(24))
                    .foregroundStyle(SurrealTheme.colors.deepIndigo)
                
                VStack(spacing: 15) {
                    HStack {
                        Text("Portée (范围): 0 - \(trainer.maxRange)")
                            .font(SurrealTheme.Typography.body(18))
                            .foregroundStyle(SurrealTheme.colors.deepIndigo)
                            .monospacedDigit()
                        Spacer()
                    }
                    
                    Slider(value: Binding(
                        get: { Double(trainer.maxRange) },
                        set: { trainer.maxRange = Int($0) }
                    ), in: 10...9999, step: 10)
                    .tint(SurrealTheme.colors.coral)
                }
                .padding(.horizontal, 30)
                
                // 快速预设
                HStack(spacing: 12) {
                    PresetButton(label: "简单 (10)", value: 10, trainer: trainer)
                    PresetButton(label: "中等 (100)", value: 100, trainer: trainer)
                    PresetButton(label: "困难 (1000)", value: 1000, trainer: trainer)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

struct PresetButton: View {
    let label: String
    let value: Int
    @ObservedObject var trainer: NumberTrainer
    
    var isSelected: Bool {
        trainer.maxRange == value
    }
    
    var body: some View {
        Button {
            trainer.maxRange = value
            trainer.generateNew(speakNow: false) // 切换难度后重置
        } label: {
            Text(label)
                .font(.caption).bold()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? SurrealTheme.colors.deepIndigo : Color.black.opacity(0.05))
                .foregroundStyle(isSelected ? .white : SurrealTheme.colors.deepIndigo)
                .clipShape(Capsule())
        }
    }
}