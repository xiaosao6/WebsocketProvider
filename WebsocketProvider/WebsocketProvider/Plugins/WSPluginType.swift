//
//  WSPluginType.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/17.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


struct WebSocketResult {
    /// 接口路径
    let path: String?
    /// 返回json字典
    let contentDict: [AnyHashable: Any]
}




/// 插件表示协议
protocol WSPluginType {
    
    func willSend(_ target: WSTargetType)
    
    func willReceive(_ result: Result<WebSocketResult>, target: WSTargetType)
    
    func didReceive(_ result: Result<WebSocketResult>, target: WSTargetType)
    
}

