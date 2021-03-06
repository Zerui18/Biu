//
//  DownloadsModel.swift
//  Biu
//
//  Created by Zerui Chen on 15/7/20.
//

import SwiftUI
import Combine
import UIKit
import CoreData
import Tetra
import BiliKit

/// Logical container for models, reflects updates from Tetra when download state changes.
final class DownloadsModel: ObservableObject {
    
    static let shared = DownloadsModel()
    
    /// Initialize the model with a binding to the fetched results.
    init() {
        // Fetch all SavedMedias.
        let request: NSFetchRequest<SavedMedia> = SavedMedia.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \SavedMedia.timestamp, ascending: true)]
        savedMedias = try! mocGlobal.fetch(request)
        
        // Create storage folder if necessary.
        if !FileManager.default.fileExists(atPath: DownloadsModel.downloadsFolder.path) {
            try! FileManager.default.createDirectory(at: DownloadsModel.downloadsFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Re-create Tetra tasks for all tasks which have yet to download.
        for media in savedMedias where !media.isDownloaded {
            // First check if media is actually downloaded.
            if FileManager.default.fileExists(atPath: media.getLocalURL().path) {
                media.isDownloaded = true
            }
            else {
                // Otherwise initialize new download task for it.
                reinitiateDownload(forSavedMedia: media)
            }
        }
        
//        // Clean.
//        var cleaned = [SavedMedia]()
//        for media in savedMedias {
//            if !cleaned.contains(where: { $0.bvid == media.bvid }) {
//                cleaned.append(media)
//            }
//            else {
//                // Delete duplicate.
//                mocGlobal.delete(media)
//            }
//        }
//        try! mocGlobal.save()
    }
    
    let tetra = Tetra.shared
    
    @Published var resourceError: BKError?
    
    private static let downloadsFolder = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SavedMedias")
    
    // MARK: Private API
    
    /// All tasks from tetra.
    private var allDownloads: [String:TTask] {
        tetra.tasksMap
    }
    
    /// Bag of cancellables from loading video info.
    private var loadItemCancellables = Set<AnyCancellable>()
    
    /// The timestamp ordered SavedMedia objects.
    private var savedMedias: [SavedMedia]
    
    /// Creates a SavedMedia object and link its SavedUpper object.
    func createSavedMedia(forMedia media: MediaInfoDataModel) -> SavedMedia {
        let savedMedia = SavedMedia(context: mocGlobal)
        savedMedia.timestamp = Date()
        // Save properties.
        savedMedia.aid = Int64(media.aid)
        savedMedia.bvid = media.bvid
        savedMedia.cid = Int64(media.cid)
        savedMedia.title = media.title
        savedMedia.desc = media.desc
        savedMedia.duration = Int64(media.duration)
        savedMedia.thumbnailURL = media.thumbnailURL
        // Set owner.
        UppersModel.shared.savedUppers(from: [media.owner!])[0]
            .addToOwnedWorks(savedMedia)
        // Set staff.
        UppersModel.shared.savedUppers(from: media.staff ?? [])
            .forEach {
                $0.addToParticipatedWorks(savedMedia)
            }
        // Immediate CoreData save.
        try? mocGlobal.save()
        return savedMedia
    }
    
    private func startTetraTask(forSavedMedia media: SavedMedia, mediaURL: URL) {
        let ttask = tetra.downloadTask(forId: media.bvid!, dstURL: media.getLocalURL())
        ttask.download(mediaURL) {
            // On success, mark media as downloaded.
            media.isDownloaded = true
        }
        media.ttask = ttask
    }
    
    /// Create a new SavedMedia and Tetra download for the given MediaInfoModel.
    private func newDownload(forMedia media: MediaInfoDataModel) {
        if let savedMedia = savedMedia(forId: media.getBVId()) {
            // SavedMedia already exists.
            startTetraTask(forSavedMedia: savedMedia, mediaURL: media.mediaURL)
        }
        else {
            // Create the SavedMedia object and keep track of it.
            let savedMedia = createSavedMedia(forMedia: media)
            // Initialize the download task.
            startTetraTask(forSavedMedia: savedMedia, mediaURL: media.mediaURL)
            savedMedias.append(savedMedia)
        }
    }
    
    // MARK: Public API
    static func localURL(forMedia media: MediaRepresentable) -> URL {
        downloadsFolder.appendingPathComponent("\(media.getBVId()).mp4")
    }
    
    func savedMedia(forId id: String) -> SavedMedia? {
        return savedMedias.first { $0.bvid! == id }
    }
    
    /// Initiate a download for a given media.
    func initiateDownload(forMedia media: MediaRepresentable) {
        let state = media.getDownloadTask().simpleState
        state.value = .downloading
        // First retrieve the video info for the resource.
        BKMainEndpoint.getVideoInfo(forBV: media.getBVId())
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
                    state.value = .none
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                let item = MediaInfoDataModel(with: output.1, mediaURL: output.0.url)
                // Create download for the media item.
                self.newDownload(forMedia: item)
            }
            .store(in: &loadItemCancellables)
    }
    
    func reinitiateDownload(forSavedMedia media: SavedMedia) {
        // Retrieve a new dash map with download urls.
        let state = media.getDownloadTask().simpleState
        state.value = .downloading
        BKAppEndpoint.getDashMaps(forAid: Int(media.aid), cid: Int(media.cid))
            .map {
                $0.data.dash.audio.sorted {
                    $0.size > $1.size
                }[0]
            }
            .receive(on: RunLoop.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    self.resourceError = error
                    state.value = .none
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                // Create download for the media item.
                self.startTetraTask(forSavedMedia: media, mediaURL: output.url)
            }
            .store(in: &loadItemCancellables)
    }
        
}
