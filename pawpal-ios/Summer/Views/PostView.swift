import SwiftUI

struct PostView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss

    @State private var dogID = "d1"
    @State private var type = "normal"
    @State private var title = "傍晚一起去遛狗吧 🐕"
    @State private var placeIndex = 0
    @State private var time = Date().addingTimeInterval(7200)
    @State private var maxPeople = "8"
    @State private var desc = "天气不错，带毛孩子一起出去玩！记得带水和拾便袋～"
    @State private var visibility = "公开"

    private let types: [(key: String, icon: String, title: String, sub: String)] = [
        ("normal", "🦮", "一起遛弯", "轻松散步"),
        ("run", "🎾", "撒欢放电", "奔跑玩耍"),
        ("cafe", "☕", "咖啡小聚", "狗狗下午茶"),
        ("train", "🎯", "训练课堂", "社交学习"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Button("取消") { dismiss() }.foregroundColor(Theme.muted)
                    Spacer()
                    Text("发起遛狗局").font(.system(size: 20, weight: .heavy))
                    Spacer()
                    Color.clear.frame(width: 30)
                }
                field("① 带哪只狗狗参加") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(SeedData.myDogs) { dog in
                                Button(action: { dogID = dog.id }) {
                                    VStack(spacing: 5) {
                                        AvatarView(avatar: dog.avatar, size: 58, corner: 16)
                                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(dogID == dog.id ? Theme.orange : .clear, lineWidth: 2.5))
                                        Text(dog.name).font(.system(size: 10.5, weight: .bold))
                                    }
                                }
                            }
                        }
                    }
                }
                field("② 活动类型") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(types, id: \.key) { t in
                            Button(action: { type = t.key }) {
                                HStack(spacing: 10) {
                                    Text(t.icon).font(.system(size: 24))
                                    VStack(alignment: .leading) {
                                        Text(t.title).font(.system(size: 13, weight: .bold))
                                        Text(t.sub).font(.system(size: 10)).foregroundColor(Theme.muted)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                                .background(type == t.key ? Theme.orangeSoft : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(type == t.key ? Theme.orange : Theme.line, lineWidth: 1.5))
                            }
                        }
                    }
                }
                field("③ 活动标题") {
                    TextField("例如：傍晚滨江撒欢局", text: $title)
                        .font(.system(size: 14)).padding(.horizontal, 14).frame(height: 46)
                        .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1.5))
                }
                field("④ 地点") {
                    Button(action: { placeIndex = (placeIndex + 1) % SeedData.places.count }) {
                        HStack {
                            Text("📍 \(SeedData.places[placeIndex].name)").font(.system(size: 14))
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(Theme.muted)
                        }
                        .padding(.horizontal, 14).frame(height: 46).background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1.5))
                    }
                }
                HStack(alignment: .top, spacing: 12) {
                    field("⑤ 日期时间") {
                        DatePicker("", selection: $time, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden().frame(height: 46).frame(maxWidth: .infinity)
                            .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    field("⑥ 人数上限") {
                        TextField("", text: $maxPeople).keyboardType(.numberPad)
                            .font(.system(size: 14)).padding(.horizontal, 14).frame(height: 46)
                            .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1.5))
                    }
                }
                field("⑦ 活动说明") {
                    TextEditor(text: $desc).font(.system(size: 14)).frame(height: 82)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1.5))
                }
                field("⑧ 谁可以看到") {
                    HStack(spacing: 8) {
                        ForEach(["公开", "仅好友", "私密"], id: \.self) { v in
                            Button(action: { visibility = v }) {
                                Text(v).font(.system(size: 12, weight: .bold))
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(visibility == v ? Theme.orangeSoft : .white)
                                    .foregroundColor(visibility == v ? Theme.orangeDeep : Theme.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(visibility == v ? Theme.orange : Theme.line, lineWidth: 1.5))
                            }
                        }
                    }
                }
                Button(action: publish) {
                    HStack {
                        Image(systemName: "plus")
                        Text("发布遛狗局").font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 50)
                    .background(LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding(.top, 4)
                Text("发布后附近狗友就能看到并报名啦 🐾")
                    .font(.system(size: 11)).foregroundColor(Theme.muted).frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func field(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .bold)).foregroundColor(Theme.ink2)
            content()
        }
    }

    private func publish() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            app.showToast("给活动起个标题吧"); return
        }
        let dog = SeedData.myDogs.first { $0.id == dogID } ?? SeedData.myDogs[0]
        let f = DateFormatter(); f.dateFormat = "M月d日 HH:mm"
        let typeLabel = types.first { $0.key == type }?.title ?? "一起遛弯"
        app.publishWalk(
            title: title, dog: dog, place: SeedData.places[placeIndex],
            timeText: f.string(from: time), max: Int(maxPeople) ?? 8,
            desc: desc, typeLabel: typeLabel
        )
        dismiss()
    }
}
