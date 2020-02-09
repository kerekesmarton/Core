///
//  Posts
//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation
import Domain
import Additions

public class UploadTracker {
    public let asset: Asset
    public var response: Media.MediaUploadResponse?
    public var error: ServiceError?
    public var id: String {
        return asset.id
    }
    public init(asset: Asset) {
        self.asset = asset
    }
}

public protocol AttachmentDisplayable: class {
    func setup(imageURL: URL, error: ServiceError?, isUploaded: Bool)
    func setup(data: Data, error: ServiceError?, isUploaded: Bool)
    func canceletionBlock(action: @escaping () -> Void)
}

public protocol AttachmentsPresenting: class {
    var numberOfRows: Int { get }
    var collectionViewCelldentifier: String { get }
    func setup(cell: AttachmentDisplayable, for path: IndexPath)
    func sizeforItem(at path: IndexPath) -> (width: Int, height: Int)
    func didSelect(cell: AttachmentDisplayable, for path: IndexPath)
    func viewReady()
    func viewDidReachEnd()
}

public protocol AttachmentsPresentingOutput: class {
    var presenter: AttachmentsPresenting? { get set }
    func reload()
}


public enum MediaState {
    case none
    case photoAdded
    case videoAdded
}

public protocol HostReloadable: class {
    func progressManagerDidCancel(uploadTracker: UploadTracker)
    func progressManagerDidUpdate(state: MediaState)
}

public protocol MediaUploadPogressManaging {
    var delegate: HostReloadable? { get set }
    var readyForUpload: Bool { get }
    var mediaState: MediaState { get }
    var imageAssets: [String:UploadTracker] { get }
    func startUploading(assets: [Asset], didStart: @escaping (Result<UploadTracker, ServiceError>) -> Void, completion: @escaping (Result<UploadTracker, ServiceError>) -> Void)
    func addExisting(media: [Media], completion: @escaping (Result<[UploadTracker], ServiceError>) -> Void)
    func setup(cell: AttachmentsPresentingOutput)
}

public class MediaUploadPogressManager: MediaUploadPogressManaging {
    private var existingAssets: [String: UploadTracker] = [:]
    public var imageAssets: [String: UploadTracker] = [:] {
        didSet {
            let sortedKeys = imageAssets.keys.sorted(by: <)
            orderedAssets = sortedKeys.compactMap { imageAssets[$0] }
        }
    }
    private var orderedAssets: [UploadTracker] = [] {
        didSet {
            guard let tracker = orderedAssets.first else {
                delegate?.progressManagerDidUpdate(state: .none)
                mediaState = .none
                return
            }
            switch tracker.asset.type {
            case .photo:
                delegate?.progressManagerDidUpdate(state: .photoAdded)
                mediaState = .photoAdded
            case .video:
                delegate?.progressManagerDidUpdate(state: .videoAdded)
                mediaState = .videoAdded
            }
        }
    }
    
    public var mediaState: MediaState = .none
    
    let queue: OperationQueue
    let mediaUploadInitService: SpecialisedDataService
    let mediaUploadAppendService: SpecialisedDataService
    let mediaUploadFinaliseService: SpecialisedDataService
    
    public init(mediaUploadInitService: SpecialisedDataService,
                mediaUploadAppendService: SpecialisedDataService,
                mediaUploadFinaliseService: SpecialisedDataService) {
        self.mediaUploadInitService = mediaUploadInitService
        self.mediaUploadAppendService = mediaUploadAppendService
        self.mediaUploadFinaliseService = mediaUploadFinaliseService
        self.queue = OperationQueue()
    }
    
    deinit {
        print("deinit")
    }
    
    fileprivate func updateOnDidStart(uploadTracker: UploadTracker?, _ result: Result<Media.MediaUploadResponse, ServiceError>, _ didStart: @escaping (Result<UploadTracker, ServiceError>) -> Void) {
        do {
            guard let uploadTracker = uploadTracker else {
                return
            }
            let response = try result.get()
            uploadTracker.response = response
            output?.reload()
            didStart(.success(uploadTracker))
        } catch {
            guard let uploadTracker = uploadTracker else {
                return
            }
            let serviceError = ServiceError(from: error)
            uploadTracker.error = serviceError
            didStart(.failure(serviceError))
            output?.reload()
        }
    }
    
    fileprivate func updateOnCompletion(uploadTracker: UploadTracker?, _ result: Result<Media.MediaUploadResponse, ServiceError>, _ completion: @escaping (Result<UploadTracker, ServiceError>) -> Void) {
        do {
            guard let uploadTracker = uploadTracker else {
                return
            }
            let response = try result.get()
            uploadTracker.response = response
            completion(.success(uploadTracker))
            output?.reload()
        } catch {
            guard let uploadTracker = uploadTracker else {
                return
            }
            let serviceError = ServiceError(from: error)
            uploadTracker.error = serviceError
            completion(.failure(serviceError))
            output?.reload()
        }
    }
    
    public func startUploading(assets: [Asset], didStart: @escaping (Result<UploadTracker, ServiceError>) -> Void, completion: @escaping (Result<UploadTracker, ServiceError>) -> Void) {
        
        let newAssets = assets.compactMap { UploadTracker(asset: $0) }
        newAssets.forEach { (uploadTracker) in
            guard imageAssets[uploadTracker.id] == nil, let uploadData = uploadTracker.asset.data else { return }
            let image = UploadingMedia(data: uploadData, id: uploadTracker.id, type: uploadTracker.asset.type.mediaType)
            
            let uploader = MediaUploader(initService: mediaUploadInitService,
                                         uploadService: mediaUploadAppendService,
                                         finaliseService: mediaUploadFinaliseService,
                                         image: image,
                                         didStart:
                { [weak uploadTracker, weak self] (result: Result<Media.MediaUploadResponse, ServiceError>) in
                    self?.updateOnDidStart(uploadTracker: uploadTracker, result, didStart)
                    
                }, completion:
                { [weak self, weak uploadTracker] (result: Result<Media.MediaUploadResponse, ServiceError>) in
                    self?.updateOnCompletion(uploadTracker: uploadTracker, result, completion)
            })
            
            imageAssets[uploadTracker.id] = uploadTracker
            queue.addOperation(uploader)
        }
        output?.reload()
    }
    
    
    public func addExisting(media: [Media], completion: @escaping (Result<[UploadTracker], ServiceError>) -> Void) {
        
        DispatchQueue.global().async { [weak self] in
            let assets = try? media.compactMap { (media) -> Asset? in
                guard let url = URL(string: media.url) else {
                    return nil
                }
                let data = try Data(contentsOf: url)
                return Asset(data: data, id: media._id, type: AssetType(with: media.type))
            }
            guard let safeAssets = assets else {
                completion(.failure(ServiceError.parsing("Couldn't add existing images")))
                return
            }
            
            let trackers = safeAssets.compactMap { UploadTracker(asset: $0) }
            
            trackers.forEach { (tracker) in
                self?.imageAssets[tracker.id] = tracker
                self?.existingAssets[tracker.id] = tracker
            }
            
            DispatchQueue.main.async { [weak self] in
                completion(.success(trackers))
                self?.output?.reload()
            }
        }
        
        
    }
    
    weak var output: AttachmentsPresentingOutput?
    
    public func setup(cell: AttachmentsPresentingOutput) {
        output = cell
        cell.presenter = self
        guard !imageAssets.compactMap({ $1.asset.data }).isEmpty else { return }
        cell.reload()
    }
    
    func cancel(tracker: UploadTracker) {
        queue.operations.forEach({ (operation) in
            guard let op = operation as? (AsyncOperaiton & MediaUploading) else { return }
            if op.image.id == tracker.id {
                op.cancel()
            }
        })
    }
    
    public weak var delegate: HostReloadable?
    
    public var readyForUpload: Bool {
        if !orderedAssets.isEmpty {
            return !uploadInProgress
        } else {
            return true
        }
    }
    
    var uploadInProgress: Bool {
        return !queue.operations.isEmpty
    }
}

extension MediaUploadPogressManager: AttachmentsPresenting {
    
    public var numberOfRows: Int {
        return orderedAssets.count
    }
    
    public var collectionViewCelldentifier: String {
        return "AttachmentCollectionViewCell"
    }
    
    public func setup(cell: AttachmentDisplayable, for path: IndexPath) {
        guard let uploadTracker = orderedAssets[safe: path.row] else {
            return
        }
        if let existingTracker = existingAssets[uploadTracker.id], let data = uploadTracker.asset.data {
            cell.setup(data: data, error: uploadTracker.error, isUploaded: true)
            cell.canceletionBlock { [weak self, weak existingTracker] in
                guard let existingTracker = existingTracker else {
                    return
                }
                self?.existingAssets[existingTracker.id] = nil
                self?.imageAssets[existingTracker.id] = nil
                self?.output?.reload()
                self?.delegate?.progressManagerDidCancel(uploadTracker: uploadTracker)
            }
        } else {
            guard let data = uploadTracker.asset.data else { return }
            cell.setup(data: data, error: uploadTracker.error, isUploaded: uploadTracker.response?.url != nil)
            cell.canceletionBlock { [weak self, weak uploadTracker] in
                guard let uploadTracker = uploadTracker else {
                    return
                }
                self?.cancel(tracker: uploadTracker)
                self?.imageAssets[uploadTracker.id] = nil
                self?.output?.reload()
                self?.delegate?.progressManagerDidCancel(uploadTracker: uploadTracker)
            }
        }
    }
    
    public func sizeforItem(at path: IndexPath) -> (width: Int, height: Int) {
        return (108, 108)
    }
    
    public func didSelect(cell: AttachmentDisplayable, for path: IndexPath) {}
    public func viewReady() {}
    public func viewDidReachEnd() {}
}
