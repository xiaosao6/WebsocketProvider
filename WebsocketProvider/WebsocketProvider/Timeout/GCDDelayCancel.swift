//
//  GCDDelayCancel.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/14.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


extension DispatchWorkItem {
    
    typealias CancelableBlock = (_ cancel: Bool) -> Void
    
    /// 开启延时任务
    @discardableResult
    static func gcdDelay(time: TimeInterval, task: DispatchWorkItem, queue: DispatchQueue = .main) -> CancelableBlock? {
        func dispatchLater(block: DispatchWorkItem) {
            queue.asyncAfter(deadline: .now() + time, execute: block)
        }
        
        var closure: DispatchWorkItem? = task
        var result: CancelableBlock?
        
        let delayedClosure: CancelableBlock = { cancel in
            if let internalClosure = closure {
                if cancel == false {
                    queue.async(execute: internalClosure)
                }
            }
            closure = nil
            result = nil
        }
        
        result = delayedClosure
        
        let item = DispatchWorkItem.init {
            if let delayedClosure = result {
                delayedClosure(false)
            }
        }
        
        dispatchLater(block: item)
        
        return result
    }
    
    /// 取消还未执行的延时任务
    static func gcdCancel(task: CancelableBlock?) {
        task?(true)
    }
    
}
