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
    
    
    @discardableResult
    func request(_ target: Target, option: WSRequestOption = .`default`, completion: @escaping (_ result: Result<WebSocketResult>) -> Void) -> TaskCancellable? {
        plugins.forEach { $0.willSend(target) }
        
        let request = WSRequest.requestWithTarget(target, option: option)
        let cancellable = accessLayer.sendRequest(request) { [weak self] (rawResponse) in
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
            
            let value = WebSocketResult(path: rawResponse.path, contentDict: jsonDict)
            let result = Result<WebSocketResult>.success(value)
            self?.plugins.forEach { $0.willReceive(result, target: target) }
            completion(result)
            self?.plugins.forEach { $0.didReceive(result, target: target) }
        }
        return cancellable
    }
    
    
}


/// WebSocket API 请求工具
struct WebSocketAPITool {
    
    typealias FailureBlk = (_ error: WSResponseError) -> Void
    typealias SuccessBlk = (_ dict: [AnyHashable: Any]) -> Void
    
    
    /// 发送请求
    ///
    /// - Parameters:
    ///   - target: 目标接口
    ///   - plugins: 请求插件
    ///   - failureBlk: 失败回调
    ///   - successBlk: 成功回调
    @discardableResult
    static func request(target: WSTargetType,
                        plugins: [WSPluginType],
                        failureBlk: FailureBlk? = nil,
                        successBlk: @escaping SuccessBlk) -> TaskCancellable? {
        
        let provider = WSProvider<WSMultiTarget>.init(plugins: plugins)
        return provider.request(WSMultiTarget(target)) { (result) in
            switch result {
            case let .success(response):
                successBlk(response.contentDict)
            case let .failure(error):
                let ns_err = (error as NSError)
                let ws_err = (error as? WSResponseError) ?? WSResponseError(code: ns_err.code, desc: ns_err.localizedDescription)
                failureBlk?(ws_err)
            }
        }
        
    }
}

extension WebSocketAPITool {
    /// 初始化配置
    static func initConfig() {
        _ = WSAccessLayer.shared
    }
}

