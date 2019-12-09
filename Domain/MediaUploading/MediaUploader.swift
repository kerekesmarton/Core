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
    var didStart: ((MediaUploadResponse?, ServiceError?) -> Void) { get }
    var completion: ((MediaUploadResponse?, ServiceError?) -> Void) { get }
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
                didStart: @escaping (MediaUploadResponse?, ServiceError?) -> Void,
                completion: @escaping (MediaUploadResponse?, ServiceError?) -> Void) {
        
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
        let initRequest = InitRequest(mediaType: image.type.rawValue,
                                               totalBytes: image.data.count)
        
        initService.getData(payload: initRequest, completion: { [weak self] (response: MediaUploadResponse?, error) in
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            guard let appendRequest = AppendRequestMetadata(safe: response), error == nil else {
                self?.didStart(nil, error)
                return
            }
            self?.didStart(response, nil)
            self?.upload(request: appendRequest)
        })
    }
    
    
    //MARK: - MediaUploading implementation
    public let image: UploadingMedia
    public let didStart: (MediaUploadResponse?, ServiceError?) -> Void
    public let completion: (MediaUploadResponse?, ServiceError?) -> Void
    
    
    //MARK: - Private methods
    private func upload(request: AppendRequestMetadata) {
        //convert meta into parameters
        guard !isCancelled else { return }
        let params = [String : String]()
        
        uploadService.upload(data: image.data, parameters: params, payload: request) { [weak self] (result: Void?, error) in
            
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            if let error = error {
                self?.completion(nil, error)
                 
            }
            self?.finalize(id: request.mediaId)
            
        }
        
    }
    
    private func finalize(id: String) {
        let request = FinalizeRequest(mediaId: id)
        guard !isCancelled else { return }
        finaliseService.getData(payload: request) { [weak self] (response: MediaUploadResponse?, error) in
            guard let weakSelf = self, !weakSelf.isCancelled else { return }
            self?.completion(response, error)
            self?.state = .finished
        }
    }
}
