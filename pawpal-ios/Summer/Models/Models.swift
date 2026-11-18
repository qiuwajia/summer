import Foundation
import SwiftUI

/// 头像来源：本地图片资源或 emoji 符号
enum Avatar: Codable, Equatable {
    case asset(String)
    case emoji(String)

    var emojiValue: String {
        if case .emoji(let e) = self { return e }
        return "🐕"
    }

    var assetName: String? {
        if case .asset(let n) = self { return n }
        return nil
    }
}

struct Dog: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let avatar: Avatar
    let tags: [String]
}

struct Walk: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let dog: String
    let dogAvatar: Avatar
    let host: String
    let hostAvatar: Avatar
    let hostInfo: String
    let status: String          // "live" | "soon"
    let statusText: String
    let place: String
    let time: String
    let dist: String
    var people: Int
    let max: Int
    var joined: [String]
    let tags: [String]
    let desc: String
    let placeEmoji: String
}

struct Place: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let addr: String
    let emoji: String
    let rating: String
    let badge: String
    let feats: [String]
}

struct Friend: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let dog: String
    let breed: String
    let dist: String
    let emoji: String
    let color: [String]         // 渐变起止色十六进制
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let from: String            // "me" | "them"
    let text: String
    let time: String
}

struct Chat: Identifiable, Codable, Equatable {
    let id: String
    let friend: String
    let emoji: String
    let color: [String]
    var time: String
    var unread: Int
    var msgs: [ChatMessage]
}

// MARK: - Color 十六进制支持（用于渐变头像）

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
