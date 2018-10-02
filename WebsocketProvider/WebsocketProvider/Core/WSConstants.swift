//
//  WSConstants.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


/// WebSocket请求方法
public enum WSMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


/// WebSocket字符常量
struct WSConstant {
    static let kUniqueId    = "uniqueId"
    static let kProduct     = "product"
    static let kService     = "service"
    static let kMethod      = "method"
    static let kContent     = "content"
    static let kError       = "error"
    static let kErrorCode   = "code"
    static let kErrorDesc   = "desc"
    static let kServerTime  = "time"
    
    /// App端默认产品名称
    static let kProductName = "app_iOS"
}


extension URL {
    /// WebSocket连接地址
    static var wSocketBaseURL: URL {
        return URL(string: "ws://192.168.1.134:9090/services")! // 本地示例: "ws://192.168.1.130:8080"
    }
}


extension String {
    /// WebSocket心跳
    static var heartbeat: String {
        let dict: [String: Any] = [WSConstant.kService:     "system/heart-beat",
                                   WSConstant.kUniqueId:    WSUniqueIDGenerator.getID(),
                                   WSConstant.kProduct:     WSConstant.kProductName,
                                   WSConstant.kMethod:      WSMethod.post.rawValue
                                   ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let string = String(data: jsonData, encoding: .utf8)!
        return string
    }
    
    /// 是否包含中文
    var containsChinese: Bool {
        for (_, value) in self.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
}
