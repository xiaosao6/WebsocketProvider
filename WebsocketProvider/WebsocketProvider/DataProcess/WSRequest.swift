//
//  WSRequest.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



/// 唯一ID协议
protocol UniqueIdRepresentable: Hashable {
    var uniqueId : Int {get}
}



/// WebSocket请求
struct WSRequest: UniqueIdRepresentable {
    var uniqueId: Int
    let header: WSRequestHeader
    /// 请求参数
    let params: [String: Any]
    let option: WSRequestOption
}
extension WSRequest{
    public var hashValue: Int {
        return uniqueId.hashValue
    }
    
    static func ==(lhs: WSRequest, rhs: WSRequest) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }
}



/// 请求头部
struct WSRequestHeader {
    /// 接口路径
    let path: String
    /// 请求方法
    let method: WSMethod
    /// 客户端代号,如`App_iOS`
    let product: String
}


/// 请求选项
struct WSRequestOption {
    
    /// 超时时间
    let timeOutInterval: TimeInterval
    
    //TODO: --
    /// 失败后需要重发
    let needResend: Bool
    //TODO: --
    /// 已重发次数
    var resendCount: Int
    
    /// 默认配置
    static var `default`: WSRequestOption {
        return WSRequestOption(timeOutInterval: 15, needResend: false, resendCount: 0)
    }
}
