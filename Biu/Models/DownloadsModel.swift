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

/// Lazy, private reference to moc.
fileprivate let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

/// Logical container for models, reflects updates from Tetra when download state changes.
final class DownloadsModel: ObservableObject {
    
    static let shared = DownloadsModel()
    
    /// Initialize the model with a binding to the fetched results.
    init() {
        let request: NSFetchRequest<SavedMedia> = SavedMedia.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \SavedMedia.timestamp, ascending: true)]
        savedMedias = try! moc.fetch(request)
        
        // Create storage folder if necessary.
        if !FileManager.default.fileExists(atPath: downloadsFolder.path) {
            try! FileManager.default.createDirectory(at: downloadsFolder, withIntermediateDirectories: false, attributes: nil)
        }
        
        // Re-create Tetra tasks for all tasks which have yet to download.
        for media in savedMedias where !media.isDownloaded {
            reinitiateDownload(forMedia: media)
        }
    }
    
    @Published var tetra = Tetra.shared
    
    @Published var resourceError: BKError?
    
    // MARK: Private API
    
    fileprivate let downloadsFolder = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SavedMedias")
    
    /// All currently downloading tasks.
    private var allDownloads: [TTask] {
        tetra.allTasks
    }
    
    /// Bag of cancellables from loading video info.
    private var loadItemCancellables = Set<AnyCancellable>()
    
    /// The timestamp ordered SavedMedia objects.
    private var savedMedias: [SavedMedia]
    
    /// Create a new SavedMedia and Tetra download for the given MediaInfoModel.
    private func newDownload(forMedia media: MediaInfoModel) {
        // Create the SavedMedia object and keep track of it.
        let savedMedia = SavedMedia(context: moc)
        savedMedia.timestamp = Date()
        savedMedia.aid = Int64(media.aid)
        savedMedia.bvid = media.bvid
        savedMedia.cid = Int64(media.cid)
        savedMedia.title = media.title
        savedMedia.desc = media.desc
        savedMedia.duration = Int64(media.duration)
        savedMedia.thumbnailURL = media.thumbnailURL
        // Initialize the download task.
        createTetraTask(forSavedMedia: savedMedia, mediaURL: media.mediaURL)
        savedMedias.append(savedMedia)
    }
    
    private func createTetraTask(forSavedMedia media: SavedMedia, mediaURL: URL) {
        let ttask = tetra.download(mediaURL,
                                   to: media.localURL,
                                   withId: media.bvid!) {
            // On success, mark media as downloaded.
            media.isDownloaded = true
        }
        media.ttask = ttask
    }
    
    // MARK: Public API
    
    /// Returns if there's an ongoing download task for the given resource.
    func isDownloading(media: SavedMedia) -> Bool {
        allDownloads.first { $0.id == media.bvid! } != nil
    }
    
    /// Returns if a resource is downloaded, as indicated by its corresponding SavedMedia.
    func isDownloaded(resource: ResourceInfoModel) -> Bool {
        savedMedias.first { $0.bvid == resource.bvid }?.isDownloaded ?? false
    }
    
    /// Initiate a download for a given resource item.
    func initiateDownload(forResource resource: ResourceInfoModel) {
        // First retrieve the video info for the resource.
        BKMainEndpoint.getVideoInfo(forBV: resource.bvid)
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
                let item = MediaInfoModel(with: output.1, mediaURL: output.0.url)
                // Create download for the media item.
                self.newDownload(forMedia: item)
            }
            .store(in: &loadItemCancellables)
    }
    
    func reinitiateDownload(forMedia media: SavedMedia) {
        // Retrieve a new dash map with download urls.
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
                }
                else {
                    self.resourceError = nil
                }
            } receiveValue: { output in
                // Create download for the media item.
                self.createTetraTask(forSavedMedia: media, mediaURL: output.url)
            }
            .store(in: &loadItemCancellables)
    }
        
}

// MARK: SavedMedia
@objc(SavedMedia)
class SavedMedia: NSManagedObject, Identifiable {
    
    fileprivate var ttask: TTask? {
        didSet {
            if let task = ttask {
                sinkCancellable = task.$state
                    .receive(on: RunLoop.main)
                    .sink { [weak self] (state) in
                        self?.downloadState = state
                    }
            }
            else {
                self.downloadState = .success
            }
        }
    }
    private var sinkCancellable: AnyCancellable?
    
    @Published var downloadState: TTask.State = .paused {
        willSet {
            objectWillChange.send()
        }
    }
        
    public var id: String {
        bvid!
    }
    
    var localURL: URL {
        DownloadsModel.shared.downloadsFolder.appendingPathComponent("\(id).mp4")
    }
    
}
