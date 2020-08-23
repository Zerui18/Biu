//
//  MediaPlaylistModel.swift
//  Biu
//
//  Created by Zerui Chen on 19/8/20.
//

import MediaPlayer
import SwiftUI

class MediaPlayerModel: ObservableObject {
    
    static let shared = MediaPlayerModel()
    
    private init () {
        setupMPCommandCenter()
    }
    
    enum Mode: Equatable {
        case flow, random, repeatSingle, repeatQueue
    }
    
    // MARK: Public Properties
    var mode: Mode = .flow {
        didSet {
            if mode == .repeatQueue {
                repeatItemIndex = currentItemIndex
            }
        }
    }
    
    @Published var currentItem: MediaPlaylistItemModel?
        
    // MARK: Private
    private var controlBindings: MediaControlBindings!
    private var queue = [MediaPlaylistItemModel]()
    private var repeatItemIndex = 0 // Note: this might be -1.
    /// Index of the current item in the queue. Updates the currentItem on set.
    private var currentItemIndex = -1 {
        willSet {
            currentItem?.stop()
            controlBindings.reset()
        }
        didSet {
            if (0..<queue.count).contains(currentItemIndex) {
                currentItem = queue[currentItemIndex]
            }
            currentItem?.play()
        }
    }
    
    private func setupMPCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [self] _ in
            if currentItem != nil {
                resume()
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
                seek(to: (event as! MPChangePlaybackPositionCommandEvent).positionTime)
                return .success
            }
            return .noActionableNowPlayingItem
        }
        
        center.nextTrackCommand.addTarget { [self] event in
            if currentItemIndex + 1 < queue.count {
                skipToNext()
                return .success
            }
            return .noSuchContent
        }
        
        center.nextTrackCommand.addTarget { [self] event in
            if currentItemIndex - 1 >= 0 {
                skipToLast()
                return .success
            }
            return .noSuchContent
        }
    }
}

// MARK: Public
extension MediaPlayerModel {
    
    func bind(to bindings: MediaControlBindings) {
        controlBindings = bindings
    }
    
    // MARK: Queue Control
    func add(_ item: MediaRepresentable) {
        let playlistItem = MediaPlaylistItemModel(withItem: item, bindings: controlBindings) { [self] in
            if self.mode == .repeatSingle {
                currentItem!.seek(to: 0)
            }
            else {
                skipToNext()
            }
        }
        queue.append(playlistItem)
        
        if queue.count == 1 {
            // Start playing.
            currentItemIndex = 0
        }
    }
    
    func clearQueue() {
        queue.removeAll()
        currentItemIndex = -1
    }
    
    // MARK: Player Controls
    func resume() {
        currentItem?.resume()
    }
    
    func pause() {
        currentItem?.pause()
    }
    
    func seek(to time: TimeInterval) {
        currentItem?.seek(to: time)
    }
    
    func skipToLast() {
        currentItemIndex = min(0, currentItemIndex - 1)
    }
    
    func skipToNext() {
        let nextIndex = currentItemIndex + 1
        if nextIndex >= queue.count {
            // Reached end.
            if mode == .repeatQueue {
                currentItemIndex = max(repeatItemIndex, 0)
            }
        }
        else {
            currentItemIndex = nextIndex
        }
    }
}

struct MediaControlBindings {
    var isSeeking: Binding<Bool>
    var currentTime: Binding<TimeInterval>
    var duration: Binding<TimeInterval>
    
    func reset() {
        isSeeking.wrappedValue = false
        currentTime.wrappedValue = 0
        duration.wrappedValue = 0
    }
}
