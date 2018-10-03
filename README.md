
# WebsocketProvider
An encapsulation of ios websocket client `Starscream` for custom API usage. 

对iOS的Websocket客户端`Starscream`的功能封装，使调用Websocket API变得像HTTP API一样简单。


---
# WebsocketProvider
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
    String service; //服务URI，由业务后端开发告知前端
    String method;  //HTTP访问类型 GET POST PUT DELETE PATCH，不填则默认POST
    String content; //服务需要的参数，JSON字符串，由业务后端开发告知前端
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
    ErrorCode error;//一级错误码，非业务错误，出现错误将会赋值
    long uniqueId;  //原值返回
    String product; //原值返回
    String service; //原值返回
    String method;  //原值返回
    String content; //内容格式由业务后端开发告知前端
```
```json
ErrorCode{
    int code; 	 //错误码: 1=非法协议体;2=服务繁忙;3=服务内部错误;4=请先登陆;...
    String desc; //错误描述
}
```

- 类结构图（待补充）



### 使用方法
暂未制作Pod库，需直接下载工程，拷贝WebsocketProvider/WebsocketProvider目录，根据实际需求和数据协议作调整后(WSConstants.swift)，即可使用

### 环境要求
- iOS 8.0+、Xcode 9.0+

## License
none

