//
//  NetworkListener.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/14.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



/// 网络状态
typealias ReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus




protocol NetworkStateChangeDelegate: class {
    func networkStateChanged(_ state: ReachabilityStatus)
}



extension Notification.Name {
    /// 网络状态变化的通知
    static var networkStateDidChange: Notification.Name {
        return Notification.Name("networkStateDidChangeNotification")
    }
}



/// 网络状态监听器
class NetworkListener {
    
    let reachabilityMgr: NetworkReachabilityManager?
    
    
    weak var delegate: NetworkStateChangeDelegate?
    
    
    var isNetReachable: Bool {
        return reachabilityMgr?.isReachable ?? false
    }
    
    
    init(host: String) {
        reachabilityMgr = NetworkReachabilityManager(host: host)
        reachabilityMgr?.listener = { [weak self] (status) in
            print("当前网络状态:\(status)")
            self?.delegate?.networkStateChanged(status)
            NotificationCenter.default.post(name: .networkStateDidChange, object: status)
        }
        reachabilityMgr?.startListening()
    }
    
}
