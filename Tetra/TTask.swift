//
//  TTask.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Combine

/// Class representing a download task.
public class TTask: ObservableObject {
    
    // MARK: Private Properties
    
    private let remoteURL: URL
    
    private let targetURL: URL
    
    /// The underlying download task object.
    private var downloadTask: URLSessionDownloadTask!
    
    /// The resume data, if applicable.
    private var resumeData: Data?
    
    /// Property keeping track of whether this task was paused.
    private var isPaused = false
    
    private var progressObservation: NSKeyValueObservation?
    
    private var onSuccess: ()-> Void
    
    // MARK: Init
    init(id: String, remoteURL: URL, targetURL: URL, onSuccess handler: @escaping ()-> Void) {
        self.id = id
        self.remoteURL = remoteURL
        self.targetURL = targetURL
        self.onSuccess = handler
        createTask()
    }
    
    // MARK: Private API
    
    /// Callback for when task completes.
    private lazy var onTaskCompleted = { [weak self] (_ url: URL?, _ res: URLResponse?, _ error: Error?) in
        DispatchQueue.main.async {
            guard let self = self else {
                return
            }
            
            if error != nil {
                self.state = self.isPaused ? .paused : .failure(error!)
            }
            else {
                // Downloaded, try moving to destination.
                do {
                    // Remove existing item.
                    if FileManager.default.fileExists(atPath: self.targetURL.path) {
                        try FileManager.default.removeItem(at: self.targetURL)
                    }
                    try FileManager.default.moveItem(at: url!, to: self.targetURL)
                    // Update state and call success callback.
                    self.state = .success
                    self.onSuccess()
                }
                catch {
                    self.state = .failure(error)
                }
            }
        }
    }
    
    /// Create a new URLSessionDownloadTask.
    private func createTask() {
        if let resumeData = resumeData {
            downloadTask = URLSession.tetra.downloadTask(withResumeData: resumeData, completionHandler: onTaskCompleted)
        }
        else {
            downloadTask = URLSession.tetra.downloadTask(with: remoteURL, completionHandler: onTaskCompleted)
        }
        downloadTask.resume()
        
        // Observe progress of task when running.
        progressObservation = downloadTask.progress.observe(\.fractionCompleted) { (progress, fraction) in
            DispatchQueue.main.async {
                self.state = .downloading(progress.fractionCompleted)
            }
        }
    }
    
    // MARK: Public API
    
    public enum State {
        case downloading(Double), success, failure(Error), paused
    }
    
    /// Publisher for the download state.
    @Published public var state: State = .paused
    
    /// A unique id attached to each task.
    public let id: String
    
    
    /// Pause the task.
    public func pause() {
        isPaused = true
        downloadTask.cancel { (resumeData) in
            self.resumeData = resumeData
        }
    }
    
    /// Resume the task.
    public func resume() {
        if !isPaused {
            return
        }
        
        isPaused = false
        createTask()
    }
    
    /// Cancel the task.
    func cancel() {
        downloadTask.cancel()
    }
    
}

// MARK: Equatable
extension TTask: Equatable {
    public static func ==(_ lhs: TTask, _ rhs: TTask) -> Bool {
        lhs.targetURL == rhs.targetURL &&
            lhs.remoteURL == rhs.remoteURL
    }
}
