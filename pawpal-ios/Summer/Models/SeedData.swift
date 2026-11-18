import Foundation

enum SeedData {
    static let myDogs: [Dog] = [
        Dog(id: "d1", name: "豆包", breed: "金毛", age: "3岁", avatar: .asset("dog-golden"), tags: ["社牛", "大型犬"]),
        Dog(id: "d2", name: "麻糬", breed: "柴犬", age: "2岁", avatar: .asset("dog-shiba"), tags: ["温顺", "中型犬"]),
    ]

    static let friends: [Friend] = [
        Friend(id: "f1", name: "小满 & 可乐", dog: "可乐", breed: "柯基", dist: "0.3km", emoji: "🐶", color: ["FFD08A", "FF9A5B"]),
        Friend(id: "f2", name: "阿哲 & 团子", dog: "团子", breed: "萨摩耶", dist: "0.6km", emoji: "🐕", color: ["BFE9FF", "7CC4F5"]),
        Friend(id: "f3", name: "Yuki & Lucky", dog: "Lucky", breed: "边牧", dist: "0.9km", emoji: "🦮", color: ["D9C6FF", "A98BF0"]),
        Friend(id: "f4", name: "大熊 & 布丁", dog: "布丁", breed: "泰迪", dist: "1.2km", emoji: "🐩", color: ["FFC9C9", "FF9A9A"]),
        Friend(id: "f5", name: "琳达 & 阿福", dog: "阿福", breed: "拉布拉多", dist: "1.5km", emoji: "🐕‍🦺", color: ["C8F0D8", "7FD6A0"]),
    ]

    static let places: [Place] = [
        Place(id: "p1", name: "徐汇滨江狗狗乐园", addr: "徐汇区龙腾大道 · 1.1km", emoji: "🌳", rating: "4.9", badge: "免门票", feats: ["围栏", "小型犬区", "饮水点"]),
        Place(id: "p2", name: "世纪公园宠物草坪", addr: "浦东新区 · 2.4km", emoji: "🌿", rating: "4.8", badge: "超大面积", feats: ["可牵绳", "饮水点", "停车"]),
        Place(id: "p3", name: "愚园路宠物友好咖啡", addr: "长宁区愚园路 · 3.0km", emoji: "☕", rating: "4.7", badge: "宠物友好", feats: ["露台", "宠物菜单"]),
        Place(id: "p4", name: "共青森林公园", addr: "杨浦区 · 4.6km", emoji: "🌲", rating: "4.9", badge: "遛狗圣地", feats: ["大草坪", "湖边", "停车"]),
    ]

    static let walks: [Walk] = [
        Walk(id: "w1", title: "傍晚滨江撒欢局 🐕", dog: "豆包", dogAvatar: .asset("dog-golden"),
             host: "豆包的家长", hostAvatar: .asset("dog-golden"), hostInfo: "金毛 · 社牛 · 3岁",
             status: "live", statusText: "正在进行", place: "徐汇滨江狗狗乐园", time: "今天 17:30", dist: "0.3km",
             people: 4, max: 8, joined: ["f1", "f2", "f3", "f4"],
             tags: ["大型犬友好", "可带飞盘", "新手欢迎"],
             desc: "趁着天气好，带毛孩子去滨江跑一跑！我们几个已经到了，带飞盘和玩具的可以一起玩。小狗大人都可以来，注意牵绳就好～", placeEmoji: "🌳"),
        Walk(id: "w2", title: "周末草坪放电大会", dog: "可乐", dogAvatar: .emoji("🐶"),
             host: "小满", hostAvatar: .emoji("🐶"), hostInfo: "柯基 · 短腿 · 2岁",
             status: "soon", statusText: "即将开始", place: "世纪公园宠物草坪", time: "明天 09:00", dist: "2.4km",
             people: 6, max: 10, joined: ["f2", "f3", "f5"],
             tags: ["带水", "防晒", "狗狗社交"],
             desc: "周末早上凉快，约上小伙伴一起去世纪公园的大草坪放放电。记得带足饮用水和拾便袋，一起维护好环境～", placeEmoji: "🌿"),
        Walk(id: "w3", title: "愚园路咖啡遛弯小聚", dog: "麻糬", dogAvatar: .asset("dog-shiba"),
             host: "Yuki", hostAvatar: .emoji("🦮"), hostInfo: "边牧 · 聪明 · 4岁",
             status: "soon", statusText: "招募中", place: "愚园路宠物友好咖啡", time: "周六 14:00", dist: "3.0km",
             people: 3, max: 6, joined: ["f1", "f4"],
             tags: ["咖啡", "小型犬", "安静"],
             desc: "遛完弯一起坐坐，这家咖啡店的露台可以带狗。性格温顺的狗狗优先哦，大家有个安静的下午茶。", placeEmoji: "☕"),
    ]

    static let chats: [Chat] = [
        Chat(id: "c1", friend: "小满 & 可乐", emoji: "🐶", color: ["FFD08A", "FF9A5B"], time: "17:22", unread: 2,
             msgs: [
                ChatMessage(id: "m1", from: "them", text: "我们到滨江啦！凤鸣路那个入口～", time: "17:18"),
                ChatMessage(id: "m2", from: "me", text: "好好好，我们停车中，5分钟到！", time: "17:20"),
                ChatMessage(id: "m3", from: "them", text: "带飞盘了没？可乐一直盯着别人的玩 😂", time: "17:22"),
             ]),
        Chat(id: "c2", friend: "阿哲 & 团子", emoji: "🐕", color: ["BFE9FF", "7CC4F5"], time: "昨天", unread: 0,
             msgs: [
                ChatMessage(id: "m4", from: "them", text: "明天世纪公园那个局还去吗？", time: "昨天 20:10"),
                ChatMessage(id: "m5", from: "me", text: "去的！团子可以和小狗们熟悉熟悉", time: "昨天 20:15"),
             ]),
        Chat(id: "c3", friend: "Yuki & Lucky", emoji: "🦮", color: ["D9C6FF", "A98BF0"], time: "周二", unread: 0,
             msgs: [
                ChatMessage(id: "m6", from: "them", text: "周六咖啡那家我查了下，露台确实能带狗", time: "周二 11:30"),
             ]),
    ]

    static func makeAppData() -> AppData {
        var q = QuestState()
        q.dailyDate = DateUtils.dayKey()
        q.dailyIds = QuestEngine.seededPick(seed: q.dailyDate, count: 3)
        return AppData(walks: walks, chats: chats, joinedMine: [], quest: q)
    }
}
