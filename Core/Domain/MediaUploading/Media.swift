//
//  Media.swift
//  Domain
//
//  Created by Marton Kerekes on 04/01/2020.
//  Copyright © 2020 Marton Kerekes. All rights reserved.
//

import Foundation

public class Media {
    
    public enum ModelType: String {
        case image = "IMAGE"
        case video = "VIDEO"
    }
    public var _id: String
    
    public var type: ModelType
    
    public var url: String
    
    public init(_id: String, type: ModelType, url: String) {
        self._id = _id
        self.type = type
        self.url = url
    }
    
    public class Image {
        public var data: Data
        public init(data: Data) {
            self.data = data
        }
    }

    public class Video {
        public let data: Data
        public var previewData: Data?
        public let url: URL
        public init(url: URL, data: Data) {
            self.url = url
            self.data = data
        }
    }
    
    public class MediaUploadResponse:  Equatable {
        
        public enum ModelType: String {
            case video = "VIDEO"
            case image = "IMAGE"
        }
        public var mediaId: String
        
        public var url: String
        
        public var size: Int
        
        public var expiresAfterSecs: Int
        
        public var type: ModelType
        
        public var mediaType: String
        
        
        public init(mediaId: String, url: String, size: Int, expiresAfterSecs: Int, type: ModelType, mediaType: String) {
            self.mediaId = mediaId
            self.url = url
            self.size = size
            self.expiresAfterSecs = expiresAfterSecs
            self.type = type
            self.mediaType = mediaType
        }
        
        public static func == (lhs: MediaUploadResponse, rhs: MediaUploadResponse) -> Bool {
            return lhs.mediaId == rhs.mediaId && lhs.url == rhs.url && lhs.size == rhs.size && lhs.expiresAfterSecs == rhs.expiresAfterSecs && lhs.type == rhs.type && lhs.mediaType == rhs.mediaType
        }
        
    }

    public class InitRequest:  Equatable {
        
        public var mediaType: String
        
        public var totalBytes: Int
        
        
        public init(mediaType: String, totalBytes: Int) {
            self.mediaType = mediaType
            self.totalBytes = totalBytes
        }
        
        public static func == (lhs: InitRequest, rhs: InitRequest) -> Bool {
            return lhs.mediaType == rhs.mediaType && lhs.totalBytes == rhs.totalBytes
        }
        
    }

    public class AppendRequestMetadata:  Equatable {
        
        /** Media ID to append chunk of data to  */
        public var mediaId: String
        
        /** Segment of specific chunk. Should start at 0 and increase by 1 for every chunk appended  */
        public var segmentIndex: Int
        
        
        public init(mediaId: String, segmentIndex: Int) {
            self.mediaId = mediaId
            self.segmentIndex = segmentIndex
        }
        
        public static func == (lhs: AppendRequestMetadata, rhs: AppendRequestMetadata) -> Bool {
            return lhs.mediaId == rhs.mediaId && lhs.segmentIndex == rhs.segmentIndex
        }
        
    }

    public class FinalizeRequest:  Equatable {
        
        public var mediaId: String
        
        
        public init(mediaId: String) {
            self.mediaId = mediaId
        }
        
        public static func == (lhs: FinalizeRequest, rhs: FinalizeRequest) -> Bool {
            return lhs.mediaId == rhs.mediaId
        }

    }
}

public extension Media.AppendRequestMetadata {
    
    convenience init?(safe value: Media.MediaUploadResponse?) {
        guard let value = value else {
            return nil
        }
        self.init(mediaId: value.mediaId, segmentIndex: 0)
    }
}


