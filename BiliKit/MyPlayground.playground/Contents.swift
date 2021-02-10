import BiliKit
import PlaygroundSupport

//let handle = BKClient.shared.login(username: "84685638", password: "asdfasdfa").sink { (completion) in
//    print(completion)
//} receiveValue: { (response) in
//    print(response)
//}

//let request = BKAppEndpoint.getUserSpace.createRequest(using: .get, withQuery: ["from":"0", "ps":"100", "vmid":"282994"])
//    .createURLRequest()

//let task = BKAppEndpoint.getUserSpace(forMid: 282994)
//    .sink { (completion) in
//        print(completion)
//    } receiveValue: { (response) in
//        print(response)
//    }

let task = BKAnyEndpoint.init(url: URL(string: "https://passport.bilibili.com/api/v2/oauth2/info")!)
    .createRequest(using: .get, withQuery: ["access_token":"b0ccd3ae893a72b88e7aeebbed4bc281"])
    .fetch()
    .sink { (completion) in
        print(completion)
    } receiveValue: { (response: BKResponse<String>) in
        print(response)
    }



PlaygroundPage.current.needsIndefiniteExecution = true
