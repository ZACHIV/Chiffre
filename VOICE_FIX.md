# 语音选择功能修复说明

## 问题描述
之前的实现使用了硬编码的语音标识符（identifier），但这些标识符在不同的 iOS 系统版本或设备上可能不可用，导致所有语音都回退到默认的男声。

## 修复方案

### 1. 改用语音名称匹配
不再使用固定的 identifier，而是通过语音名称（name）来查找系统中可用的语音。

### 2. 多层回退机制
```swift
func getVoice() -> AVSpeechSynthesisVoice? {
    let allVoices = AVSpeechSynthesisVoice.speechVoices()
    
    // 第一层：精确匹配法语语音（名称 + 语言）
    if let voice = allVoices.first(where: { 
        $0.name == self.rawValue && $0.language.hasPrefix("fr")
    }) {
        return voice
    }
    
    // 第二层：只匹配名称
    if let voice = allVoices.first(where: { $0.name == self.rawValue }) {
        return voice
    }
    
    // 第三层：回退到默认法语语音
    return AVSpeechSynthesisVoice(language: "fr-FR")
}
```

### 3. 添加调试功能
在 App 启动时会在控制台打印所有可用的法语语音，方便调试：

```
=== 可用的法语语音 ===
[1] Thomas
    ID: com.apple.voice.compact.fr-FR.Thomas
    语言: fr-FR
    性别: 1
...
```

## 语音说明

### iOS 系统中常见的法语语音

1. **Thomas** - 男声，Compact 质量
2. **Amélie** - 女声，Enhanced 质量（需要下载）
3. **Daniel** - 男声，Premium 质量（需要下载）
4. **Marie** - 女声，Compact 质量

### 如何下载高质量语音

1. 打开 iPhone/iPad 设置
2. 辅助功能 → 朗读内容 → 语音
3. 选择"法语" 
4. 下载想要的语音（Amélie、Daniel 等）

## 测试方法

1. 运行 App
2. 查看 Xcode 控制台，会显示所有可用的法语语音
3. 打开设置，选择不同的语音
4. 点击"试听"按钮测试
5. 确认语音确实发生了变化（男声/女声）

## 修改的文件

- `SpeechManager.swift`
  - 移除了硬编码的 identifier
  - 添加了 `getVoice()` 方法
  - 添加了调试打印功能
  
- `ChiffreHomeView.swift`
  - 添加了 `onAppear` 调用调试函数

## 预期效果

- ✅ Amélie 和 Marie 应该是女声
- ✅ Thomas 和 Daniel 应该是男声
- ✅ 如果某个语音未下载，会自动回退到系统默认法语语音
- ✅ 控制台会显示所有可用语音的详细信息

## 注意事项

1. **首次使用**：如果选择了 Enhanced 或 Premium 语音但未下载，系统会自动使用默认语音
2. **下载语音**：建议在系统设置中预先下载 Amélie（女声）以获得最佳体验
3. **调试信息**：启动 App 时查看控制台，确认系统中有哪些可用语音

现在语音选择功能应该能正常工作了！🎉
