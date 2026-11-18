# Summer · 找个狗友一起遛狗

一个帮助狗主人在附近找到遛狗搭子、约着一起遛狗的产品。核心场景：发现附近的遛狗局、查看宠物友好场所、发起约遛、报名参与、狗友聊天，并通过游戏化任务帮助新人快速融入圈子。

本仓库包含两个版本：

| 目录 | 说明 | 技术栈 |
|---|---|---|
| [`pawpal/`](pawpal/) | Web 版（PWA，可添加到 iPhone 主屏幕） | 原生 HTML/CSS/JS，localStorage |
| [`pawpal-ios/`](pawpal-ios/) | iPhone 原生版 | SwiftUI，iOS 17+，MapKit |

## 功能

- **发现**：附近遛狗局、一键报名、推荐遛狗场所、附近狗友打招呼
- **地图**：原生版使用 MapKit 展示狗狗与场所标注
- **发起**：选择狗狗、活动类型、地点、时间、人数与可见性
- **消息**：会话列表与聊天
- **我的**：档案、狗狗、等级与徽章
- **任务系统**：5 步新手引导链、每日随机任务、等级、徽章、连续天数

## 快速开始

### Web 版

```bash
cd pawpal
python3 -m http.server 8000
```

浏览器打开 `http://localhost:8000`。详细说明见 [`pawpal/`](pawpal/)。

### iPhone 原生版

用 Xcode 打开 `pawpal-ios/Summer.xcodeproj`，选择模拟器或真机后按 `⌘ + R`。

首次使用 Xcode 前需同意许可协议：`sudo xcodebuild -license accept`。详细说明与后端接入点见 [`pawpal-ios/README.md`](pawpal-ios/README.md)。

## 架构说明

两个版本当前均使用本地持久化（Web 版 localStorage，原生版 JSON 文件），内置演示数据。原生版通过 `Repository` 协议抽象了数据层——接入真实后端时只需新增一个遵守该协议的实现并替换注入，界面层无需改动。

若要实现真实的多用户在线约遛，需要后端提供：用户认证、活动/报名/消息实时同步、推送通知。

## 素材

图片素材由 AI 生成，仅用于演示。
