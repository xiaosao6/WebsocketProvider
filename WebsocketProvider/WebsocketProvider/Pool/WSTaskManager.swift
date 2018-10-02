//
//  WSTaskManager.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/14.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation



typealias WSResponseCompletion = (WSResponse) -> Void



/// WebSocket请求任务
struct WSRequestTask {
    let request: WSRequest
    let completionBlk: WSResponseCompletion?
    /// 请求超时后执行的闭包
    let timeOutBlk: DispatchWorkItem.CancelableBlock?
}
extension WSRequestTask: Hashable{
    public var hashValue: Int {
        return request.uniqueId.hashValue
    }
    static func ==(lhs: WSRequestTask, rhs: WSRequestTask) -> Bool {
        return (lhs.request.uniqueId == rhs.request.uniqueId)
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
    func insertRequest(_ request: WSRequest, completion: WSResponseCompletion?) {
        let blk = DispatchWorkItem.init { [weak self] in
            self?.delegate?.websocketRequestDidTimeout(request)
        }
        let timeOutBlk = DispatchWorkItem.gcdDelay(time: request.option.timeOutInterval, task: blk)
        let task = WSRequestTask(request: request, completionBlk: completion, timeOutBlk: timeOutBlk)
        
        if taskPool.contains(task) == false {
            taskPool.insert(task)
        }
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
