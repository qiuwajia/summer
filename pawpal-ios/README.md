# Summer · iPhone 原生 App（SwiftUI）

这是「Summer · 找个狗友一起遛狗」的原生 iOS 版本，用 SwiftUI 编写，最低支持 iOS 17。

## 当前状态（务必先读）

**已完成完整构建与运行时验证：**

- `xcodebuild` 模拟器构建：**BUILD SUCCEEDED**，零错误
- `xcodebuild` 真机构建（不签名）：**BUILD SUCCEEDED**，零错误
- iPhone 16 Pro 模拟器：安装 → 启动 → 首页正常渲染，无 crash log

Xcode 许可已同意，项目可直接在 Xcode 中打开运行。

### 曾经的"一打开就闪退"问题及修复

原因是脚本生成的 `project.pbxproj` 缺少两类关键信息，Xcode 加载工程时就内部断言崩溃（并非 App 本身崩溃）：

1. 每个 `XCBuildConfiguration` 缺少 `name` 字段 → `XCConfigurationList buildConfigurationNames` 拿到 nil 后断言
2. Swift 文件的 `path` 被扁平化到 `Summer/` 根目录，实际源文件在 `Models/`、`Views/` 等子目录 → 构建期找不到输入文件

`generate_project.py` 已修正这两处，并用真实 `xcodebuild` 验证通过。若日后新增/删除 `.swift` 文件，重新运行 `python3 generate_project.py` 即可同步工程文件。

## 如何运行

### 第一步：打开项目

```
open /Users/qiuwajia/WorkBuddy/2026-11-17-16-48-20/pawpal-ios/Summer.xcodeproj
```

或在 Finder 中双击 `Summer.xcodeproj`。

### 第二步：选设备并运行

在 Xcode 顶部设备选择器中选一个 iPhone 模拟器（或连接你的 iPhone），按 `⌘ + R` 运行。

- 真机运行：需要用你的 Apple ID 登录 Xcode（Xcode → Settings → Accounts → Add Apple ID），在 Signing 里选你的 Personal Team。免费 Apple ID 可在真机调试，安装包约 7 天过期，适合验证，但不能上架。
- 上架 App Store：需要加入 Apple Developer Program（¥688/年），另需隐私清单、隐私政策、年龄分级问卷等材料。

## 项目结构

```
Summer/
├── SummerApp.swift              App 入口
├── Models/
│   ├── Models.swift             Dog/Walk/Place/Friend/Chat 数据模型
│   ├── QuestModels.swift        任务/等级/徽章定义与状态
│   ├── SeedData.swift           演示数据
├── Repositories/
│   ├── Repository.swift         存储协议（云端替换点）
│   └── LocalRepository.swift    本地 JSON 持久化
├── ViewModels/
│   ├── AppState.swift           全局状态与业务入口
│   └── QuestEngine.swift        任务引擎
└── Views/
    ├── ContentView.swift        TabBar 与全局浮层
    ├── DiscoverView.swift       发现页
    ├── MapView.swift            地图页（MapKit 原生）
    ├── PostView.swift           发起遛狗局
    ├── MessagesView.swift       消息与聊天
    ├── ProfileView.swift        个人中心
    ├── QuestCenterView.swift    任务中心
    ├── WalkDetailSheet.swift    活动详情
    └── PlaceDetailSheet.swift   场所详情（在 ContentView.swift 内）
```

## 已实现功能

- **发现**：横幅、搜索入口、附近遛狗局、一键报名、推荐场所、附近狗友打招呼
- **地图**：原生 MapKit，狗狗与场所标注、附近活动卡片、发起入口
- **发起**：选狗狗/类型/地点/时间/人数/可见性，发布后写入本地
- **消息**：会话列表、聊天详情、发送消息（触发任务）
- **我的**：档案、狗狗、等级条、徽章数、设置菜单
- **任务系统**：5 步新手引导链、每日随机 3 任务（按日期种子）、等级、徽章、连续天数、完成飞入提示、升级弹窗

所有数据通过 `LocalRepository` 存到 App 的 Documents 目录（JSON），重启后保留。

## 如何接入后端（关键扩展点）

这是从"演示"变成"真实多人在线"的唯一改动点，界面层无需改动：

1. 新建一个遵守 `Repository` 协议的类（如 `CloudRepository`），实现 `load()` 与 `save()`，内部调用你的后端 API。
2. 在 `SummerApp.swift` 中把 `AppState()` 改为 `AppState(repository: CloudRepository())`。

`Repository.swift` 已定义好协议，`AppState` 只通过协议读写数据，因此替换实现不影响任何 View。

推荐后端能力：用户认证、遛狗局/报名/消息的实时同步（如 Supabase 或自建 WebSocket 服务）、推送通知（APNs）。

## 与网页版的差异

原生版使用真实 MapKit（网页版是手绘 SVG），并具备后续接入推送、相机、定位、Apple 登录的能力——这些正是通过 App Store 审核指南 4.2（"不能只是重新包装的网站"）所需要的原生特性。

## 素材说明

图片沿用网页版的 3 张（横幅、金毛、柴犬），已放入 Asset Catalog。其余头像用 emoji 与渐变实现，无需额外素材。
