//
//  Tetra.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Foundation

/// The top most logial container for Tetra apis.
public class Tetra: ObservableObject {
    
    private init() {}
    
    /// Array of all ongoing tasks.
    @Published public var allTasks = [TTask]()
    
    /// Create and start a new download task.
    @discardableResult
    public func download(_ url: URL, to dstURL: URL, withId id: String, onSuccess handler: @escaping ()-> Void) -> TTask {
        let newTask = TTask(id: id, remoteURL: url, targetURL: dstURL, onSuccess: handler)
        allTasks.append(newTask)
        return newTask
    }
    
    /// Removes a download task.
    public func remove(task: TTask) {
        if let idx = allTasks.firstIndex(of: task) {
            let task = allTasks.remove(at: idx)
            task.cancel()
        }
    }
    
}

extension Tetra {
    
    /// The only instance of Tetra ever created.
    public static let shared = Tetra()
    
}
