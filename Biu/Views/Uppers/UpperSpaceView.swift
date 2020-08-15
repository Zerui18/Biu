//
//  UpperSpaceView.swift
//  Biu
//
//  Created by Zerui Chen on 12/8/20.
//

import SwiftUI

struct UpperSpaceView: View {
    
    init(upper: UpperRepresentable) {
        self.upper = upper
        self.face = .init(url: upper.getFace())
        self.banner = upper.getBanner().flatMap { .init(url: $0) }
                                                ?? .init(image: Image(uiImage: UIImage()))
    }
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var model: UppersModel = .shared
    @ObservedObject var face: FetchImage
    @ObservedObject var banner: FetchImage
    
    @State var hasLoadedUpper = false
    
    let upper: UpperRepresentable
    
    var body: some View {
        ScrollView(.vertical) {
            // Top.
            ZStack(alignment: .top) {
                VStack {
                    banner.image
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 120)
                        .clipped()

                    VStack(spacing: 10) {
                        Text(upper.getName())
                            .font(Font.largeTitle.bold())

                        if let sign = upper.getSign() {
                            Text(sign)
                                .font(.subheadline)
                        }
                    }
                    .padding(15)
                    // 50 placess name right below the image.
                    .padding(.top, 50 + 20)
                }

                face.image
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 4))
                    .padding(.top, 100)
            }
            .layoutPriority(1)
            
            Divider()
            
            // Saved Works.
            if let upper = model.savedUpper,
               let medias = upper.ownedWorks?.allObjects as? [SavedMedia] {
                UpperSpaceSection(title: "已保存", media: medias) {
                    Color.white
                }
                .padding(.bottom, 20)
                
                Divider()
            }
            
            // Loaded Works.
            if let upper = model.remoteUpper {
                UpperSpaceSection(title: "最新", media: upper.archive.item) {
                    Color.white
                }
                .padding(.bottom, 20)
                
                Divider()
            }
            
            Color.clear
                .frame(height: 200)
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea([.top, .bottom])
        .onAppear {
            if !hasLoadedUpper {
                model.loadUpper(with: upper)
                hasLoadedUpper = true
            }
        }
    }
}

struct UpperSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpperSpaceView(upper: _MockUpperInfo())
                .colorScheme(.dark)
        }
    }
}

struct _MockUpperInfo: UpperRepresentable {
    func getMid() -> Int {
        282994
    }
    func getName() -> String {
        "泠鸢yousa"
    }
    func getFace() -> URL {
        URL(string: "http://i2.hdslb.com/bfs/face/28f95c383f2805dbed32e93007c91ccfda28775f.jpg")!
    }
    func getSign() -> String? {
        "虚拟艺人团体VirtuaReal Star成员，微博&网易云等搜：泠鸢yousa "
    }
    func getBanner() -> URL? {
        URL(string: "http://i0.hdslb.com/bfs/garb/item/51bb0ebb333c3f1a983735ba283ca15383bccae3.jpg")!
    }
    func getBannerNight() -> URL? {
        nil
    }
}

struct _MockMediaInfo: Identifiable, MediaRepresentable {
    func getBVId() -> String {
        "BV1Wt4y1Q797"
    }
    
    func getTitle() -> String {
        "【动画PV】冰糖-ファンサ《Fans》★【超电VUP】"
    }
    
    func getThumbnailURL() -> URL {
        URL(string: "https://i0.hdslb.com/bfs/archive/e523109320dde93e7919cbfed4a780bc1a4a81e6.jpg")!
    }
    
    func getAuthor() -> UpperRepresentable {
        author
    }
    
    
    let id = UUID()
    let author = _MockUpperInfo()
    
    static let samples: [_MockMediaInfo] = (1...10).map { _ in _MockMediaInfo() }
}
