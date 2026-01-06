# 月份日期逻辑修复

## 问题
之前的实现对所有月份都使用 1-31 的日期范围，导致出现不合理的日期，如：
- ❌ le 30 février（2月30日）
- ❌ le 31 avril（4月31日）
- ❌ le 31 septembre（9月31日）

## 修复方案

### 实现逻辑
现在根据每个月份的实际天数来生成日期：

```swift
let monthsWithDays: [(name: String, days: Int)] = [
    ("janvier", 31),    // 1月 - 31天
    ("février", 28),    // 2月 - 28天（简化处理）
    ("mars", 31),       // 3月 - 31天
    ("avril", 30),      // 4月 - 30天
    ("mai", 31),        // 5月 - 31天
    ("juin", 30),       // 6月 - 30天
    ("juillet", 31),    // 7月 - 31天
    ("août", 31),       // 8月 - 31天
    ("septembre", 30),  // 9月 - 30天
    ("octobre", 31),    // 10月 - 31天
    ("novembre", 30),   // 11月 - 30天
    ("décembre", 31)    // 12月 - 31天
]
```

### 生成流程
1. 随机选择一个月份（带天数信息）
2. 根据该月份的实际天数生成日期
3. 确保日期在合理范围内

### 月份天数规则

#### 31天的月份（7个）
- janvier（1月）
- mars（3月）
- mai（5月）
- juillet（7月）
- août（8月）
- octobre（10月）
- décembre（12月）

#### 30天的月份（4个）
- avril（4月）
- juin（6月）
- septembre（9月）
- novembre（11月）

#### 28天的月份（1个）
- février（2月）

### 关于闰年
为了简化逻辑，2月固定为 28 天，不考虑闰年的 29 天。
- ✅ 这样可以避免复杂的闰年计算
- ✅ 对于听力练习来说，28天已经足够
- ✅ 不会影响学习效果

## 示例输出

### 现在可能的日期（合理）
- ✅ le 28 février（2月28日）
- ✅ le 30 avril（4月30日）
- ✅ le 31 janvier（1月31日）
- ✅ le 15 septembre（9月15日）

### 不会再出现（不合理）
- ❌ le 29 février（2月29日 - 不考虑闰年）
- ❌ le 30 février（2月30日）
- ❌ le 31 avril（4月31日）
- ❌ le 31 juin（6月31日）
- ❌ le 31 septembre（9月31日）
- ❌ le 31 novembre（11月31日）

## 记忆口诀（法语）

### 30天的月份
> Trente jours ont septembre, avril, juin et novembre.
> （9月、4月、6月和11月有30天）

### 其他规则
- 除了2月，其他月份不是30天就是31天
- 2月最特殊，只有28天（闰年29天）

## 技术细节

### 数据结构
使用元组数组存储月份和天数的对应关系：
```swift
[(name: String, days: Int)]
```

### 随机选择
```swift
let selectedMonth = monthsWithDays.randomElement()!
let monthName = selectedMonth.name
let maxDay = selectedMonth.days
let day = Int.random(in: 1...maxDay)
```

### 优点
- ✅ 逻辑清晰，易于维护
- ✅ 数据和逻辑分离
- ✅ 生成的日期始终合理
- ✅ 不需要复杂的日期计算

## 测试建议

多次点击"Suivant"按钮，验证：
1. ✅ 2月的日期不会超过28
2. ✅ 4月、6月、9月、11月的日期不会超过30
3. ✅ 其他月份可以到31
4. ✅ 所有月份都至少有1号

现在月份模式会生成完全合理的日期了！🎉
