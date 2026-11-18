import SwiftUI

struct QuestCenterView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss

    private var level: (current: Level, next: Level?) {
        QuestEngine.currentLevel(xp: app.data.quest.xp)
    }

    private var dailyDefs: [QuestDef] {
        QuestDefs.dailyPool.filter { app.data.quest.dailyIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    levelCard
                    questSection(title: "🌱 新手任务", subtitle: "带你快速融入圈子", defs: QuestDefs.onboard, isDaily: false)
                    questSection(title: "📅 今日任务", subtitle: "每天刷新", defs: dailyDefs, isDaily: true)
                    badgeSection
                    Text("完成任务赚取经验值，升级解锁更多标识。每日任务次日刷新，连续全清有惊喜 🐾")
                        .font(.system(size: 10.5)).foregroundColor(Theme.muted).multilineTextAlignment(.center)
                        .padding(.horizontal, 20).padding(.vertical, 18)
                }
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("任务中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }.foregroundColor(Theme.orange)
                }
            }
        }
    }

    private var levelCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Color.white.opacity(0.22)
                Text(level.current.icon).font(.system(size: 32))
            }.frame(width: 56, height: 56).clipShape(RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text("Lv.\(level.current.lv) · \(level.current.name)").font(.system(size: 16, weight: .heavy)).foregroundColor(.white)
                Text("累计 \(app.data.quest.xp) 经验值" + (app.data.quest.streak > 0 ? " · 连续 \(app.data.quest.streak) 天" : ""))
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.9))
                ProgressBar(fraction: level.next.map { Double(app.data.quest.xp) / Double($0.min) } ?? 1, height: 6)
                    .foregroundColor(.clear)
                    .padding(.top, 4)
                Text(level.next.map { "距下一级还差 \($0.min - app.data.quest.xp) 经验" } ?? "已达最高等级 👑")
                    .font(.system(size: 10)).foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(16)
        .background(LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 18).padding(.top, 14)
    }

    private func questSection(title: String, subtitle: String, defs: [QuestDef], isDaily: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.system(size: 14, weight: .bold))
                Text(subtitle).font(.system(size: 10.5)).foregroundColor(Theme.muted)
                Spacer()
                if isDaily {
                    let done = app.data.quest.dailyIds.filter { app.data.quest.dailyClaimed[$0] == true }.count
                    Text("\(done)/\(app.data.quest.dailyIds.count)").font(.system(size: 11, weight: .semibold)).foregroundColor(Theme.orange)
                }
            }
            .padding(.horizontal, 18).padding(.top, 18).padding(.bottom, 10)

            VStack(spacing: 0) {
                ForEach(defs) { def in
                    let progress = app.questProgress(def)
                    Button(action: {
                        if !progress.done { app.showToast("前往完成：\(def.title)") }
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                progress.done ? Theme.greenSoft : Theme.orangeSoft
                                Image(systemName: progress.done ? "checkmark" : def.icon)
                                    .font(.system(size: 20)).foregroundColor(progress.done ? Theme.green : Theme.orangeDeep)
                            }.frame(width: 42, height: 42).clipShape(RoundedRectangle(cornerRadius: 13))
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(def.title).font(.system(size: 13.5, weight: .bold))
                                    Spacer()
                                    Text("+\(def.point) XP").font(.system(size: 10, weight: .bold))
                                        .foregroundColor(progress.done ? Theme.green : Theme.orangeDeep)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(progress.done ? Theme.greenSoft : Theme.orangeSoft).clipShape(Capsule())
                                }
                                Text(def.desc).font(.system(size: 11)).foregroundColor(Theme.muted)
                                HStack(spacing: 10) {
                                    ProgressBar(fraction: min(Double(progress.value) / Double(def.target), 1), height: 5)
                                    Text(progress.done ? "✓ 已完成" : "\(progress.value)/\(def.target)")
                                        .font(.system(size: 10, weight: .semibold)).foregroundColor(Theme.ink2)
                                }
                            }
                        }
                        .padding(14)
                        .opacity(progress.done ? 0.7 : 1)
                    }
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.line), alignment: .bottom)
                }
            }
            .background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line, lineWidth: 1))
            .padding(.horizontal, 18)
        }
    }

    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("🏅 徽章墙").font(.system(size: 14, weight: .bold))
                Text("\(app.data.quest.badges.count)/\(QuestDefs.badges.count) 已解锁").font(.system(size: 10.5)).foregroundColor(Theme.muted)
            }
            .padding(.horizontal, 18).padding(.top, 18).padding(.bottom, 10)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(QuestDefs.badges) { badge in
                    let owned = app.data.quest.badges.contains(badge.id)
                    VStack(spacing: 4) {
                        Text(owned ? badge.icon : "🔒").font(.system(size: 28)).opacity(owned ? 1 : 0.5)
                        Text(badge.name).font(.system(size: 11.5, weight: .bold))
                        Text(badge.desc).font(.system(size: 9)).foregroundColor(Theme.muted).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
                    .opacity(owned ? 1 : 0.6)
                }
            }.padding(.horizontal, 18)
        }
    }
}
