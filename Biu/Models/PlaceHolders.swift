//
//  PlaceHolders.swift
//  Biu
//
//  Created by Zerui Chen on 8/7/20.
//

import Foundation
import Nuke

/// Placeholder models for testing.
struct PlaceHolders {
    
    static let favouriteFolder = FavouriteFolderModel(id: 234, title: "默认收藏夹", mediaCount: 15, thumbnailURL: URL(string: "https://i0.hdslb.com/bfs/archive/e523109320dde93e7919cbfed4a780bc1a4a81e6.jpg")!)
    
    static let favouriteCategory = FavouriteCategoryModel(id: 23948723, name: "我的创建", folders: [favouriteFolder, FavouriteFolderModel(id: 1234, title: "收藏夹2", mediaCount: 99, thumbnailURL: URL(string: "https://i0.hdslb.com/bfs/archive/e523109320dde93e7919cbfed4a780bc1a4a81e6.jpg")!)])
    
    static let favouritePage = FavouriteModel(favouritePage: [favouriteCategory], openedItems: [resourceInfo, resourceInfo, resourceInfo, resourceInfo])
    
    static let resourceInfo = ResourceInfoModel(bvid: "BV1Wt4y1Q797",
                                                title: "【动画PV】冰糖-ファンサ《Fans》★【超电VUP】",
                                                thumbnailURL: URL(string: "https://i0.hdslb.com/bfs/archive/e523109320dde93e7919cbfed4a780bc1a4a81e6.jpg")!,
                                                pageCount: 1,
                                                duration: 3601)
    
//    static let mediaInfo = MediaInfoModel(aid: 626292014, bvid: "BV1Wt4y1Q797", cid: 3434,
//                                          title: "【动画PV】冰糖-ファンサ《Fans》★【超电VUP】",
//                                          desc: "喜欢的话就坚持吧！！！！！！！！！！\n・・・‥‥………………………………………………………‥‥・・・\n■本家：HoneyWorks（夏川椎菜）\n■翻唱：进击的冰糖\n■和声：张京华、帕里、花园Serena、高槻律、早稻叽、永远酱\n■参演：木糖纯、虚拟次元计划、菫妃奈、喵田弥夜、雫るる、夜霧Yogiri、希薇娅Civia、黑桃影、阿媂娅Artia、艾因Eine、琉绮Ruki、七海Nana7mi、一果Ichigo、中单光一\n\n■曲绘：DRAGEN_LI\n■PV：PinoEliza\n■制作：超电VUP\n■文案、监修：进击的冰糖\n・・・‥‥………………………………………………………‥‥・・・\n感兴趣的话就关注一下吧(*˘︶˘*).｡.:*♡\n\n进击的冰糖的bilibili空间：https://space.bilibili.com/198297\n\n进击的冰糖的直播间：https://live.bilibili.com/876396\n\n超电VUP官方账号：https://space.bilibili.com/597066058",
//                                          duration: 255,
//                                          mediaURL: URL(string: "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a")!,
//                                          thumbnailURL: URL(string: "http://i0.hdslb.com/bfs/archive/8681dbce8ad3ed3d4c89c4a7951e233996bdbd98.jpg")!,
//                                          isSavedMedia: false)
    
//    static let mediaPlayer = MediaPlayerModel(item: mediaInfo)
    
}
