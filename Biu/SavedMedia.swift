//
//  SavedMedia.swift
//  Biu
//
//  Created by Zerui Chen on 4/8/20.
//

import CoreData
import Combine
import Tetra

// MARK: SavedMedia
@objc(SavedMedia)
public class SavedMedia: NSManagedObject {
    
    var ttask: TTask? {
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
    
    var localURL: URL {
        DownloadsModel.shared.downloadsFolder.appendingPathComponent("\(bvid!).mp4")
    }
    
    var upper: SavedUpper? {
        staff?[0] as? SavedUpper
    }
}
