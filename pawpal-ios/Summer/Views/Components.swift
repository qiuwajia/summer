import SwiftUI

enum Theme {
    static let orange = Color(hex: "FF7A45")
    static let orangeDeep = Color(hex: "F2601F")
    static let coral = Color(hex: "FF9A6B")
    static let orangeSoft = Color(hex: "FFF0E8")
    static let green = Color(hex: "3FAE73")
    static let greenSoft = Color(hex: "E8F7EF")
    static let bg = Color(hex: "F6F4EF")
    static let card = Color.white
    static let ink = Color(hex: "2B2A27")
    static let ink2 = Color(hex: "5F5A50")
    static let muted = Color(hex: "9A9488")
    static let line = Color(hex: "EDE9E1")
}

/// 统一头像渲染：图片资源或 emoji
struct AvatarView: View {
    let avatar: Avatar
    let size: CGFloat
    var corner: CGFloat = 12

    var body: some View {
        Group {
            if let name = avatar.assetName {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Theme.orangeSoft
                    Text(avatar.emojiValue)
                        .font(.system(size: size * 0.55))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: corner))
    }
}

/// emoji + 渐变背景的狗友头像
struct GradientAvatar: View {
    let emoji: String
    let colors: [String]
    let size: CGFloat

    var body: some View {
        ZStack {
            if colors.count >= 2 {
                LinearGradient(
                    colors: [Color(hex: colors[0]), Color(hex: colors[1])],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                Theme.orangeSoft
            }
            Text(emoji).font(.system(size: size * 0.5))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct ProgressBar: View {
    let fraction: Double
    var height: CGFloat = 6
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.07))
                Capsule()
                    .fill(LinearGradient(colors: [Theme.coral, Theme.orangeDeep], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}

struct SectionTitle: View {
    let title: String
    let action: String?
    let onTap: (() -> Void)?

    var body: some View {
        HStack {
            Text(title).font(.system(size: 16.5, weight: .bold)).foregroundColor(Theme.ink)
            Spacer()
            if let action, let onTap {
                Button(action: onTap) {
                    Text(action).font(.system(size: 12, weight: .semibold)).foregroundColor(Theme.orange)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
