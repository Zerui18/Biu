import BiliKit
import PlaygroundSupport

//let handle = BKClient.shared.login(username: "84685638", password: "A2Bzx578436").sink { (completion) in
//    print(completion)
//} receiveValue: { (response) in
//    print(response)
//}

let url = URL(string: "http://upos-hz-mirrorakam.akamaized.net/upgcxcode/50/58/210655850/210655850_nb2-1-30280.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEuENvNC8aNEVEtEvE9IMvXBvE2ENvNCImNEVEIj0Y2J_aug859r1qXg8xNEVE5XREto8GuFGv2U7SuxI72X6fTr859IB_&uipk=5&nbs=1&deadline=1594489186&gen=playurl&os=akam&oi=461222012&trid=0c60ac56c3404e73a89445438848e0d6u&platform=android&upsig=2fdfeb85ef24e477930b318d546cf28f&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,platform&hdnts=exp=1594489186~hmac=1b7d705b8a3719b549c3593fa5ab21546958ae44ce786604768f5f26bf66f6d9&mid=0&orderid=0,1&agrr=0&logo=80000000")!

//let query = [
//    "force_host" : "0",
//    "fnval" : "16",
//    "qn" : "32",
//    "npcybs" : "0",
////    "cid" : "210655850",
//    "fnver" : "0",
//    "aid" : "626292014",
//]
//
//let request: BKRequest<[Int]> = BKAnyEndpoint(url: url).createRequest(using: .get, withQuery: query)
//
//let urlRequest = request.createURLRequest()
//
//URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
//    guard error == nil else {
//        print("error:", error!)
//        return
//    }
//    print(String(data: data!, encoding: .utf8)!)
//    print()
//    print()
//
//    let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//    print(json)
//}.resume()
//
//PlaygroundPage.current.needsIndefiniteExecution = true
