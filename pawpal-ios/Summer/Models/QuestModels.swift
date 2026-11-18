import Foundation

// MARK: - 任务定义

struct QuestDef: Identifiable, Codable, Equatable {
    let id: String
    let icon: String
    let title: String
    let desc: String
    let point: Int
    let event: String
    let target: Int
    let goto: String

    var isOnboard: Bool { id.hasPrefix("ob") }
}

struct Level: Codable, Equatable {
    let lv: Int
    let name: String
    let min: Int
    let icon: String
}

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let icon: String
    let name: String
    let desc: String
}

// MARK: - 任务持久化状态

struct QuestState: Codable {
    var xp: Int = 0
    var onboard: [String: Int] = [:]
    var onboardClaimed: [String: Bool] = [:]
    var dailyDate: String = ""
    var dailyIds: [String] = []
    var daily: [String: Int] = [:]
    var dailyClaimed: [String: Bool] = [:]
    var badges: [String] = []
    var stats: [String: Int] = [:]
    var streak: Int = 0
    var lastFullDaily: String = ""
    var levelShown: Int = 1
    var greeted: [String: Bool] = [:]
}

struct QuestDefs {
    static let onboard: [QuestDef] = [
        QuestDef(id: "ob1", icon: "magnifyingglass", title: "逛逛附近", desc: "点开一个遛狗局看看大家在玩什么", point: 10, event: "viewWalk", target: 1, goto: "discover"),
        QuestDef(id: "ob2", icon: "hand.wave", title: "认识邻居", desc: "向一位附近的狗友打个招呼", point: 10, event: "greet", target: 1, goto: "discover"),
        QuestDef(id: "ob3", icon: "leaf", title: "踩点场地", desc: "查看一个宠物友好的遛狗场所", point: 10, event: "viewPlace", target: 1, goto: "discover"),
        QuestDef(id: "ob4", icon: "pawprint", title: "首次约遛", desc: "报名一场附近的遛狗局", point: 20, event: "joinWalk", target: 1, goto: "discover"),
        QuestDef(id: "ob5", icon: "bubble.left", title: "打开话匣", desc: "给狗友发送一条消息", point: 20, event: "sendChat", target: 1, goto: "messages"),
    ]

    static let dailyPool: [QuestDef] = [
        QuestDef(id: "dq_explore", icon: "binoculars", title: "探索达人", desc: "浏览 3 个遛狗局", point: 15, event: "viewWalk", target: 3, goto: "discover"),
        QuestDef(id: "dq_social", icon: "person.2", title: "社交蝴蝶", desc: "向 2 位狗友打招呼", point: 15, event: "greet", target: 2, goto: "discover"),
        QuestDef(id: "dq_join", icon: "figure.walk", title: "活力玩家", desc: "报名 1 场遛狗局", point: 20, event: "joinWalk", target: 1, goto: "discover"),
        QuestDef(id: "dq_chat", icon: "bubble.left.and.bubble.right", title: "闲聊高手", desc: "发送 2 条消息", point: 15, event: "sendChat", target: 2, goto: "messages"),
        QuestDef(id: "dq_place", icon: "map", title: "场地勘探", desc: "查看 2 个遛狗场所", point: 15, event: "viewPlace", target: 2, goto: "discover"),
        QuestDef(id: "dq_host", icon: "megaphone", title: "组织者", desc: "发起 1 场遛狗局", point: 25, event: "publish", target: 1, goto: "post"),
        QuestDef(id: "dq_map", icon: "map.circle", title: "地图达人", desc: "打开地图 3 次", point: 10, event: "viewMap", target: 3, goto: "map"),
    ]

    static let levels: [Level] = [
        Level(lv: 1, name: "初来乍到", min: 0, icon: "🌱"),
        Level(lv: 2, name: "熟门熟路", min: 80, icon: "🐕"),
        Level(lv: 3, name: "圈子红人", min: 180, icon: "⭐"),
        Level(lv: 4, name: "遛狗老炮", min: 350, icon: "🏆"),
        Level(lv: 5, name: "狗狗大使", min: 600, icon: "👑"),
    ]

    static let badges: [Badge] = [
        Badge(id: "b_ice", icon: "🧊", name: "破冰者", desc: "完成全部新手任务"),
        Badge(id: "b_social", icon: "💞", name: "社交达人", desc: "累计打招呼 10 次"),
        Badge(id: "b_host", icon: "📣", name: "组织者", desc: "发起第一场遛狗局"),
        Badge(id: "b_active", icon: "🔥", name: "活动家", desc: "累计报名 5 场遛狗局"),
        Badge(id: "b_scout", icon: "🔭", name: "探险家", desc: "查看全部遛狗场所"),
        Badge(id: "b_streak", icon: "📅", name: "坚持不懈", desc: "连续 3 天完成每日任务"),
    ]
}
