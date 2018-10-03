
# WebsocketProvider

-------------

An encapsulation of ios websocket client `Starscream` for custom API usage. 

对iOS Websocket客户端`Starscream`的功能封装，使调用Websocket API变得像HTTP API一样简单。

-------------



### 示例:  
```swift
WebSocketAPITool.request(target: MyAPI.test, plugins: []) { (dict) in
    print("result:\(dict)")
}
```

### 特性
- 单个请求可定义超时、可中途取消
- 监听网络状态并自动处理重连、心跳机制
- 调用方式模仿Moya，使用遵守TargetType的enum定义API接口
- 正常返回数据为字典形式，转模型的方案需自行实现

### 原理描述

- 背景情况
 
公司项目有对多设备数据同步的要求，因此选用Websocket作为即时通信的方案，并且将原有的HTTP API也用Websocket方案作了一层封装，App端每次请求需将指定的数据通过协定的字符格式发送给后台，后台会返回相应的结果字符；每次请求用一个唯一序列号`uniqueId`，接口返回时也会携带同样的`uniqueId`，用以代表一次请求的落地。

- 请求协议格式：

```json
    long uniqueId;  //终端每次请求生成唯一序列号
    String product; //产品代号
    String service; //服务URI，由业务后端开发提供
    String method;  //HTTP访问类型 GET POST PUT DELETE PATCH，不填则默认POST
    String content; //服务需要的参数，JSON字符串，由业务后端开发提供
```

- 请求示例：

```json
{
    "uniqueId": 101,
    "product": "app_iOS",
    "service": "test-services/nlu/analyze",
    "content": "{\"userId\":1,\"robotId\":\"1\",\"question\":\"Are you OK?\"}"
}
```

- 返回协议格式：

```json
    ErrorCode error;//顶层错误码，非业务错误，有错误时出现
    long uniqueId;  //原值返回
    String product; //原值返回
    String service; //原值返回
    String method;  //原值返回
    String content; //内容格式由业务后端开发提供
    
    // 错误
    ErrorCode {
        "code": 2,        //错误码: 1=非法协议体; 2=服务繁忙; 3=服务内部错误; 4=请先登录;...
        "desc": "服务繁忙" //错误描述
    }
    
    // 正常content示例
    content: {
        "ret_code": "0000",    // 业务状态码,一般"0000"表示成功
        "ret_msg":  "操作成功", // 业务提示语
        "result":   (Object or Array) // 业务相关的对象或数组
    }
```

- 类定义说明

`WSWebSocketConnection` WebSocket连接实现类

`NetworkListener` 网络状态监听器

`WSConstants.swift` 常量配置

`WSUniqueIDGenerator` 唯一ID生成器

`WSAccessLayer` WebSocket请求处理层

`WSDataParser` WebSocket数据解析器

`WSResponse` WebSocket响应

`WSErrorType` WebSocket错误类型(非业务错误)

`WSRequest` WebSocket请求

`WSTaskManager` 请求任务管理器

`WSProvider` WebSocket API 提供类

`WSTargetType` WebSocket接口表示协议

`GCDDelayCancel.swift` 取消延时任务的扩展

`WSPluginType` 请求插件表示协议


### 使用方法
暂未制作Pod库，需直接下载工程，拷贝WebsocketProvider/WebsocketProvider目录，根据实际需求和数据协议作调整后(WSConstants.swift)，即可使用

### 环境要求
- iOS 8.0+、Xcode 9.0+

## License
none

