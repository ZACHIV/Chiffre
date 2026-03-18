//
//  SpeechRecognizer.swift
//  Chiffre
//
//  Created by zachmacmini on 2025/12/26.
//


import Foundation
import Speech
import SwiftUI
import Combine  // <--- 必须添加这一行

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var error: String?
    
    // 动态获取当前语言的语音识别器
    private var speechRecognizer: SFSpeechRecognizer? {
        let locale = LanguageVoiceManager.shared.currentLanguage.localeIdentifier
        return SFSpeechRecognizer(locale: Locale(identifier: locale))
    }
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestPermission()
    }
    
    private func requestPermission() {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        // 用户允许，可以录音
                        break
                    case .denied, .restricted, .notDetermined:
                        self.error = "请在设置中开启语音权限"
                    @unknown default:
                        self.error = "未知权限状态"
                    }
                }
            }
        }
    
    func startRecording() {
            // 1. 状态检查：如果正在录音，直接返回
            if isRecording { return }
            
            // 2.【关键修复】权限检查：如果用户还没授权，绝对不能启动引擎，否则会闪退
            let authStatus = SFSpeechRecognizer.authorizationStatus()
            guard authStatus == .authorized else {
                self.error = "请先允许语音权限"
                print("❌ 错误：尝试在未授权状态下启动录音。当前状态: \(authStatus.rawValue)")
                // 如果是首次由于未决状态(notDetermined)，可以尝试再次请求，但不要启动引擎
                if authStatus == .notDetermined {
                    requestPermission()
                }
                return
            }
            
            // 3. 重置状态
            stopRecording() //以此确保干净的启动
            transcript = ""
            error = nil
            
            // 4. 配置 Audio Session
            let audioSession = AVAudioSession.sharedInstance()
            do {
                // 设置为录音模式，duckOthers 会压低背景音乐
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                self.error = "无法启动音频会话"
                print("Audio Session Error: \(error)")
                return
            }
            
            // 5. 创建识别请求
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            // 6. 检查音频输入节点 (InputNode)
            // 注意：访问 inputNode 是一个“危险”操作，如果引擎状态不对会崩溃，所以放在 try-catch 块或者确保引擎状态
            let inputNode = audioEngine.inputNode
            
            // 7. 配置识别任务
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                var isFinal = false
                
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcript = result.bestTranscription.formattedString
                    }
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    // 停止录音 (注意不要在回调里直接 stop，可能会死锁，最好异步)
                    self.stopRecording()
                }
            }
            
            // 8. 安装 Tap (监听麦克风数据)
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            // 再次防崩溃：如果采样率为0，说明硬件没准备好
            if recordingFormat.sampleRate == 0 {
                 self.error = "麦克风初始化失败"
                 return
            }
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            
            // 9. 启动引擎
            do {
                try audioEngine.start()
                DispatchQueue.main.async {
                    self.isRecording = true
                }
            } catch {
                self.error = "引擎启动失败"
                print("Engine Start Error: \(error)")
            }
        }
    
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
}
