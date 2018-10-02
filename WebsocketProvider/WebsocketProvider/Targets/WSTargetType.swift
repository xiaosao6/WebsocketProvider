//
//  WSTargetType.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/17.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


/// 请求基础表示协议
protocol BaseTargetTypeConvertible {
    var baseURL: URL { get }
    var path: String { get }
}


/// WebSocket接口表示协议
protocol WSTargetType : BaseTargetTypeConvertible {
    /// url地址
    var baseURL: URL { get }
    /// 产品类型
    var product: String { get }
    /// 接口路径
    var path: String { get }
    /// 请求方法
    var method: WSMethod { get }
    /// 请求参数
    var parameters: [String: Any] { get }
    
    /// 测试数据
    var sampleData: Data { get }
}

extension WSTargetType {
    var product: String {
        return WSConstant.kProductName
    }
}




enum WSMultiTarget: WSTargetType {
    
    case target(WSTargetType)
    
    init(_ target: WSTargetType) {
        self = WSMultiTarget.target(target)
    }
    
    var target: WSTargetType {
        switch self {
        case .target(let t): return t
        }
    }
}

extension WSMultiTarget {
    var baseURL: URL {
        return target.baseURL
    }
    
    var path: String {
        return target.path
    }
    
    var method: WSMethod {
        return target.method
    }
    
    var parameters: [String : Any] {
        return target.parameters
    }
    
    var sampleData: Data {
        return target.sampleData
    }
}
