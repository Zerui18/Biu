import BiliKit
import PlaygroundSupport

//let handle = BKClient.shared.login(username: "84685638", password: "asdfasdfa").sink { (completion) in
//    print(completion)
//} receiveValue: { (response) in
//    print(response)
//}

let request = BKAppEndpoint.getUserSpace.createRequest(using: .get, withQuery: ["from":"0", "ps":"100", "vmid":"282994"])
    .createURLRequest()

URLSession.shared.dataTask(with: request) { data, _, _ in
    print(String(data: data!, encoding: .utf8)!)
}.resume()


PlaygroundPage.current.needsIndefiniteExecution = true
