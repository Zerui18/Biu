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
    
    /// Initialize the model with a binding to the fetched results.
    init() {
        let request: NSFetchRequest<SavedMedia> = SavedMedia.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \SavedMedia.timestamp, ascending: true)]
        self.savedMedias = try! moc.fetch(request)
        
        // Create storage folder if necessary.
        if !FileManager.default.fileExists(atPath: downloadsFolder.path) {
            try! FileManager.default.createDirectory(at: downloadsFolder, withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    @Published var tetra = Tetra.shared
    
    @Published var resourceError: BKError?
    
    // MARK: Private API
    
    private let downloadsFolder = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SavedMedias")
    
    /// All currently downloading tasks.
    private var allDownloads: [TTask] {
        tetra.allTasks
    }
    
    private var loadItemCancellable: AnyCancellable?
    
    /// The timestamp ordered SavedMedia objects.
    private var savedMedias: [SavedMedia]
    
    private func createDownload(forMedia media: MediaInfoModel) {
        // Create the SavedMedia object and keep track of it.
        let savedMedia = SavedMedia(context: moc)
        savedMedia.timestamp = Date()
        savedMedia.aid = Int64(media.aid)
        savedMedia.bvid = media.bvid
        savedMedia.title = media.title
        savedMedia.desc = media.desc
        savedMedia.duration = Int64(media.duration)
        savedMedia.thumbnailURL = media.thumbnailURL
        savedMedias.append(savedMedia)
        // Initialize the download task.
        tetra.download(media.mediaURL,
                       to: savedMedia.localURL(inFolder: downloadsFolder),
                       withId: media.bvid) {
            // On success, mark media as downloaded.
            savedMedia.isDownloaded = true
        }
    }
    
    // MARK: Public API
    
    /// Returns if there's an ongoing download task for the given resource.
    func isDownloading(media: SavedMedia) -> Bool {
        allDownloads.first { $0.id == media.bvid! } != nil
    }
    
    /// Returns a Publisher for the download state for the fiven SavedMedia object.
    func downloadState(forMedia media: SavedMedia) -> AnyPublisher<TTask.State, Never>? {
        allDownloads
            .first { $0.id == media.bvid }?.$state
            .eraseToAnyPublisher()
    }
    
    /// Returns if a resource is downloaded, as indicated by its corresponding SavedMedia.
    func isDownloaded(resource: ResourceInfoModel) -> Bool {
        savedMedias.first { $0.bvid == resource.bvid }?.isDownloaded ?? false
    }
    
    /// Initiate a download for a given resource item.
    func initiateDownload(forResource resource: ResourceInfoModel) {
        // First retrieve the video info for the resource.
        loadItemCancellable = BKMainEndpoint.getVideoInfo(forBV: resource.bvid)
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
                let item = MediaInfoModel.create(with: output.1, mediaURL: output.0.url)
                // Create download for the media item.
                self.createDownload(forMedia: item)
            }
    }
        
}

// MARK: Identifiable
extension SavedMedia: Identifiable {
    
    public var id: String {
        bvid!
    }
    
    func localURL(inFolder folder: URL) -> URL {
        folder.appendingPathComponent("\(id).mp4")
    }
    
}
