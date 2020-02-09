///
//  Core
//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Additions

public class UploadingMedia {
    public var data: Data
    public var id: String
    public var type: Media.ModelType
    public init(data: Data, id: String, type: Media.ModelType) {
        self.data = data
        self.id = id
        self.type = type
    }
}

public protocol MediaUploading {
    var image: UploadingMedia { get }
    var didStart: (Result<Media.MediaUploadResponse, ServiceError>) -> Void { get }
    var completion: (Result<Media.MediaUploadResponse, ServiceError>) -> Void { get }
}

public class MediaUploader: AsyncOperaiton, MediaUploading {
    
    //MARK: - Properties
    private let initService: SpecialisedDataService
    private let uploadService: SpecialisedDataService
    private let finaliseService: SpecialisedDataService
    
    //MARK: - Constuctor
    public init(initService: SpecialisedDataService,
                uploadService: SpecialisedDataService,
                finaliseService: SpecialisedDataService,
                image: UploadingMedia,
                didStart: @escaping (Result<Media.MediaUploadResponse, ServiceError>) -> Void,
                completion: @escaping (Result<Media.MediaUploadResponse, ServiceError>) -> Void) {
        
        self.initService = initService
        self.uploadService = uploadService
        self.finaliseService = finaliseService
        self.image = image
        self.didStart = didStart
        self.completion = completion
    }
        
    //MARK: - AsyncOperaiton
    public override func main() {
        super.main()
        guard !isCancelled else { return }
        
        //Starting init service
        let initRequest = Media.InitRequest(mediaType: image.type.rawValue,
                                               totalBytes: image.data.count)
        
        initService.getData(payload: initRequest, completion: { [weak self] (result: Result<Media.MediaUploadResponse, ServiceError>) in
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            do {
                let response = try result.get()
                guard let appendRequest = Media.AppendRequestMetadata(safe: response) else {
                    self?.didStart(.failure(ServiceError.unknown))
                    return
                }
                self?.didStart(.success(response))
                self?.upload(request: appendRequest)
            } catch {
                self?.didStart(.failure(ServiceError.init(from: error)))
            }
        })
    }
    
    
    //MARK: - MediaUploading implementation
    public let image: UploadingMedia
    public let didStart: (Result<Media.MediaUploadResponse, ServiceError>) -> Void
    public let completion: (Result<Media.MediaUploadResponse, ServiceError>) -> Void
    
    
    //MARK: - Private methods
    private func upload(request: Media.AppendRequestMetadata) {
        //convert meta into parameters
        guard !isCancelled else { return }
        let params = [String : String]()
        
        uploadService.upload(data: image.data, parameters: params, payload: request) { [weak self] (result: Result<Media.MediaUploadResponse, ServiceError>) in
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            do {
                let _ = try result.get()
                self?.finalize(id: request.mediaId)
            } catch {
                self?.didStart(.failure(ServiceError.init(from: error)))
            }
        }
        
    }
    
    private func finalize(id: String) {
        let request = Media.FinalizeRequest(mediaId: id)
        guard !isCancelled else { return }
        finaliseService.getData(payload: request) { [weak self] (result: Result<Media.MediaUploadResponse, ServiceError>) in
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            do {
                let response = try result.get()
                self?.completion(.success(response))
                self?.state = .finished
            } catch {
                self?.didStart(.failure(ServiceError.init(from: error)))
            }
        }
    }
}
