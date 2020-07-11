//
//  MediaPlayerModel.swift
//  Biu
//
//  Created by Zerui Chen on 11/7/20.
//

import SwiftUI
import Combine
import BiliKit
import AVFoundation

// MARK: Media Player Model
final class MediaPlayerModel: ObservableObject {
    
    // MARK: Init
    init() {}
    
    init(item: MediaInfoModel) {
        self.currentItem = item
    }
    
    // MARK: Published
    @Published var currentItem: MediaInfoModel?
    @Published var resourceError: BKError?
    
    // MARK: Bindings
    var isSeeking: Binding<Bool>!
    var currentTime: Binding<TimeInterval>!
    var duration: Binding<TimeInterval>!
    
    // MARK: Private Props
    private var loadItemCancellable: AnyCancellable?
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
    
    // MARK: Methods
    func bind(_ isSeeking: Binding<Bool>, _ currentTime: Binding<TimeInterval>, _ duration: Binding<TimeInterval>) {
        self.isSeeking = isSeeking
        self.currentTime = currentTime
        self.duration = duration
    }
    
    func play(_ item: ResourceInfoModel) {
        startLoading(item: item)
    }
    
    func seek(to seconds: TimeInterval) {
        let time = CMTime(seconds: seconds, preferredTimescale: 1)
        currentItem?.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setPaused(_ isPaused: Bool) {
        if isPaused {
            currentItem?.player.pause()
        }
        else {
            currentItem?.player.play()
        }
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
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.resourceError = error
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                self.currentItem = .create(with: output.1, mediaURL: output.0.url)
                let player = self.currentItem!.player
                self.observePlayer(player)
                player.play()
            }
    }
    
    private func observePlayer(_ player: AVPlayer) {
        durationObservation = player.currentItem?.observe(\.duration) { [self] item, _ in
            duration.wrappedValue = item.duration.seconds
        }
        
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [self] time in
            // Only update from here when not seeking.
            if !isSeeking.wrappedValue {
                currentTime.wrappedValue = time.seconds
            }
        }
    }
}

// MARK: Media Info Model
struct MediaInfoModel {
    let aid: Int
    let title: String
    let desc: String
    let duration: Int
    let mediaURL: URL
    let thumbnailURL: URL
    
    lazy var player = AVPlayer(url: mediaURL)
    
    static func create(with videoInfo: BKMainEndpoint.VideoInfoResponse, mediaURL: URL) -> MediaInfoModel {
        MediaInfoModel(aid: videoInfo.aid,
                       title: videoInfo.title,
                       desc: videoInfo.desc,
                       duration: videoInfo.duration,
                       mediaURL: mediaURL,
                       thumbnailURL: videoInfo.thumbnailURL)
    }
}
