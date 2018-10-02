//
//  ViewController.swift
//  WebsocketProvider
//
//  Created by sischen on 2018/10/1.
//  Copyright © 2018年 XiaoSao6. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        WebSocketAPITool.request(target: MyAPI.test, plugins: []) { (dict) in
            print("result:\(dict)")
        }
        
        super.touchesBegan(touches, with: event)
    }

}




enum MyAPI {
    case test
}

extension MyAPI: WSTargetType{
    var baseURL: URL {
        return URL.wSocketBaseURL
    }
    
    var path: String {
        return "/test"
    }
    
    var method: WSMethod {
        return .post
    }
    
    var parameters: [String : Any] {
        return ["key1": "value1"]
    }
    
    var sampleData: Data {
        return Data()
    }
}


