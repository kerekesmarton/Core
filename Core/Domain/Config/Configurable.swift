//
//  Domain
//
//  Copyright © 2018 mkerekes. All rights reserved.
//

import Foundation
import Photos
import UserNotifications

public enum BackgroundFetchResult : UInt {
    case newData
    case noData
    case failed
}

public protocol NotificationRefreshable {
    func updateEndpoint(userId: String)
}

public protocol NotificationServiceable {
    var shouldShowRedDotOnNotificationsTab: Bool? { get set }
    var config: Configurable? { get set }
    var helper: Any! { get set }
    func didRegisterForRemoteNotificationsWith(token: Data)
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (BackgroundFetchResult) -> Void)
    
    func setupAWSservices(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    
    func registerForPushNotifications()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
    func forwardNotifications(userInfo: [AnyHashable : Any])
    
}

public protocol Sessionable {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
}

public protocol UserProfileStoring {
    var token: String? { get set }
    var refresh: String? { get set }
    var chatToken: String? { get set }
    var id: String? { get set }
    var avatar: URL? { get set }
}

public protocol SessionCleaning {
    var hasSession: Bool { get }
    func deleteSession()
    func deleteUserId()
}

public protocol KeychainLoading {
    var id: String? { get set }
    var token: String? { get }
    func saveToken(_ value: String)
}

public protocol PhotosDataFetching {
    typealias UpdateBlock = (Double, Error?, [AnyHashable : Any]?) -> Void
    typealias PhotoFetchingCompletion = (Media.Image?, String?) -> Void
    typealias VideoFetchingCompletion = (Media.Video?, String?) -> Void
    func image(for asset: PHAsset, with size: CGSize, completionHandler: @escaping PhotoFetchingCompletion, progressHandler: UpdateBlock?)
    func video(for asset: PHAsset, completionHandler: @escaping VideoFetchingCompletion, progressHandler: UpdateBlock?)
}

public protocol UniqueStringProviding {
    var uniqueString: String { get }
}

public protocol Configurable {
    var appModules: ApplicationModules { get }
    var settings: SettingsConfigurable { get }
    var session: Sessionable { get }
    var notificationServices: NotificationServiceable & NotificationRefreshable { get set }
    var userProfileStore: UserProfileStoring { get }
    var photosFetching: PhotosDataFetching { get }
    var uniqueStringProviding: UniqueStringProviding { get }
    func loadConfiguration(didFinish: @escaping ()-> Void)
    func addToLoad(block: @escaping ()-> Void)
}
