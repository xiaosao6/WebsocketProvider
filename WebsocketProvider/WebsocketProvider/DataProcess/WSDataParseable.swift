//
//  WSDataParseable.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


/// WS数据解析协议
protocol WSDataParseable {
    /// 解析字符为数据包
    static func parseMessage(_ message: String) -> WSResponse?
    /// 构建数据包为请求字符
    static func buildRequest(_ request: WSRequest) -> String?
}



typealias WSDataCodeable = WSDataEncodeable & WSDataDecodeable
/// WS数据加密协议
protocol WSDataEncodeable {
    static func encode(_ content: String) -> String
}
/// WS数据解密协议
protocol WSDataDecodeable {
    static func decode(_ content: String) -> String
}




/// WS数据解析器
struct WSDataParser: WSDataParseable {
    
    static func parseMessage(_ message: String) -> WSResponse? {
        guard let data = message.data(using: .utf8) else { return nil }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        guard let jsonDict = jsonObject as? [AnyHashable: Any] else { return nil }
        
        guard let uniqueId = (jsonDict[WSConstant.kUniqueId] as? Int) else { return nil }
        
        let path_     = jsonDict[WSConstant.kService] as? String
        let content   = jsonDict[WSConstant.kContent] as? String
//        let time      = jsonDict[WSConstant.kServerTime] as? Int64
        
        let error_     = jsonDict[WSConstant.kError] as? [AnyHashable: Any]
        let errorCode_ = error_?[WSConstant.kErrorCode] as? Int
        let errorDesc  = error_?[WSConstant.kErrorDesc] as? String
        
        guard let path = path_ else {
            return WSResponse.responseWith(uniqueId: uniqueId, path: nil, errorType: .responseInvalid)
        }
        
        var errObj: WSResponseError? = nil
        if let errorCode = errorCode_ { // 后台接口的WebSocket顶层错误码
            errObj = WSResponseError(code: errorCode, desc: errorDesc)
        }
        return WSResponse(uniqueId: uniqueId, path: path, content: content, error: errObj)
    }
    
    static func buildRequest(_ request: WSRequest) -> String? {
        var params = request.params
        for (key, value) in request.params {
            if let valueStr = value as? String, valueStr.containsChinese || valueStr.trimmingCharacters(in: .whitespaces).contains(" ") { // 含有中文,或中间含有空格
                let valueStrNew = valueStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                params.updateValue(valueStrNew, forKey: key)
            }
        }
        let paramData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        let paramStr  = String(data: paramData ?? Data(), encoding: .utf8) ?? ""
        
        let dict: [String: Any] = [WSConstant.kUniqueId:request.uniqueId,
                                   WSConstant.kProduct: request.header.product,
                                   WSConstant.kMethod:  request.header.method.rawValue,
                                   WSConstant.kService: request.header.path,
                                   WSConstant.kContent: paramStr]
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        if let jsonData = jsonData {
            return String(data: jsonData, encoding: .utf8)
        }
        print("\(#function):请求结构错误")
        return nil
    }
}

extension WSDataParser: WSDataCodeable {
    static func encode(_ content: String) -> String {
        return content
    }
    static func decode(_ content: String) -> String {
        return content
    }
}



fileprivate extension String {
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
