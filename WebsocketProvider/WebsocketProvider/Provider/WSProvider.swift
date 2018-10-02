//
//  WSProvider.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/23.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation




fileprivate extension WSRequest {
    static func requestWithTarget(_ target: WSTargetType, option: WSRequestOption) -> WSRequest {
        let uniqueId = WSUniqueIDGenerator.getID()
        let header = WSRequestHeader(path: target.path, method: target.method, product: target.product)
        let params = target.parameters
        
        return WSRequest(uniqueId: uniqueId, header: header, params: params, option: option)
    }
}





class WSProvider<Target: WSTargetType> {
    
    private let accessLayer = WSAccessLayer.shared
    
    /// 插件数组
    let plugins: [WSPluginType]
    
    
    
    init(plugins: [WSPluginType] = []) {
        self.plugins = plugins
    }
    
    
    
    func request(_ target: Target, option: WSRequestOption = .`default`, completion: @escaping (_ result: Result<WebSocketResult>) -> Void) {
        plugins.forEach { $0.willSend(target) }
        
        let request = WSRequest.requestWithTarget(target, option: option)
        accessLayer.sendRequest(request) { [weak self] (rawResponse) in
            if let error = rawResponse.error {
                let result = Result<WebSocketResult>.failure(error)
                self?.plugins.forEach { $0.willReceive(result, target: target) }
                completion(result)
                self?.plugins.forEach { $0.didReceive(result, target: target) }
                return
            }
            
            guard let data = rawResponse.content?.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let jsonDict = jsonObject as? Dictionary<AnyHashable, Any> else {
                let errType = WSErrorType.responseInvalid
                let parseError = WSResponseError(code: errType.rawValue, desc: errType.description)
                
                let result = Result<WebSocketResult>.failure(parseError)
                self?.plugins.forEach { $0.willReceive(result, target: target) }
                completion(result)
                self?.plugins.forEach { $0.didReceive(result, target: target) }
                return
            }
            
            let value = WebSocketResult(path: rawResponse.path, content: jsonDict)
            let result = Result<WebSocketResult>.success(value)
            self?.plugins.forEach { $0.willReceive(result, target: target) }
            completion(result)
            self?.plugins.forEach { $0.didReceive(result, target: target) }
        }
        
    }
    
    
}


/// WebSocket API 请求工具
struct WebSocketAPITool {
    
    /// 发送请求
    ///
    /// - Parameters:
    ///   - target: 目标接口
    ///   - plugins: 请求插件
    ///   - failureBlk: 失败回调
    ///   - successBlk: 成功回调
    static func request(target: WSTargetType,
                        plugins: [WSPluginType],
                        failureBlk: ((_ error: WSResponseError?) -> Void)? = nil,
                        successBlk: @escaping (_ resultDic: [AnyHashable: Any]) -> Void) {
        
        let provider = WSProvider<WSMultiTarget>.init(plugins: plugins)
        provider.request(WSMultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                successBlk(response.content)
            case let .failure(error):
                failureBlk?(error as? WSResponseError)
            }
        }
        
    }
}

