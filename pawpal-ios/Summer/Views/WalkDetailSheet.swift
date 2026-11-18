import SwiftUI

struct WalkDetailSheet: View {
    @EnvironmentObject var app: AppState
    let walk: Walk
    let onOpenChat: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 4).fill(Color(hex: "DDD8CE")).frame(width: 38, height: 4)
                    .frame(maxWidth: .infinity).padding(.top, 8)
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: [Color(hex: "BFE3C8"), Color(hex: "8FC9A6")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(walk.placeEmoji).font(.system(size: 80)).frame(maxWidth: .infinity).frame(height: 170)
                    Text(walk.statusText).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 11).padding(.vertical, 5)
                        .background(walk.status == "live" ? Theme.green : Theme.orange).clipShape(Capsule()).padding(12)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18)).padding(.top, 14)

                Text(walk.title).font(.system(size: 20, weight: .heavy)).padding(.top, 16)
                HStack(spacing: 9) {
                    AvatarView(avatar: walk.hostAvatar, size: 38, corner: 19)
                    VStack(alignment: .leading) {
                        Text(walk.host).font(.system(size: 13, weight: .bold))
                        Text(walk.hostInfo).font(.system(size: 11)).foregroundColor(Theme.muted)
                    }
                }.padding(.top, 12)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    infoCell("location.fill", "地点", walk.place)
                    infoCell("clock", "时间", walk.time)
                    infoCell("ruler", "距离", walk.dist)
                    infoCell("person.2", "已报名", "\(walk.people + (app.isJoined(walk.id) ? 1 : 0)) / \(walk.max)")
                }.padding(.top, 16)

                Text(walk.desc).font(.system(size: 13)).foregroundColor(Theme.ink2)
                    .lineSpacing(5).padding(.top, 16)

                HStack(spacing: 6) {
                    ForEach(walk.tags, id: \.self) { t in
                        Text(t).font(.system(size: 10.5, weight: .semibold)).foregroundColor(Theme.ink2)
                            .padding(.horizontal, 9).padding(.vertical, 4).background(Color(hex: "F4F1EA")).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }.padding(.top, 14)

                VStack(alignment: .leading, spacing: 8) {
                    Text("🐾 已经报名的狗狗").font(.system(size: 13, weight: .bold))
                    HStack(spacing: 6) {
                        ForEach(walk.joined, id: \.self) { fid in
                            if let f = SeedData.friends.first(where: { $0.id == fid }) {
                                GradientAvatar(emoji: f.emoji, colors: f.color, size: 34)
                            }
                        }
                        if app.isJoined(walk.id) {
                            ZStack { Theme.orange; Text("🐾").font(.system(size: 17)) }
                                .frame(width: 34, height: 34).clipShape(Circle())
                        }
                    }
                }
                .padding(.top, 16).padding(.bottom, 20)

                HStack(spacing: 10) {
                    Button(action: onOpenChat) {
                        Image(systemName: "bubble.left").font(.system(size: 20)).foregroundColor(Theme.orangeDeep)
                            .frame(width: 52, height: 50).background(Theme.orangeSoft).clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    Button(action: { app.toggleJoin(walk.id) }) {
                        Text(app.isJoined(walk.id) ? "✓ 已报名，点击取消" : "我也去 · 立即报名")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(app.isJoined(walk.id) ? Theme.green : .white)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(app.isJoined(walk.id) ? Theme.greenSoft : Theme.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }.padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.bg)
    }

    private func infoCell(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 9) {
            ZStack { Color.white; Image(systemName: icon).foregroundColor(Theme.orange) }
                .frame(width: 34, height: 34).clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 10)).foregroundColor(Theme.muted)
                Text(value).font(.system(size: 12.5, weight: .bold)).lineLimit(1)
            }
        }
        .padding(12).background(Theme.bg).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
