//
//  AudioPlayerModel.swift
//  Biu
//
//  Created by Zerui Chen on 11/7/20.
//

import Combine
import BiliKit
import AVFoundation

final class MediaPlayerModel: ObservableObject {
    
    // MARK: Published
    @Published var currentItem: MediaInfoModel?
    @Published var resourceError: BKError?
    
    // MARK: Private Props
    private var loadItemCancellable: AnyCancellable?
    
    // MARK: Methods
    func play(_ item: ResourceInfoModel) {
        startLoading(item: item)
    }
    
    // MARK: Private Helpers
    private func startLoading(item: ResourceInfoModel) {
        loadItemCancellable = BKMainEndpoint.getVideoInfo(forBV: item.bvid)
            .flatMap { response in
                BKAppEndpoint.getDashMaps(forAid: response.data.aid, cid: response.data.pages[0].cid)
                    .map {
                        $0.data.dash.audio.sorted {
                            $0.size > $1.size
                        }[0]
                    }
                    .zip(Just(response.data)
                            .setFailureType(to: BKError.self))
            }
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.resourceError = error
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                self.currentItem = .create(with: output.1, mediaURL: output.0.url)
                self.currentItem?.audioPlayer?.play()
            }
    }
}

struct MediaInfoModel {
    let aid: Int
    let title: String
    let desc: String
    let mediaURL: URL
    let thumbnailURL: URL
    
    fileprivate lazy var audioPlayer = try? AVAudioPlayer(contentsOf: mediaURL)
    
    static func create(with videoInfo: BKMainEndpoint.VideoInfoResponse, mediaURL: URL) -> MediaInfoModel {
        MediaInfoModel(aid: videoInfo.aid,
                       title: videoInfo.title,
                       desc: videoInfo.desc,
                       mediaURL: mediaURL,
                       thumbnailURL: videoInfo.thumbnailURL)
    }
}
