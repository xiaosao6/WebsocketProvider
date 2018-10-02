//
//  WSAccessLayer.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/14.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


/// WebSocket连接处理协议
protocol WSConnectionProtocol {
    var isConnected: Bool {get}
    var isNetworkReachable: Bool {get}
    
    func openConnection()
    func closeConnection()
    func sendMessage(_ message: String)
}



/// WebSocket事件回调
protocol WSConnectionObservable: class {
    func onWebSocketMessage(_ message: String, client: WSWebSocketClient)
    func onWebSocketOpened(_ client: WSWebSocketClient)
    func onWebSocketClosed(_ client: WSWebSocketClient, error: Error?)
    func onWebSocketReceivePong(_ data: Data?, client: WSWebSocketClient)
}




/// WebSocket请求处理层
class WSAccessLayer: NSObject {
    
    fileprivate lazy var connection: WSConnectionProtocol = {
        let conn = WSWebSocketConnection.init()
        conn.delegate = self
        return conn
    }()
    
    fileprivate lazy var taskManager: WSTaskManager = {
        let mgr = WSTaskManager.init()
        mgr.delegate = self
        return mgr
    }()
    
    
    static let shared = WSAccessLayer()
    private override init() {
        super.init()
        _ = self.connection
        _ = self.taskManager
    }
    
}

//MARK: ------------------------ Public
extension WSAccessLayer {
    func sendRequest(_ request: WSRequest, completion: WSResponseCompletion?) {
        if !(connection.isConnected) { // 未连接状态
            let errType: WSErrorType = connection.isNetworkReachable ? .serverApiError : .reachableError
            let response = WSResponse.responseWith(uniqueId: request.uniqueId, path: request.header.path, errorType: errType)
            completion?(response) // 直接回调:连接错误
            return
        }
        guard let messageString = WSDataParser.buildRequest(request) else { return }
        connection.sendMessage(messageString)
        taskManager.insertRequest(request, completion: completion)
    }
}

//MARK: ------------------------ WSConnectionObservable
extension WSAccessLayer: WSConnectionObservable {
    func onWebSocketMessage(_ message: String, client: WSWebSocketClient) {
        guard let response = WSDataParser.parseMessage(message) else { return }
        
        let task = taskManager.getTaskWithId(response.uniqueId)
        DispatchWorkItem.gcdCancel(task: task?.timeOutBlk) // 取消超时
        task?.completionBlk?(response) // 回调结果
        taskManager.removeTaskWithId(response.uniqueId)
    }
    
    func onWebSocketOpened(_ client: WSWebSocketClient) {
        
    }
    
    func onWebSocketClosed(_ client: WSWebSocketClient, error: Error?) {
        let taskSet = taskManager.getAllTasks()
        taskSet.forEach { (task) in
            let errType: WSErrorType = connection.isNetworkReachable ? .serverApiError : .reachableError
            let response = WSResponse.responseWith(uniqueId: task.request.uniqueId, path: task.request.header.path, errorType: errType)
            DispatchWorkItem.gcdCancel(task: task.timeOutBlk) // 取消超时
            task.completionBlk?(response) // 回调结果
        }
        taskManager.removeAllRequests()
    }
    
    func onWebSocketReceivePong(_ data: Data?, client: WSWebSocketClient) {
        
    }
}

//MARK: ------------------------ WSTaskTimeoutDelegate
extension WSAccessLayer: WSTaskTimeoutDelegate {
    func websocketRequestDidTimeout(_ request: WSRequest) {
        let response = WSResponse.responseWith(uniqueId: request.uniqueId, path: request.header.path, errorType: .requestTimeout)
        let task = taskManager.getTaskWithId(request.uniqueId)
        task?.completionBlk?(response) // 回调结果
        taskManager.removeTaskWithId(request.uniqueId)
    }
}
