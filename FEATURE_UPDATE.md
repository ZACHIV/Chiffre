# 听力界面新增功能 / New Listening Features

## 更新日期 / Update Date
2026-01-06

## 新增听力模式 / New Listening Modes

已成功在听力界面增加以下三种新的听力练习模式：

### 1. 月份 (Mois) 🗓️
- **图标**: calendar.circle.fill
- **功能**: 随机播放法语月份名称
- **月份列表**: janvier, février, mars, avril, mai, juin, juillet, août, septembre, octobre, novembre, décembre
- **显示格式**: 首字母大写（如 "Janvier"）
- **语音格式**: 小写月份名称

### 2. 火车号 (Train) 🚆
- **图标**: tram.fill
- **功能**: 生成法国常见的火车号码格式
- **火车类型**: 
  - TGV (高速列车)
  - Intercités (城际列车)
  - TER (区域快车)
- **号码范围**: 1000-9999
- **显示格式**: "TGV 6523"
- **语音格式**: "TGV, 6523" (带停顿，便于听清)

### 3. 航班号 (Vol) ✈️
- **图标**: airplane
- **功能**: 生成国际航班号码
- **航空公司代码**:
  - AF (Air France - 法国航空)
  - EK (Emirates - 阿联酋航空)
  - BA (British Airways - 英国航空)
  - LH (Lufthansa - 汉莎航空)
  - KL (KLM - 荷兰皇家航空)
- **号码范围**: 10-9999
- **显示格式**: "AF 1234"
- **语音格式**: "A, F, 1234" (逐字母读航空公司代码)

## 修改的文件 / Modified Files

### 1. NumberTrainer.swift
- 在 `GameMode` 枚举中添加了三个新模式
- 为每个新模式添加了对应的图标
- 在 `generateNew()` 函数中实现了三种新模式的生成逻辑
- 优化了语音输出格式，确保听力清晰度

### 2. SettingsSheet.swift
- 在 `getModeDescription()` 函数中添加了三种新模式的描述文字
- 新模式会自动显示在设置界面的横向滚动胶囊中

## 使用方法 / How to Use

1. 打开应用后，点击底部的设置按钮（齿轮图标）
2. 在"Mode (模式)"区域，横向滑动查看所有模式
3. 选择以下任一新增模式：
   - **Mois (月份)**
   - **Train (火车号)**
   - **Vol (航班号)**
4. 点击"Révéler"按钮显示答案
5. 点击"Suivant"按钮进入下一题
6. 点击喇叭图标或卡片区域重新播放语音

## 技术细节 / Technical Details

- 所有新模式都使用法语 TTS (Text-to-Speech) 进行语音播放
- 语音内容经过优化，使用逗号分隔符增加停顿，提高听力清晰度
- 航班号的航空公司代码会逐字母朗读（如 "A, F" 而不是 "AF"）
- 火车号和航班号都会在类型/代码和数字之间添加停顿
- 月份名称使用标准法语发音

## 界面展示 / UI Display

所有新模式都完美集成到现有的 Surreal 主题设计中：
- ✨ 玻璃态卡片效果
- 🎨 深靛蓝和珊瑚色配色方案
- 🌊 流畅的动画过渡
- 📱 响应式布局

## 测试建议 / Testing Recommendations

在 Xcode 中打开项目并运行到 iOS 模拟器或真机：
1. 测试每种新模式的语音播放
2. 验证显示格式是否正确
3. 检查设置界面中的模式切换
4. 确认所有图标显示正常
