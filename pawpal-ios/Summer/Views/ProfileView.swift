import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var app: AppState
    let onOpenQuest: () -> Void

    private var level: (current: Level, next: Level?) {
        QuestEngine.currentLevel(xp: app.data.quest.xp)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                    HStack(spacing: 14) {
                        Image("dog-golden").resizable().scaledToFill()
                            .frame(width: 62, height: 62).clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 3))
                        VStack(alignment: .leading) {
                            Text("豆包的家长").font(.system(size: 19, weight: .heavy)).foregroundColor(.white)
                            Text("📍 上海 · 徐汇滨江").font(.system(size: 12)).foregroundColor(.white.opacity(0.9))
                            HStack(spacing: 22) {
                                stat("\(SeedData.myDogs.count)", "我的狗狗")
                                stat("\(app.data.joinedMine.count)", "参与活动")
                                stat("\(SeedData.friends.count)", "狗友")
                            }.padding(.top, 8)
                        }
                    }.padding(18)
                    Text("🐾").font(.system(size: 100)).opacity(0.12).offset(x: 240, y: 30)
                }
                .frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 20).padding(.top, 2)

                Button(action: onOpenQuest) {
                    HStack(spacing: 12) {
                        ZStack {
                            LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                            Text(level.current.icon).font(.system(size: 24))
                        }.frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 13))
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Lv.\(level.current.lv) \(level.current.name)").font(.system(size: 13, weight: .bold))
                                Spacer()
                                Text("任务中心 ›").font(.system(size: 10.5, weight: .semibold)).foregroundColor(Theme.orange)
                            }
                            ProgressBar(fraction: level.next.map { Double(app.data.quest.xp) / Double($0.min) } ?? 1, height: 5)
                            Text("\(app.data.quest.xp) 经验" + (level.next.map { " · 距升级还差 \($0.min - app.data.quest.xp)" } ?? " · 已满级"))
                                .font(.system(size: 9.5)).foregroundColor(Theme.muted)
                        }
                    }
                    .padding(13).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line, lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.top, 16)

                SectionTitle(title: "🐕 我的毛孩子", action: "+ 添加", onTap: { app.showToast("添加狗狗") })
                    .padding(.top, 20)
                HStack(spacing: 12) {
                    ForEach(SeedData.myDogs) { dog in
                        HStack(spacing: 10) {
                            AvatarView(avatar: dog.avatar, size: 46, corner: 13)
                            VStack(alignment: .leading) {
                                Text(dog.name).font(.system(size: 13, weight: .bold))
                                Text("\(dog.breed) · \(dog.age)").font(.system(size: 10.5)).foregroundColor(Theme.muted)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                        .background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line, lineWidth: 1))
                    }
                }.padding(.horizontal, 20).padding(.top, 4)

                VStack(spacing: 0) {
                    menu("🎯", "任务与徽章", "\(app.data.quest.badges.count) 枚徽章", onOpenQuest)
                    menu("📢", "我发起的活动", "\(app.data.walks.filter { $0.host.contains("家长") }.count) 场", { app.showToast("我发起的遛狗局") })
                    menu("🐾", "我报名的活动", "\(app.data.joinedMine.count) 场", { app.showToast("我报名的活动") })
                    menu("🗺️", "遛狗足迹", "12.6 km", { app.showToast("遛狗足迹") })
                    menu("🏅", "成就徽章", "\(app.data.quest.badges.count)/\(QuestDefs.badges.count)", onOpenQuest)
                }
                .background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line, lineWidth: 1))
                .padding(.horizontal, 20).padding(.top, 20)

                VStack(spacing: 0) {
                    menu("🔒", "隐私与安全", "", { app.showToast("隐私设置：模糊距离、家庭隐私圈") })
                    menu("🔔", "消息通知", "", { app.showToast("消息通知设置") })
                    menu("⚙️", "设置", "", { app.showToast("Summer · 原生版本 v1.0") })
                }
                .background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line, lineWidth: 1))
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 20)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack { Text(value).font(.system(size: 16, weight: .heavy)).foregroundColor(.white); Text(label).font(.system(size: 10)).foregroundColor(.white.opacity(0.85)) }
    }

    private func menu(_ icon: String, _ title: String, _ value: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack { Theme.orangeSoft; Text(icon).font(.system(size: 17)) }
                    .frame(width: 32, height: 32).clipShape(RoundedRectangle(cornerRadius: 10))
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.ink)
                Spacer()
                Text(value).font(.system(size: 12)).foregroundColor(Theme.muted)
                Text("›").foregroundColor(Theme.muted)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
        .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.line), alignment: .bottom)
    }
}
