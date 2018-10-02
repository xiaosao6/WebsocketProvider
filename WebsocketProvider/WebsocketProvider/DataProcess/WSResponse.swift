//
//  WSResponse.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



/// WebSocket错误类型
enum WSErrorType: Int {
    case requestTimeout     = -11
    case reachableError     = -12 // 本地网络配置异常
    case serverApiError     = -13 // 服务端连接异常
    case responseInvalid    = -14
}

extension WSErrorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .requestTimeout:
            return "请求超时"
        case .reachableError:
            return "网络连接失败"
        case .serverApiError:
            return "接口连接失败"
        case .responseInvalid:
            return "响应数据解析异常"
        }
    }
}



/// WebSocket错误
struct WSResponseError: Error {
    let code: Int
    let desc: String?
}


/// WebSocket响应
struct WSResponse: UniqueIdRepresentable {
    var uniqueId: Int
    /// 接口路径
    let path: String?
    /// 返回内容
    let content: String?
    
    /// 错误
    let error: WSResponseError?
    
//    let serverTime: Int64? // 服务器时间戳,例如1536318323658
}

extension WSResponse {
    public var hashValue: Int {
        return uniqueId.hashValue
    }
    
    static func ==(lhs: WSResponse, rhs: WSResponse) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }
}

extension WSResponse {
    
    static func responseWith(uniqueId: Int, path: String?, errorType: WSErrorType) -> WSResponse {
        let error = WSResponseError(code: errorType.rawValue, desc: errorType.description)
        return WSResponse(uniqueId: uniqueId, path: path, content: nil, error: error)
    }
}

