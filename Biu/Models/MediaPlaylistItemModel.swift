//
//  MediaPlaylistItemModel.swift
//  Biu
//
//  Created by Zerui Chen on 19/8/20.
//

import MediaPlayer
import Combine
import BiliKit
import Nuke
import SwiftUI

class MediaPlaylistItemModel: ObservableObject {
    
    init(withMedia item: MediaRepresentable,
         bindings: MediaControlBindings,
         onComplete handler: @escaping () -> Void) {
        self.item = item
        self.controlBindings = bindings
        self.completionHandler = handler
    }
    
    enum State: Equatable {
        case loadingMetadata, playerPreparing, playing, paused, error
    }
    
    // MARK: Published
    @Published var state: State = .loadingMetadata
    @Published var error: BKError?
    @Published var cover: SwiftUI.Image = .init("bg_placeholder")
    @Published var controlsEnabled = false
    
    // MARK: Private Properties
    let item: MediaRepresentable
    private let completionHandler: () -> Void
    private let controlBindings: MediaControlBindings
    private var playableItem: MediaInfoDataModel? {
        didSet {
            controlsEnabled = playableItem != nil
            if playableItem != nil && isCurrentItem {
                resume()
                observePlayer()
                updateMPNowPlaying()
            }
        }
    }
    private var isCurrentItem = false
    
    private var loadCancellable: AnyCancellable?
    private var imageTask: ImageTask?
    
    private var playerReadyObservation: NSKeyValueObservation?
    private var playRateObservation: NSKeyValueObservation?
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
    
    // MARK: Public Methods
    func play() {
        assert(playableItem == nil, ".play() should not be called when playableItem already exists!")
        
        isCurrentItem = true
        
        if let savedMedia = DownloadsModel.shared.savedMedia(forId: item.getBVId()) {
            playableItem = .init(with: savedMedia)
        }
        else {
            loadMetadata()
        }
        
        loadCover()
    }
    
    func resume() {
        playableItem!.player.play()
        updateMPNowPlaying(isPlaying: true)
    }
    
    func pause() {
        playableItem!.player.pause()
        updateMPNowPlaying(isPlaying: false)
    }
    
    func toggleResumePause() {
        switch state {
        case .playing, .playerPreparing:
            pause()
        case .paused:
            resume()
        default: break
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let player = playableItem?.player else {
            return
        }
        let time = CMTime(seconds: time,
                          preferredTimescale: player.currentItem?.asset.duration.timescale ?? 1)
        self.pause()
        player.seek(to: time) { _ in
            self.resume()
        }
    }
    
    /// Clear up resources.
    func stop() {
        isCurrentItem = false
        playRateObservation = nil
        durationObservation = nil
        timeObservation = nil
        playableItem?.player.replaceCurrentItem(with: nil)
        playableItem = nil
    }
    
    // MARK: Private, Loading
    private func loadMetadata() {
        // Load new item.
        loadCancellable = BKMainEndpoint.getVideoInfo(forBV: item.getBVId())
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
            .sink { [weak self] (completion) in
                guard let self = self else {
                    return
                }
                
                if case .failure(let error) = completion {
                    self.state = .error
                    self.error = error
                }
                else {
                    self.state = .playing
                }
            } receiveValue: { [weak self] output in
                guard let self = self else {
                    return
                }
                
                self.playableItem = .init(with: output.1, mediaURL: output.0.url)
            }
    }
    
    private func loadCover() {
        imageTask =
            ImagePipeline.shared.loadImage(with: item.getThumbnailURL(), completion:  { [self] result in
                guard let image = try? result.get().image else {
                    return
                }
                cover = .init(uiImage: image)
                if isCurrentItem {
                    updateMPNowPlaying(thumbnailImage: image)
                }
            })
    }
    
    // MARK: Observation
    private func observePlayer() {
        let player = playableItem!.player
        
        // Play/pause status.
        playRateObservation = player.observe(\.timeControlStatus) { [weak self] player, _ in
            let isPlaying = player.timeControlStatus == .playing
            self?.state = isPlaying ? .playing:.paused
            if self?.isCurrentItem == true {
                self?.updateMPNowPlaying(isPlaying: isPlaying)
            }
        }
        
        // Item duration.
        durationObservation = player.currentItem?.observe(\.duration) { [weak self] item, _ in
            self?.controlBindings.duration.wrappedValue = item.duration.seconds
        }
        
        // Current time.
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 60), queue: nil) { [weak self] time in
            guard let bindings = self?.controlBindings else {
                return
            }
            // Only update from here when not seeking.
            if !bindings.isSeeking.wrappedValue {
                bindings.currentTime.wrappedValue = time.seconds
            }
        }
        
        // Finished playing.
        var playerEndObserver: NSObjectProtocol!
        playerEndObserver = NotificationCenter.default
            .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem,
                         queue: .main) { [weak playerEndObserver, weak self] (_) in
                // Don't strongly retain observer in case it retains this block.
                playerEndObserver.flatMap(NotificationCenter.default.removeObserver)
                // Invoke completion.
                self?.completionHandler()
        }
    }
    
    // MARK: MPNowPlayingInfoCenter
    private func updateMPNowPlaying() {
        guard let item = playableItem else {
            return
        }
        
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = item.title
        info[MPMediaItemPropertyArtist] = item.owner!.name
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateMPNowPlaying(isPlaying: Bool) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playableItem!.player.currentTime().seconds
        info[MPMediaItemPropertyPlaybackDuration] = playableItem!.player.currentItem?.duration.seconds
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1:0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateMPNowPlaying(thumbnailImage: UIImage) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: thumbnailImage.size) { _ in
            return thumbnailImage
        }
    }
    
}
