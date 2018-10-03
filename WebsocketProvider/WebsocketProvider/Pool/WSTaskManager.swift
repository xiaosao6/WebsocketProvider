//
//  WSTaskManager.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/14.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



typealias WSResponseCompletion = (WSResponse) -> Void


/// 可取消协议
protocol TaskCancellable {
    var isCancelled: Bool { get }
    func cancel()
}


/// WebSocket请求任务
class WSRequestTask {
    let request: WSRequest
    /// 请求结束闭包
    let completionBlk: WSResponseCompletion?
    /// 请求超时后执行的闭包
    let timeOutBlk: DispatchWorkItem.CancellableBlock?
    
    /// 是否被取消
    fileprivate(set) var isCancelled = false
    
    
    init(_ request:     WSRequest,
         completionBlk: WSResponseCompletion?,
         timeOutBlk:    DispatchWorkItem.CancellableBlock?) {
        self.request = request
        self.completionBlk = completionBlk
        self.timeOutBlk = timeOutBlk
    }
}

extension WSRequestTask: Hashable{
    public var hashValue: Int {
        return request.uniqueId.hashValue
    }
    static func ==(lhs: WSRequestTask, rhs: WSRequestTask) -> Bool {
        return (lhs.request.uniqueId == rhs.request.uniqueId)
    }
}

extension WSRequestTask: TaskCancellable {
    func cancel() {
        if isCancelled { return }
        
        isCancelled = true
        DispatchWorkItem.gcdCancel(task: timeOutBlk) // 取消超时
        let response = WSResponse.responseWith(uniqueId: request.uniqueId, path: request.header.path, errorType: .requestCancelled)
        completionBlk?(response) // 回调错误
    }
}




protocol WSTaskTimeoutDelegate: class {
    func websocketRequestDidTimeout(_ request: WSRequest)
}



/// 请求任务管理器
class WSTaskManager {
    
    weak var delegate: WSTaskTimeoutDelegate?
    
    /// 请求任务池
    fileprivate var taskPool = Set<WSRequestTask>()
    
}

extension WSTaskManager {
    /// 添加新的任务
    @discardableResult
    func insertRequest(_ request: WSRequest, completion: WSResponseCompletion?) -> TaskCancellable {
        let blk = DispatchWorkItem.init { [weak self] in
            self?.delegate?.websocketRequestDidTimeout(request)
        }
        let timeOutBlk = DispatchWorkItem.gcdDelay(time: request.option.timeOutInterval, task: blk)
        let task = WSRequestTask(request, completionBlk: completion, timeOutBlk: timeOutBlk)
        
        if !(taskPool.contains(task)) {
            taskPool.insert(task)
        }
        return task
    }
    
    /// 移除某个任务
    func removeTaskWithId(_ uniqueId: Int) {
        var task: WSRequestTask?
        for tmptask in taskPool {
            if tmptask.request.uniqueId == uniqueId {
                task = tmptask
                break
            }
        }
        if let task = task {
            taskPool.remove(task)
        }
    }
    
    /// 移除所有任务
    func removeAllRequests() {
        taskPool.removeAll()
    }
    
    /// 获取某个任务
    func getTaskWithId(_ uniqueId: Int) -> WSRequestTask? {
        let filteredSet = taskPool.filter { $0.request.uniqueId == uniqueId }
        return filteredSet.first
    }
    
    /// 获取所有任务
    func getAllTasks() -> Set<WSRequestTask> {
        return taskPool
    }
}
