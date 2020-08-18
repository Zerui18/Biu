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
import MediaPlayer

// MARK: Media Player Model
final class MediaPlayerModel: ObservableObject {
    
    static let shared = MediaPlayerModel()
    
    // MARK: Init
    init() {
        self.setupMPCommandCenter()
    }
    
    convenience init(item: MediaInfoDataModel) {
        self.init()
        self.currentItem = item
    }
    
    // MARK: Published
    @Published var currentItem: MediaInfoDataModel? {
        willSet {
            // Cleanup before currentItem changes.
            cleanup()
        }
        didSet {
            if let item = currentItem {
                // Begin observation.
                observePlayer(item.player)
                // Start loading thumbnail.
                loadThumbnail(for: item)
                // Set MPNowPlaying info.
                setMPNowPlaying(for: item)
                // Start playing when ready.
                item.player.play()
            }
            else {
                thumbnailImage.wrappedValue = .init("bg_placeholder")
            }
        }
    }
    @Published var resourceError: BKError?
    
    var title: String {
        currentItem?.title ?? "--"
    }
    
    // MARK: Bindings
    private var playState: Binding<MediaPlayerView.PlayState>!
    private var isSeeking: Binding<Bool>!
    private var currentTime: Binding<TimeInterval>!
    private var duration: Binding<TimeInterval>!
    private var thumbnailImage: Binding<SwiftUI.Image>!
    
    // MARK: Private Props
    private var loadItemCancellable: AnyCancellable?
    private var playerReadyObservation: NSKeyValueObservation?
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
    
    // MARK: Play Controls
    
    func seek(to seconds: TimeInterval, play: Bool) {
        guard let player = currentItem?.player else {
            return
        }
        let time = CMTime(seconds: seconds, preferredTimescale: player.currentItem?.asset.duration.timescale ?? 1)
        self.pause()
        player.seek(to: time) { _ in
            if play {
                self.play()
            }
        }
    }
    
    func togglePlaying() {
        if playState.wrappedValue == .playing {
            pause()
        }
        else {
            play()
        }
    }
    
    func play() {
        guard let item = currentItem else {
            return
        }
        item.player.play()
    }
    
    func pause() {
        guard let item = currentItem else {
            return
        }
        item.player.pause()
    }
    
    // MARK: Load
    
    private func startLoading(_ item: MediaRepresentable) {
        // Clear props.
        currentItem = nil
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
    
    private func loadThumbnail(for item: MediaInfoDataModel) {
        imageTask =
            ImagePipeline.shared.loadImage(with: item.thumbnailURL) { [self] result in
            if let image = try? result.get().image,
               // Check if we're still on the same item.
               currentItem?.aid == item.aid {
                thumbnailImage.wrappedValue = .init(uiImage: image)
                updateMPNowPlaying(thumbnailImage: image)
            }
        }
    }
    
    private func cleanup() {
        clearObservers()
        imageTask = nil
    }
    
    // MARK: Observervation
    
    private func observePlayer(_ player: AVPlayer) {
        playRateObservation = player.observe(\.timeControlStatus) { [self] player, _ in
            let isPlaying = player.timeControlStatus == .playing
            playState.wrappedValue = isPlaying ? .playing:.paused
            updateMPNowPlaying(isPlaying: isPlaying)
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
    
    private func clearObservers() {
        loadItemCancellable = nil
        playRateObservation = nil
        durationObservation = nil
        if let ob = timeObservation {
            currentItem?.player.removeTimeObserver(ob)
        }
        timeObservation = nil
    }
    
    // MARK: Now Playing
    
    private func setMPNowPlaying(for item: MediaInfoDataModel) {
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = item.title
        info[MPMediaItemPropertyArtist] = item.owner!.name
        info[MPMediaItemPropertyPlaybackDuration] = item.duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupMPCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [self] _ in
            if currentItem != nil {
                play()
                return .success
            }
            return .noActionableNowPlayingItem
        }
        
        center.pauseCommand.addTarget { [self] _ in
            if currentItem != nil {
                pause()
                return .success
            }
            return .noActionableNowPlayingItem
        }
        
        center.changePlaybackPositionCommand.addTarget { [self] event in
            if currentItem != nil {
                seek(to: (event as! MPChangePlaybackPositionCommandEvent).positionTime, play: true)
                return .success
            }
            return .noActionableNowPlayingItem
        }
    }
    
    private func updateMPNowPlaying(isPlaying: Bool) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem!.player.currentTime().seconds
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1:0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateMPNowPlaying(thumbnailImage: UIImage) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: thumbnailImage.size) { _ in
            return thumbnailImage
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
