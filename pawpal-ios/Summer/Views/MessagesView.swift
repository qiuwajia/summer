import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var app: AppState
    @State private var activeChat: Chat?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack { Text("消息").font(.system(size: 24, weight: .heavy)); Spacer() }
                        .padding(.horizontal, 20).padding(.top, 6).padding(.bottom, 12)
                    VStack(spacing: 0) {
                        ForEach(app.data.chats) { chat in
                            Button(action: { activeChat = chat }) {
                                HStack(spacing: 12) {
                                    ZStack(alignment: .topTrailing) {
                                        GradientAvatar(emoji: chat.emoji, colors: chat.color, size: 52)
                                        if chat.unread > 0 {
                                            Circle().fill(Theme.orange).frame(width: 12, height: 12)
                                                .overlay(Circle().stroke(Theme.bg, lineWidth: 2)).offset(x: 2, y: -2)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(chat.friend).font(.system(size: 14.5, weight: .bold))
                                            Spacer()
                                            Text(chat.time).font(.system(size: 11)).foregroundColor(Theme.muted)
                                        }
                                        if let last = chat.msgs.last {
                                            Text("\(last.from == "me" ? "我：" : "")\(last.text)")
                                                .font(.system(size: 12.5)).foregroundColor(Theme.muted).lineLimit(1)
                                        }
                                    }
                                }
                                .padding(.vertical, 14)
                            }
                            .overlay(Rectangle().frame(height: 1).foregroundColor(Theme.line), alignment: .bottom)
                        }
                    }.padding(.horizontal, 20)
                    Color.clear.frame(height: 20)
                }
            }
            .background(Theme.bg.ignoresSafeArea())
        }
        .sheet(item: $activeChat) { chat in
            ChatView(chat: chat).environmentObject(app)
        }
    }
}

struct ChatView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) var dismiss
    let chat: Chat
    @State private var text = ""

    private var currentChat: Chat {
        app.data.chats.first { $0.id == chat.id } ?? chat
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold)).foregroundColor(Theme.ink)
                }
                GradientAvatar(emoji: chat.emoji, colors: chat.color, size: 36)
                VStack(alignment: .leading) {
                    Text(chat.friend).font(.system(size: 15, weight: .bold))
                    Text("● 最近活跃").font(.system(size: 10.5)).foregroundColor(Theme.green)
                }
                Spacer()
            }
            .padding(.horizontal, 16).frame(height: 52).background(.white)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(currentChat.msgs) { m in
                        HStack {
                            if m.from == "me" { Spacer() }
                            VStack(alignment: m.from == "me" ? .trailing : .leading) {
                                Text(m.text).font(.system(size: 13.5)).foregroundColor(m.from == "me" ? .white : Theme.ink)
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(m.from == "me" ? Theme.orange : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Text(m.time).font(.system(size: 10)).foregroundColor(Theme.muted)
                            }
                            if m.from != "me" { Spacer() }
                        }
                    }
                }.padding(16)
            }
            .background(Theme.bg)
            HStack(spacing: 10) {
                TextField("发条消息...", text: $text)
                    .font(.system(size: 14)).padding(.horizontal, 15).frame(height: 40)
                    .background(Theme.bg).clipShape(Capsule())
                Button(action: send) {
                    Image(systemName: "paperplane.fill").font(.system(size: 17)).foregroundColor(.white)
                        .frame(width: 40, height: 40).background(Theme.orange).clipShape(Circle())
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10).background(.white)
        }
        .background(Theme.bg)
        .onAppear { app.markRead(chat.id) }
    }

    private func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        app.sendMessage(chatID: chat.id, text: text)
        text = ""
    }
}
