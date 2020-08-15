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
import Nuke

// MARK: Media Player Model
final class MediaPlayerModel: ObservableObject {
    
    static let shared = MediaPlayerModel()
    
    // MARK: Init
    init() {}
    
    init(item: MediaInfoDataModel) {
        self.currentItem = item
    }
    
    // MARK: Published
    @Published var currentItem: MediaInfoDataModel? {
        willSet {
            // Clean up observations and tasks.
            loadItemCancellable = nil
            playRateObservation = nil
            durationObservation = nil
            self.currentItem?.player.removeTimeObserver(timeObservation as Any)
            timeObservation = nil
            imageTask = nil
        }
        didSet {
            if let item = currentItem {
                // Begin observation.
                observePlayer(item.player)
                // Play.
                item.player.play()
                // Start loading thumbnail.
                imageTask =
                    ImagePipeline.shared.loadImage(with: item.thumbnailURL) { result in
                    if let image = try? result.get().image,
                       // Check if we're still on the same item.
                       self.currentItem?.aid == item.aid {
                        self.thumbnailImage.wrappedValue = .init(uiImage: image)
                    }
                }
            }
            else {
                self.thumbnailImage.wrappedValue = .init("bg_placeholder")
            }
        }
    }
    @Published var resourceError: BKError?
    
    var title: String {
        currentItem?.title ?? "--"
    }
    
    // MARK: Bindings
    var playState: Binding<MediaPlayerView.PlayState>!
    var isSeeking: Binding<Bool>!
    var currentTime: Binding<TimeInterval>!
    var duration: Binding<TimeInterval>!
    var thumbnailImage: Binding<SwiftUI.Image>!
    
    // MARK: Private Props
    private var loadItemCancellable: AnyCancellable?
    private var playRateObservation: NSKeyValueObservation?
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
    private var imageTask: ImageTask?
    
    // MARK: Methods
    func bind(_ playState: Binding<MediaPlayerView.PlayState>,
              _ isSeeking: Binding<Bool>,
              _ currentTime: Binding<TimeInterval>,
              _ duration: Binding<TimeInterval>,
              _ thumbnailImage: Binding<SwiftUI.Image>) {
        self.playState = playState
        self.isSeeking = isSeeking
        self.currentTime = currentTime
        self.duration = duration
        self.thumbnailImage = thumbnailImage
    }
    
    func play(_ item: MediaRepresentable) {
        // Check if the item is already downloaded.
        if let media = DownloadsModel.shared.savedMedia(forId: item.getBVId()) {
            currentItem = MediaInfoDataModel(with: media)
        }
        // Otherwise proceed to loading.
        else {
            startLoading(item)
        }
    }
    
    func seek(to seconds: TimeInterval, play: Bool) {
        guard let player = currentItem?.player else {
            return
        }
        let time = CMTime(seconds: seconds, preferredTimescale: player.currentItem?.asset.duration.timescale ?? 1)
        player.seek(to: time) { _ in
            if play {
                player.play()
            }
        }
    }
    
    func playPause() {
        if playState.wrappedValue == .playing {
            currentItem?.player.pause()
        }
        else {
            currentItem?.player.play()
        }
    }
    
    func pause() {
        playState.wrappedValue = .paused
        currentItem?.player.pause()
    }
    
    // MARK: Private Helpers
    private func startLoading(_ item: MediaRepresentable) {
        // Clear props.
        currentItem = nil
        isSeeking.wrappedValue = false
        currentTime.wrappedValue = 0
        duration.wrappedValue = 0
        // Remove tasks.
        loadItemCancellable?.cancel()
        // Load new item.
        loadItemCancellable = BKMainEndpoint.getVideoInfo(forBV: item.getBVId())
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
                    self.thumbnailImage.wrappedValue = .init("bg_placeholder")
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                let item = MediaInfoDataModel(with: output.1, mediaURL: output.0.url)
                self.currentItem = item
            }
    }
    
    private func observePlayer(_ player: AVPlayer) {
        playRateObservation = player.observe(\.rate) { [self] player, _ in
            playState.wrappedValue =
                player.rate != 0 ? .playing:.paused
        }
        
        durationObservation = player.currentItem?.observe(\.duration) { [self] item, _ in
            duration.wrappedValue = item.duration.seconds
        }
        
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 60), queue: nil) { [self] time in
            // Only update from here when not seeking.
            if !isSeeking.wrappedValue {
                currentTime.wrappedValue = time.seconds
            }
        }
    }
}
