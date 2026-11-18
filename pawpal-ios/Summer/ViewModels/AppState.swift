import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var data: AppData
    @Published var toast: String?
    @Published var feedback: QuestFeedback?
    @Published var showLevelUp: Level?

    private let repository: Repository

    init(repository: Repository = LocalRepository()) {
        self.repository = repository
        self.data = repository.load()
        QuestEngine.ensureDaily(&self.data.quest)
    }

    func persist() { repository.save(data) }

    // MARK: - 行为追踪入口

    func track(_ event: String) {
        let fb = QuestEngine.track(event: event, state: &data.quest, placeCount: SeedData.places.count)
        persist()
        if fb.hasContent {
            feedback = fb
            if let level = fb.leveledUpTo { showLevelUp = level }
        }
    }

    func showToast(_ message: String) {
        toast = message
    }

    // MARK: - 遛狗局

    func isJoined(_ id: String) -> Bool { data.joinedMine.contains(id) }

    func toggleJoin(_ id: String) {
        guard let walk = data.walks.first(where: { $0.id == id }) else { return }
        if let i = data.joinedMine.firstIndex(of: id) {
            data.joinedMine.remove(at: i)
            showToast("已取消报名")
        } else {
            data.joinedMine.append(id)
            showToast("🐾 报名成功！去和 \(walk.dog) 一起玩吧")
            track("joinWalk")
        }
        persist()
    }

    func publishWalk(title: String, dog: Dog, place: Place, timeText: String, max: Int, desc: String, typeLabel: String) {
        let newWalk = Walk(
            id: "w\(Int(Date().timeIntervalSince1970))",
            title: title, dog: dog.name, dogAvatar: dog.avatar,
            host: "\(dog.name)的家长", hostAvatar: dog.avatar,
            hostInfo: "\(dog.breed) · \(dog.tags.first ?? "")",
            status: "soon", statusText: "刚刚发布", place: place.name,
            time: timeText, dist: "0.0km", people: 0, max: max, joined: [],
            tags: [typeLabel, "新活动"],
            desc: desc.isEmpty ? "欢迎大家一起来！" : desc,
            placeEmoji: place.emoji
        )
        data.walks.insert(newWalk, at: 0)
        data.joinedMine.append(newWalk.id)
        track("publish")
        persist()
        showToast("🎉 遛狗局发布成功！")
    }

    // MARK: - 狗友打招呼（每日去重）

    func greetFriend(_ id: String) {
        guard let friend = SeedData.friends.first(where: { $0.id == id }) else { return }
        if data.quest.greeted[id] == true {
            showToast("你已经和 \(friend.dog) 打过招呼啦 🐾")
            return
        }
        data.quest.greeted[id] = true
        showToast("已向 \(friend.dog) 发送打招呼 🐾")
        track("greet")
        persist()
    }

    // MARK: - 消息

    func sendMessage(chatID: String, text: String) {
        guard let i = data.chats.firstIndex(where: { $0.id == chatID }) else { return }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        data.chats[i].msgs.append(
            ChatMessage(id: "m\(Int(Date().timeIntervalSince1970))", from: "me", text: text, time: f.string(from: Date()))
        )
        data.chats[i].time = f.string(from: Date())
        track("sendChat")
        persist()
    }

    func markRead(_ chatID: String) {
        guard let i = data.chats.firstIndex(where: { $0.id == chatID }) else { return }
        data.chats[i].unread = 0
        persist()
    }

    // MARK: - 任务导航

    func questProgress(_ def: QuestDef) -> (value: Int, done: Bool) {
        let isDaily = data.quest.dailyIds.contains(def.id)
        let value = isDaily ? (data.quest.daily[def.id] ?? 0) : (data.quest.onboard[def.id] ?? 0)
        return (value, value >= def.target)
    }

    var nextQuest: (def: QuestDef, isDaily: Bool, progress: Int)? {
        if let def = QuestDefs.onboard.first(where: { data.quest.onboardClaimed[$0.id] != true }) {
            return (def, false, data.quest.onboard[def.id] ?? 0)
        }
        if let def = QuestDefs.dailyPool.first(where: {
            data.quest.dailyIds.contains($0.id) && data.quest.dailyClaimed[$0.id] != true
        }) {
            return (def, true, data.quest.daily[def.id] ?? 0)
        }
        return nil
    }
}
