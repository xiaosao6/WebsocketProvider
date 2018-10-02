//
//  WSUniqueIDGenerator.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/9/13.
//  Copyright © 2018年 Xiaosao6® All rights reserved.
//

import Foundation


/// WebSocket 唯一ID生成器
struct WSUniqueIDGenerator {
    
    private static var value: Int = 1
    
    private static var internal_lock: Int = 0
    
    /// 生成ID
    static func getID() -> Int {
        objc_sync_enter(internal_lock)
        value += 1
        let result = value
        objc_sync_exit(internal_lock)
        return result
    }
    
}
