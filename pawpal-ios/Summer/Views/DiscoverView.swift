import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var app: AppState
    let onOpenWalk: (Walk) -> Void
    let onOpenPlace: (Place) -> Void
    let onOpenQuest: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                searchRow
                locationStrip
                heroBanner
                questBanner
                SectionTitle(title: "🐾 附近的遛狗局", action: "查看地图", onTap: {})
                walkList
                SectionTitle(title: "🌿 推荐遛狗点", action: "全部", onTap: {})
                placesRow
                SectionTitle(title: "👋 附近狗友", action: "更多", onTap: {})
                friendsRow
                Color.clear.frame(height: 20)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            HStack(spacing: 9) {
                ZStack {
                    LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text("🐾").font(.system(size: 22))
                }
                .frame(width: 38, height: 38).clipShape(RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Summer").font(.system(size: 19, weight: .heavy))
                    Text("WALK WITH DOGS").font(.system(size: 9, weight: .bold)).tracking(2).foregroundColor(Theme.muted)
                }
            }
            Spacer()
            Button(action: onOpenQuest) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "target").font(.system(size: 18)).foregroundColor(Theme.orange)
                    if app.feedback?.hasContent == true {
                        Circle().fill(Theme.orange).frame(width: 7, height: 7).offset(x: 3, y: -3)
                    }
                }
                .frame(width: 38, height: 38).background(.white)
                .clipShape(Circle()).overlay(Circle().stroke(Theme.line, lineWidth: 1))
            }
            Button(action: { app.showToast("暂无新通知") }) {
                Image(systemName: "bell").font(.system(size: 18)).foregroundColor(Theme.ink)
                    .frame(width: 38, height: 38).background(.white)
                    .clipShape(Circle()).overlay(Circle().stroke(Theme.line, lineWidth: 1))
            }
            Image("dog-golden").resizable().scaledToFill()
                .frame(width: 40, height: 40).clipShape(Circle())
        }
        .padding(.horizontal, 20).padding(.top, 6).padding(.bottom, 12)
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            Button(action: { app.showToast("搜索功能：可搜索遛狗点、狗友、活动") }) {
                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass").foregroundColor(Theme.muted)
                    Text("搜索遛狗点 / 狗友 / 活动").font(.system(size: 14)).foregroundColor(Theme.muted)
                }
                .frame(height: 42).padding(.horizontal, 14).frame(maxWidth: .infinity)
                .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
            }
            Button(action: { app.showToast("筛选：距离 / 犬型 / 时间") }) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text("筛选").font(.system(size: 13, weight: .bold))
                }
                .frame(height: 42).padding(.horizontal, 14).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
            }
        }
        .padding(.horizontal, 20).padding(.bottom, 12)
    }

    private var locationStrip: some View {
        HStack(spacing: 7) {
            Image(systemName: "location.fill").foregroundColor(Theme.orange).font(.system(size: 12))
            Text("当前位置 · 徐汇滨江").font(.system(size: 12.5, weight: .semibold)).foregroundColor(Theme.ink2)
            Spacer()
            Text("切换 ›").font(.system(size: 12, weight: .bold)).foregroundColor(Theme.orange)
        }
        .padding(.horizontal, 20).padding(.bottom, 12)
    }

    private var heroBanner: some View {
        Button(action: { if let w = app.data.walks.first { onOpenWalk(w) } }) {
            ZStack(alignment: .leading) {
                Image("hero").resizable().scaledToFill().frame(height: 150)
                Color.black.opacity(0.28)
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日热门").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 9).padding(.vertical, 3)
                        .background(.white.opacity(0.2)).clipShape(Capsule())
                    Text("找个狗友\n一起撒欢吧").font(.system(size: 20, weight: .heavy)).foregroundColor(.white)
                    Text("附近 12 场遛狗局正在等你加入").font(.system(size: 11.5)).foregroundColor(.white.opacity(0.92))
                }
                .padding(.leading, 18)
                VStack { Spacer(); HStack { Spacer()
                    Text("去看看 ›").font(.system(size: 11, weight: .bold)).foregroundColor(Theme.orangeDeep)
                        .padding(.horizontal, 13).padding(.vertical, 7).background(.white).clipShape(Capsule())
                        .padding(14)
                } }
            }
            .frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .padding(.horizontal, 20).padding(.bottom, 18)
    }

    private var questBanner: some View {
        Group {
            if let next = app.nextQuest {
                let lv = QuestEngine.currentLevel(xp: app.data.quest.xp)
                Button(action: onOpenQuest) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(lv.current.icon) Lv.\(lv.current.lv) \(lv.current.name)")
                                .font(.system(size: 13, weight: .bold)).foregroundColor(Theme.ink)
                            Spacer()
                            if let n = lv.next {
                                Text("再得 \(n.min - app.data.quest.xp) 经验升级")
                                    .font(.system(size: 10.5, weight: .semibold)).foregroundColor(Theme.orangeDeep)
                            }
                        }
                        ProgressBar(fraction: lv.next.map { Double(app.data.quest.xp) / Double($0.min) } ?? 1)
                            .padding(.top, 9)
                        HStack(spacing: 10) {
                            ZStack {
                                Color.white
                                Image(systemName: next.def.icon).font(.system(size: 20)).foregroundColor(Theme.orangeDeep)
                            }
                            .frame(width: 38, height: 38).clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(next.isDaily ? "今日任务" : "新手任务") · \(next.def.title)")
                                    .font(.system(size: 12.5, weight: .bold)).foregroundColor(Theme.ink)
                                Text("\(next.def.desc) (\(next.progress)/\(next.def.target))")
                                    .font(.system(size: 10.5)).foregroundColor(Theme.ink2).lineLimit(1)
                            }
                            Spacer()
                            Text("去做 ›").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                                .padding(.horizontal, 12).padding(.vertical, 7).background(Theme.orange).clipShape(Capsule())
                        }
                        .padding(.top, 12)
                    }
                    .padding(14)
                    .background(LinearGradient(colors: [Color(hex: "FFF6EF"), Color(hex: "FFEADB")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "FFDCC6"), lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.bottom, 18)
            }
        }
    }

    private var walkList: some View {
        VStack(spacing: 13) {
            ForEach(app.data.walks) { walk in
                WalkCard(walk: walk, onTap: { onOpenWalk(walk) })
            }
        }
        .padding(.horizontal, 20)
    }

    private var placesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SeedData.places) { place in
                    Button(action: { onOpenPlace(place) }) {
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                LinearGradient(colors: [Color(hex: "BFE3C8"), Color(hex: "8FC9A6")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                Text(place.emoji).font(.system(size: 52))
                                    .frame(maxWidth: .infinity).frame(height: 96)
                                Text(place.badge).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                    .padding(.horizontal, 9).padding(.vertical, 4).background(.black.opacity(0.35))
                                    .clipShape(Capsule()).padding(9)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.name).font(.system(size: 14, weight: .bold)).foregroundColor(Theme.ink)
                                Text("📍 \(place.addr)").font(.system(size: 11)).foregroundColor(Theme.muted).lineLimit(1)
                                HStack(spacing: 5) {
                                    ForEach(place.feats, id: \.self) { f in
                                        Text(f).font(.system(size: 9.5, weight: .semibold)).foregroundColor(Theme.green)
                                            .padding(.horizontal, 7).padding(.vertical, 3).background(Theme.greenSoft).clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }.padding(.top, 6)
                            }.padding(12)
                        }
                        .frame(width: 210).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var friendsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(SeedData.friends) { friend in
                    Button(action: { app.greetFriend(friend.id) }) {
                        VStack(spacing: 5) {
                            GradientAvatar(emoji: friend.emoji, colors: friend.color, size: 60)
                                .overlay(Circle().stroke(Theme.orange, lineWidth: 2.5))
                            Text(friend.dog).font(.system(size: 11, weight: .bold)).foregroundColor(Theme.ink)
                            Text(friend.dist).font(.system(size: 10)).foregroundColor(Theme.muted)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct WalkCard: View {
    @EnvironmentObject var app: AppState
    let walk: Walk
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(avatar: walk.dogAvatar, size: 54, corner: 16)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .top) {
                        Text(walk.title).font(.system(size: 15, weight: .bold)).foregroundColor(Theme.ink)
                        Spacer(minLength: 4)
                        Text(walk.statusText).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(walk.status == "live" ? Theme.green : Theme.orange).clipShape(Capsule())
                    }
                    Text("by \(walk.host) · \(walk.hostInfo)").font(.system(size: 12)).foregroundColor(Theme.muted)
                }
            }
            HStack(spacing: 12) {
                Label(walk.place, systemImage: "location.fill")
                Label(walk.time, systemImage: "clock")
                Label(walk.dist, systemImage: "location")
            }
            .font(.system(size: 12)).foregroundColor(Theme.ink2).padding(.top, 13)
            HStack(spacing: 6) {
                ForEach(walk.tags, id: \.self) { t in
                    Text(t).font(.system(size: 10.5, weight: .semibold)).foregroundColor(Theme.ink2)
                        .padding(.horizontal, 9).padding(.vertical, 4).background(Color(hex: "F4F1EA")).clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }.padding(.top, 10)
            HStack {
                HStack(spacing: -7) {
                    ForEach(walk.joined.prefix(3), id: \.self) { fid in
                        if let f = SeedData.friends.first(where: { $0.id == fid }) {
                            GradientAvatar(emoji: f.emoji, colors: f.color, size: 26)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                        }
                    }
                    if app.isJoined(walk.id) {
                        ZStack { Theme.orange; Text("🐾").font(.system(size: 13)) }
                            .frame(width: 26, height: 26).clipShape(Circle()).overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
                Text("\(walk.people + (app.isJoined(walk.id) ? 1 : 0))/\(walk.max) 只狗狗")
                    .font(.system(size: 11)).foregroundColor(Theme.muted).padding(.leading, 6)
                Spacer()
                Button(action: { app.toggleJoin(walk.id) }) {
                    Text(app.isJoined(walk.id) ? "✓ 已报名" : "我也去")
                        .font(.system(size: 12.5, weight: .bold)).foregroundColor(app.isJoined(walk.id) ? Theme.green : .white)
                        .padding(.horizontal, 17).padding(.vertical, 9)
                        .background(app.isJoined(walk.id) ? Theme.greenSoft : Theme.orange)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 13)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.line).opacity(0.7), alignment: .top)
            .padding(.top, 12)
        }
        .padding(15).background(.white).clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.line, lineWidth: 1))
        .onTapGesture(perform: onTap)
    }
}
