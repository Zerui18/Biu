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
                                                ?? .init(image: Image(""))
    }
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @ObservedObject var model: UppersModel = .shared
    @ObservedObject var face: FetchImage
    @ObservedObject var banner: FetchImage
    
    let upper: UpperRepresentable
    
    var body: some View {
        ScrollView {
            // Top.
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                banner.image
                    .frame(maxWidth: .infinity)
                    .mask(LinearGradient(gradient:
                                            .init(stops: [
                                                .init(color: .white, location: 0.6),
                                                .init(color: Color.white.opacity(0.25), location: 1)
                                            ]),
                                           startPoint: .top, endPoint: .bottom))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(upper.getName())
                        .font(Font.largeTitle.bold())
                    
                    if let sign = upper.getSign() {
                        Text(sign)
                            .font(.subheadline)
                    }
                }
                .padding(10)
            }
            .padding(.bottom, 20)
            
            // Saved Works.
            
            // Loaded Works.
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            model.loadUpper(forMid: upper.getMid())
        }
    }
}

struct UpperSpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpperSpaceView(upper: MockUpperInfo())
                .colorScheme(.dark)
        }
    }
}

struct MockUpperInfo: UpperRepresentable {
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
