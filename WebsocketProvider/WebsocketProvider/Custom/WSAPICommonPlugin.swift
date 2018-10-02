//
//  WSAPICommonPlugin.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/25.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



/// WebSocket请求通用插件
class WSAPICommonPlugin: WSPluginType {
    
    func willSend(_ target: WSTargetType) {
        var paramStr = ""
        var keyValues = [String]()
        for (key, value) in target.parameters {
            keyValues.append(key + "=" + String(describing: value))
        }
        paramStr = keyValues.joined(separator: "&")
        print("请求地址:\n\(target.baseURL.absoluteString)\(target.path)?\(paramStr)") //TODO: -- debug模式才打印
    }
    
    func willReceive(_ result: Result<WebSocketResult>, target: WSTargetType) {
        
    }
    
    func didReceive(_ result: Result<WebSocketResult>, target: WSTargetType) {
        switch result {
        case let .success(wsresult):
            print("service:\(wsresult.path ?? ""),resultDict:\(wsresult.content.description)")
            let code = wsresult.content["ret_code"] as? String ?? ""
            let msg  = wsresult.content["ret_msg"]  as? String
            if (code != "0000") {
                print("弹出toast提示:\(String(describing: msg))")
                //TODO: -- 弹出toast错误提示
            }
        case let .failure(error):
            print("error:\(error)")
            //TODO: -- 判断网络是否可用
            //TODO: -- 弹出toast错误提示
        }
    }
    
}
