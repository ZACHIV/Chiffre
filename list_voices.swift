#!/usr/bin/env swift
import AVFoundation

print("=== 所有可用的法语语音 ===\n")

let frenchVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("fr") }

for (index, voice) in frenchVoices.enumerated() {
    print("[\(index + 1)] 名称: \(voice.name)")
    print("    标识符: \(voice.identifier)")
    print("    语言: \(voice.language)")
    print("    质量: \(voice.quality.rawValue)")
    print("    性别: \(voice.gender.rawValue)")
    print("")
}

print("总共找到 \(frenchVoices.count) 个法语语音")
