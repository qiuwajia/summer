import Foundation

/// 数据存储协议。当前由 LocalRepository 实现；
/// 接入云端时只需新增 CloudRepository 遵守此协议，在 AppState 中替换即可，界面层无需改动。
protocol Repository {
    func load() -> AppData
    func save(_ data: AppData)
}

struct AppData: Codable {
    var walks: [Walk]
    var chats: [Chat]
    var joinedMine: [String]
    var quest: QuestState
}
