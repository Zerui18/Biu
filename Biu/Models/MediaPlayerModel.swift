//
//  MediaPlayerModel.swift
//  Biu
//
//  Created by Zerui Chen on 19/8/20.
//

import MediaPlayer
import SwiftUI
import Combine

fileprivate var cancellable: AnyCancellable?

class MediaPlayerModel: ObservableObject {
    
    static let shared = MediaPlayerModel()
    
    private init () {
        setupMPCommandCenter()
    }
    
    enum Mode: Equatable {
        case flow, random, repeatSingle, repeatQueue
    }
    
    struct DisplayInfo {
        let title: String
        
        static let empty = DisplayInfo(title: "")
    }
    
    // MARK: Published
    @Published var mode: Mode = .flow {
        didSet {
            if mode == .repeatQueue {
                repeatItemIndex = currentItemIndex
            }
        }
    }
    @Published var queue = [MediaPlaylistItemModel]()
    @Published var currentItem: MediaPlaylistItemModel? {
        willSet {
            cancellable = newValue?.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }
    @Published var displayInfo: DisplayInfo = .empty
    
    var canSkipBackward: Bool {
        currentItemIndex > 0
    }
    
    var canSkipForward: Bool {
        mode == .repeatQueue || currentItemIndex + 1 < queue.count
    }
    
    var canControlItem: Bool {
        currentItem?.controlsEnabled ?? false
    }
    
    var currentItemPaused: Bool {
        currentItem?.state == .paused
    }
        
    // MARK: Private
    private var controlBindings: MediaControlBindings!
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
            // Update displayInfo.
            if let media = currentItem?.item {
                displayInfo = .init(title: media.getCleanedTitle())
            }
            else {
                displayInfo = .empty
            }
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
        
        center.previousTrackCommand.addTarget { [self] event in
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
    /// Add the given media to queue at the specified position, defaults to -1 which represents the end.
    func addToQueue(_ media: MediaRepresentable, position: Int = -1) {
        let playlistItem = MediaPlaylistItemModel(withMedia: media, bindings: controlBindings) { [self] in
            if self.mode == .repeatSingle {
                currentItem!.seek(to: 0)
            }
            else {
                skipToNext()
            }
        }
        
        if position == -1 {
            queue.append(playlistItem)
        }
        else {
            queue.insert(playlistItem, at: position)
        }
        
        if queue.count == 1 {
            // Start playing.
            currentItemIndex = 0
        }
    }
    
    func clearQueue() {
        queue.removeAll()
        currentItemIndex = -1
    }
    
    func replaceQueue(withMedia media: MediaRepresentable) {
        clearQueue()
        addToQueue(media)
    }
    
    // MARK: Player Controls
    func resume() {
        currentItem?.resume()
    }
    
    func pause() {
        currentItem?.pause()
    }
    
    func toggleResumePause() {
        currentItem?.toggleResumePause()
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
