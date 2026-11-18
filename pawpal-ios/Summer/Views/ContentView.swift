import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppState
    @State private var tab = 0
    @State private var detailWalk: Walk?
    @State private var detailPlace: Place?
    @State private var showPost = false
    @State private var showQuest = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tab) {
                DiscoverView(onOpenWalk: { detailWalk = $0 }, onOpenPlace: { detailPlace = $0 }, onOpenQuest: { showQuest = true })
                    .tabItem { Label("发现", systemImage: "house") }.tag(0)
                MapView(onOpenWalk: { detailWalk = $0 }, onOpenPlace: { detailPlace = $0 })
                    .tabItem { Label("地图", systemImage: "map") }.tag(1)
                Color.clear.tabItem { Label("发起", systemImage: "plus.circle.fill") }.tag(2)
                MessagesView().tabItem { Label("消息", systemImage: "bubble.left") }.tag(3)
                ProfileView(onOpenQuest: { showQuest = true })
                    .tabItem { Label("我的", systemImage: "person") }.tag(4)
            }
            .onChange(of: tab) { _, newTab in
                if newTab == 2 {
                    showPost = true
                    tab = 0
                }
            }

            // toast
            if let toast = app.toast {
                Text(toast).font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 20).padding(.vertical, 11).background(Theme.ink)
                    .clipShape(Capsule()).padding(.bottom, 90)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { app.toast = nil }
                    }
            }

            // quest feedback banner
            if let fb = app.feedback, fb.hasContent {
                questFeedbackView(fb)
                    .padding(.horizontal, 14).padding(.bottom, 90)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { app.feedback = nil }
                    }
            }
        }
        .sheet(item: $detailWalk) { walk in
            WalkDetailSheet(walk: walk, onOpenChat: { detailWalk = nil }).environmentObject(app)
        }
        .sheet(item: $detailPlace) { place in
            PlaceDetailSheet(place: place).environmentObject(app)
        }
        .sheet(isPresented: $showPost) { PostView().environmentObject(app) }
        .sheet(isPresented: $showQuest) { QuestCenterView().environmentObject(app) }
        .overlay {
            if let level = app.showLevelUp {
                levelUpOverlay(level).onTapGesture { app.showLevelUp = nil }
            }
        }
    }

    private func questFeedbackView(_ fb: QuestFeedback) -> some View {
        HStack(spacing: 12) {
            ZStack {
                LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: fb.unlockedBadges.isEmpty ? "star.fill" : "rosette")
                    .font(.system(size: 22)).foregroundColor(.white)
            }.frame(width: 42, height: 42).clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                if let badge = fb.unlockedBadges.first {
                    Text("解锁徽章：\(badge.name)").font(.system(size: 13.5, weight: .bold)).foregroundColor(.white)
                } else if let title = fb.completedTitles.first {
                    Text("完成任务：\(title)").font(.system(size: 13.5, weight: .bold)).foregroundColor(.white)
                }
                if fb.gainedXP > 0 {
                    Text("+\(fb.gainedXP) 经验值").font(.system(size: 11, weight: .semibold)).foregroundColor(Theme.coral)
                }
            }
            Spacer()
        }
        .padding(12).background(Theme.ink).clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func levelUpOverlay(_ level: Level) -> some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 8) {
                Text(level.icon).font(.system(size: 64))
                Text("LEVEL UP").font(.system(size: 11, weight: .bold)).tracking(4).foregroundColor(Theme.orangeDeep)
                Text("升级到 Lv.\(level.lv)").font(.system(size: 21, weight: .heavy))
                Text(level.name).font(.system(size: 14)).foregroundColor(Theme.ink2)
                Text("点击关闭 · 继续保持 🐾").font(.system(size: 10)).foregroundColor(Theme.muted).padding(.top, 12)
            }
            .frame(width: 270).padding(.vertical, 30)
            .background(LinearGradient(colors: [Color(hex: "FFF7EE"), Color(hex: "FFE6CF")], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }
}

struct PlaceDetailSheet: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    let place: Place

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "DDD8CE")).frame(width: 38, height: 4).frame(maxWidth: .infinity).padding(.top, 8)
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: [Color(hex: "BFE3C8"), Color(hex: "8FC9A6")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(place.emoji).font(.system(size: 80)).frame(maxWidth: .infinity).frame(height: 170)
                    Text(place.badge).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 11).padding(.vertical, 5).background(Theme.green).clipShape(Capsule()).padding(12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18)).padding(.top, 14)
                Text(place.name).font(.system(size: 20, weight: .heavy)).padding(.top, 16)
                HStack(spacing: 12) {
                    Label(place.addr, systemImage: "location.fill")
                    Text("⭐ \(place.rating)")
                }.font(.system(size: 12)).foregroundColor(Theme.ink2).padding(.top, 10)
                Text("由狗友们实地标注的宠物友好去处。带毛孩子来之前记得确认现场规定，一起维护好环境～")
                    .font(.system(size: 13)).foregroundColor(Theme.ink2).lineSpacing(5).padding(.top, 16)
                HStack(spacing: 6) {
                    ForEach(place.feats, id: \.self) { f in
                        Text(f).font(.system(size: 10.5, weight: .semibold)).foregroundColor(Theme.green)
                            .padding(.horizontal, 9).padding(.vertical, 4).background(Theme.greenSoft).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }.padding(.top, 14).padding(.bottom, 24)
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("在这里发起遛狗局").font(.system(size: 14, weight: .bold))
                    }.foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 50)
                        .background(Theme.orange).clipShape(RoundedRectangle(cornerRadius: 15))
                }.padding(.bottom, 20)
            }.padding(.horizontal, 20)
        }.background(Theme.bg)
    }
}
