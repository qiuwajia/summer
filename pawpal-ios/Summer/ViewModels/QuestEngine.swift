import Foundation

enum DateUtils {
    static func dayKey(date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}

/// 本次行为触发的界面反馈
struct QuestFeedback {
    var gainedXP: Int = 0
    var completedTitles: [String] = []
    var unlockedBadges: [Badge] = []
    var leveledUpTo: Level?

    var hasContent: Bool {
        gainedXP > 0 || !unlockedBadges.isEmpty || leveledUpTo != nil
    }
}

enum QuestEngine {
    // MARK: - 每日日期与随机

    /// 按日期种子确定性伪随机：同一天结果固定，跨天自动更换
    static func seededPick(seed: String, count: Int) -> [String] {
        var s: UInt64 = 0
        for byte in seed.utf8 { s = (s &* 31 &+ UInt64(byte)) & 0xFFFFFFFF }
        func next() -> UInt64 {
            s = (s &* 1664525 &+ 1013904223) & 0xFFFFFFFF
            return s
        }
        var pool = QuestDefs.dailyPool
        for i in stride(from: pool.count - 1, to: 0, by: -1) {
            let j = Int(next() % UInt64(i + 1))
            pool.swapAt(i, j)
        }
        return Array(pool.prefix(count).map { $0.id })
    }

    static func ensureDaily(_ state: inout QuestState) {
        let today = DateUtils.dayKey()
        if state.dailyDate != today || state.dailyIds.isEmpty {
            state.dailyDate = today
            state.daily = [:]
            state.dailyClaimed = [:]
            state.dailyIds = seededPick(seed: today, count: 3)
            state.greeted = [:]
        }
    }

    static func currentLevel(xp: Int) -> (current: Level, next: Level?) {
        var current = QuestDefs.levels[0]
        for l in QuestDefs.levels where xp >= l.min { current = l }
        let next = QuestDefs.levels.first { $0.min > xp }
        return (current, next)
    }

    // MARK: - 行为追踪

    /// 追踪一次行为，原地更新状态并返回界面反馈
    @discardableResult
    static func track(event: String, state: inout QuestState, placeCount: Int = 4) -> QuestFeedback {
        ensureDaily(&state)
        var feedback = QuestFeedback()

        // 累计行为统计（徽章判定依据）
        let statKey: String? = [
            "viewWalk": "viewWalk", "greet": "greet", "viewPlace": "viewPlace",
            "joinWalk": "join", "sendChat": "chat", "publish": "publish", "viewMap": "viewMap"
        ][event]
        if let k = statKey { state.stats[k, default: 0] += 1 }

        func apply(_ defs: [QuestDef], progress: inout [String: Int], claimed: inout [String: Bool], dailyOnly: Bool) {
            for def in defs where def.event == event {
                if dailyOnly && !state.dailyIds.contains(def.id) { continue }
                let current = min((progress[def.id] ?? 0) + 1, def.target)
                progress[def.id] = current
                if current >= def.target && claimed[def.id] != true {
                    claimed[def.id] = true
                    state.xp += def.point
                    feedback.gainedXP += def.point
                    feedback.completedTitles.append(def.title)
                }
            }
        }

        apply(QuestDefs.onboard, progress: &state.onboard, claimed: &state.onboardClaimed, dailyOnly: false)
        apply(QuestDefs.dailyPool, progress: &state.daily, claimed: &state.dailyClaimed, dailyOnly: true)

        checkDailyComplete(&state, feedback: &feedback)
        checkBadges(&state, feedback: &feedback, placeCount: placeCount)
        checkLevelUp(&state, feedback: &feedback)
        return feedback
    }

    // MARK: - 徽章 / 等级 / 连续天数

    private static func checkBadges(_ state: inout QuestState, feedback: inout QuestFeedback, placeCount: Int) {
        func unlock(_ id: String) {
            guard !state.badges.contains(id),
                  let badge = QuestDefs.badges.first(where: { $0.id == id }) else { return }
            state.badges.append(id)
            feedback.unlockedBadges.append(badge)
        }
        if QuestDefs.onboard.allSatisfy({ state.onboardClaimed[$0.id] == true }) { unlock("b_ice") }
        if (state.stats["greet"] ?? 0) >= 10 { unlock("b_social") }
        if (state.stats["publish"] ?? 0) >= 1 { unlock("b_host") }
        if (state.stats["join"] ?? 0) >= 5 { unlock("b_active") }
        if (state.stats["viewPlace"] ?? 0) >= placeCount { unlock("b_scout") }
        if state.streak >= 3 { unlock("b_streak") }
    }

    private static func checkLevelUp(_ state: inout QuestState, feedback: inout QuestFeedback) {
        let level = currentLevel(xp: state.xp).current
        if level.lv > state.levelShown {
            state.levelShown = level.lv
            feedback.leveledUpTo = level
        }
    }

    private static func checkDailyComplete(_ state: inout QuestState, feedback: inout QuestFeedback) {
        let allDone = !state.dailyIds.isEmpty && state.dailyIds.allSatisfy { state.dailyClaimed[$0] == true }
        guard allDone, state.lastFullDaily != state.dailyDate else { return }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        let diff = state.lastFullDaily.isEmpty ? 999 : Int(
            fmt.date(from: state.dailyDate)!.timeIntervalSince(fmt.date(from: state.lastFullDaily)!)
        ) / 86400
        state.streak = (diff == 1) ? state.streak + 1 : 1
        state.lastFullDaily = state.dailyDate
    }
}
