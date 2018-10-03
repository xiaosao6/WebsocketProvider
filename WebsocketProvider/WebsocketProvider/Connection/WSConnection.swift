//
//  WSConnection.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation
import Starscream


typealias WSWebSocketClient = WebSocketClient


/// 连接配置
struct WSConnectionOption {
    /// 等待连接结果的超时
    let timeoutInterval: TimeInterval
    /// 重连间隔时间
    let reconnectInterval: TimeInterval
    /// 最多重连次数
    let reconnectMaxCount: Int
    /// 心跳间隔时间
    let heartbeatInterval: TimeInterval
    
    /// 默认配置
    static var `default`: WSConnectionOption {
        return WSConnectionOption(timeoutInterval: 5.0, reconnectInterval: 3.0, reconnectMaxCount: 20, heartbeatInterval: 15.0)
    }
}




/// WebSocket连接实现类
class WSWebSocketConnection {
    
    /// WebSocket事件代理
    weak var delegate: WSConnectionObservable?
    
    /// WebSocket客户端
    fileprivate var wsocket: WebSocket?
    
    /// 重连次数
    fileprivate var reconnectCount = 0
    
    /// 网络状态监听器
    private let networkListener: NetworkListener
    
    /// 下一次心跳block
    fileprivate var nextHeartbeatingBlk: DispatchWorkItem.CancellableBlock?
    
    
    init() {
        networkListener = NetworkListener(host: URL.wSocketBaseURL.host!)
        networkListener.delegate = self
    }
}

extension WSWebSocketConnection: NetworkStateChangeDelegate {
    func networkStateChanged(_ state: ReachabilityStatus) {
        switch state {
        case .reachable(.wwan), .reachable(.ethernetOrWiFi):
            openConnection()
        case .notReachable, .unknown:
            enableHeartBeating(false)
        }
    }
}

extension WSWebSocketConnection: WSConnectionProtocol {
    var isNetworkReachable: Bool {
        return networkListener.isNetReachable
    }
    
    var isConnected: Bool {
        return wsocket?.isConnected ?? false
    }
    
    func openConnection() {
        if isConnected {
            return
        }
        let timeout = WSConnectionOption.`default`.timeoutInterval
        let request = URLRequest(url: .wSocketBaseURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        wsocket = WebSocket.init(request: request)
        wsocket?.pongDelegate = self
        wsocket?.delegate = self
        wsocket?.connect()
        print("正在开启WebSocket连接...")
    }
    
    func closeConnection() {
        wsocket?.disconnect()
        wsocket = nil
        enableHeartBeating(false)
        print("正在关闭WebSocket连接...")
    }
    
    func sendMessage(_ message: String) {
        if !isConnected { return }
        wsocket?.write(string: message)
    }
    
}

extension WSWebSocketConnection {
    /// 重新连接
    fileprivate func retryConnect() {
        closeConnection()
        if networkListener.isNetReachable == false { return } // 断网时不重连
        if reconnectCount > WSConnectionOption.`default`.reconnectMaxCount { return }
        
        let reconnectDelay = WSConnectionOption.`default`.reconnectInterval
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            self?.openConnection()
        }
        reconnectCount += 1
        print("\(#function),Count:\(reconnectCount)")
    }
    
    /// 心跳配置
    fileprivate func enableHeartBeating(_ enable: Bool) {
        if enable {
            wsocket?.write(string: String.heartbeat)
            let delay = WSConnectionOption.`default`.heartbeatInterval
            nextHeartbeatingBlk = DispatchWorkItem.gcdDelay(time: delay, task: DispatchWorkItem(block: { [weak self] in
                self?.enableHeartBeating(true)
            }))
        } else {
            DispatchWorkItem.gcdCancel(task: nextHeartbeatingBlk)
        }
    }
}

extension WSWebSocketConnection: WebSocketDelegate {
    func websocketDidConnect(socket: WSWebSocketClient) {
        reconnectCount = 0 // 清空重连次数
        enableHeartBeating(true) // 开启心跳
        self.delegate?.onWebSocketOpened(socket)
        print("WebSocket连接成功!")
    }
    
    func websocketDidDisconnect(socket: WSWebSocketClient, error: Error?) {
        print("\(#function):\(error?.localizedDescription ?? "")")
        self.delegate?.onWebSocketClosed(socket, error: error)
        retryConnect()
        print("WebSocket连接已关闭!")
    }
    
    func websocketDidReceiveMessage(socket: WSWebSocketClient, text: String) {
        print("\(#function):\(text)")
        self.delegate?.onWebSocketMessage(text, client: socket)
    }
    func websocketDidReceiveData(socket: WSWebSocketClient, data: Data) { }
}

extension WSWebSocketConnection: WebSocketPongDelegate {
    func websocketDidReceivePong(socket: WSWebSocketClient, data: Data?) {
        let desc = String(data: data ?? Data(), encoding: .utf8) ?? ""
        print("\(#function):\(desc)")
        self.delegate?.onWebSocketReceivePong(data, client: socket)
    }
}
