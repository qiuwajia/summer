import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var app: AppState
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.1868, longitude: 121.4637),
            span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        )
    )
    @State private var selectedWalk: Walk?
    let onOpenWalk: (Walk) -> Void
    let onOpenPlace: (Place) -> Void

    private let walkPins: [(id: String, lat: Double, lon: Double)] = [
        ("w1", 31.1860, 121.4600),
        ("w2", 31.2120, 121.5500),
        ("w3", 31.2240, 121.4300),
    ]
    private let placePins: [(id: String, lat: Double, lon: Double)] = [
        ("p1", 31.1850, 121.4620),
        ("p2", 31.2300, 121.5600),
        ("p3", 31.2180, 121.4250),
        ("p4", 31.2750, 121.5200),
    ]

    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(SeedData.places) { place in
                    if let pin = placePins.first(where: { $0.id == place.id }) {
                        Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)) {
                            Button(action: { onOpenPlace(place) }) {
                                ZStack {
                                    Circle().fill(Theme.green)
                                    Text(place.emoji).font(.system(size: 17))
                                }
                                .frame(width: 38, height: 38)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                            }
                        }
                    }
                }
                ForEach(app.data.walks) { walk in
                    if let pin = walkPins.first(where: { $0.id == walk.id }) {
                        Annotation(walk.dog, coordinate: CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)) {
                            Button(action: { selectedWalk = walk }) {
                                HStack(spacing: 6) {
                                    AvatarView(avatar: walk.dogAvatar, size: 30, corner: 15)
                                    Text(walk.dog).font(.system(size: 11, weight: .bold))
                                }
                                .padding(4).padding(.trailing, 10)
                                .background(.white).clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.orange, lineWidth: 2))
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(Theme.muted)
                    Text("搜索这一带...").font(.system(size: 14)).foregroundColor(Theme.muted)
                    Spacer()
                }
                .padding(.horizontal, 14).frame(height: 44).background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15)).padding(.horizontal, 16).padding(.top, 8)
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: {
                            withAnimation { position = .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 31.1868, longitude: 121.4637),
                                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)))
                            }
                            app.showToast("已定位到：徐汇滨江")
                        }) {
                            Image(systemName: "location.fill").font(.system(size: 19)).foregroundColor(Theme.ink)
                                .frame(width: 42, height: 42).background(.white).clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                    }.padding(.trailing, 16)
                }
                Button(action: { onOpenPlace(SeedData.places[0]) }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("发起遛狗局").font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 11)
                    .background(Theme.ink).clipShape(Capsule())
                }
                .padding(.top, 10)
                sheet
            }
        }
        .onAppear { app.track("viewMap") }
        .sheet(item: $selectedWalk) { walk in
            WalkDetailSheet(walk: walk, onOpenChat: { onOpenWalk(walk) }).environmentObject(app)
        }
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "DDD8CE")).frame(width: 38, height: 4)
                .frame(maxWidth: .infinity)
            HStack {
                Text("附近正在发生").font(.system(size: 15, weight: .bold))
                Spacer()
                Text("实时更新 · \(app.data.walks.count) 场").font(.system(size: 12, weight: .semibold)).foregroundColor(Theme.orange)
            }.padding(.top, 10).padding(.bottom, 8)
            ForEach(app.data.walks.prefix(3)) { w in
                HStack(spacing: 11) {
                    AvatarView(avatar: w.dogAvatar, size: 44, corner: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(w.title).font(.system(size: 13, weight: .bold)).lineLimit(1)
                        Text("\(w.place) · \(w.time) · \(w.dist)").font(.system(size: 11)).foregroundColor(Theme.muted).lineLimit(1)
                    }
                    Spacer()
                    Button(action: { app.toggleJoin(w.id) }) {
                        Text(app.isJoined(w.id) ? "已加入" : "加入")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(Theme.orangeDeep)
                            .padding(.horizontal, 12).padding(.vertical, 7).background(Theme.orangeSoft).clipShape(Capsule())
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture { selectedWalk = w }
            }
        }
        .padding(.horizontal, 18).padding(.top, 8).padding(.bottom, 16)
        .background(.white).clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
    }
}
