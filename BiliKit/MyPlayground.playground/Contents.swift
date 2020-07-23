import BiliKit
import PlaygroundSupport

//let handle = BKClient.shared.login(username: "84685638", password: "asdfasdfa").sink { (completion) in
//    print(completion)
//} receiveValue: { (response) in
//    print(response)
//}

print(BKSec.calculateSign(from: "appkey=bca7e84c2d947ac6&bili_local_id=86de45ac33d29d1b324af076ff106ca7202007221400349a8c8468afc1ae867d&build=6050500&buvid=XY0BB210515E35F2DBD8DFF2C75B2263BA9F6&c_locale=en_US&challenge=49895670b2db5a9e6c14f60418c432e6l8&channel=bili&device=phone&&device_name=unknownAndroid%20SDK%20built%20for%20x86_64&device_platform=Android9unknownAndroid%20SDK%20built%20for%20x86_64&dt=lORG75hgG0Amp%2Bw8b2mgIV%2F2FO7%2BWjjniZJdIpqOsGRQQYFXzrpFR7ZolkOR4iTLOH6V%2B6zoxumc%0AkZCFOrzpzeTYiMgbE6XD7DlaGoNngXnC6iv7i%2BXsWD3Qcs1BQ3Sa309fkR6JCickLpbtiO02n2Wl%0AoVRU%2FsXvx19o2RK3ijs%3D%0A&local_id=XY0BB210515E35F2DBD8DFF2C75B2263BA9F6&mobi_app=android&password=wMXoRL4vd6nmRMKSj%2Byl4AbJKpLe%2FjnXR0%2BSc4uN3WeqcV0yCNLeLe1GmVONq5vTNk4eVr7pOxqS%0A3pLrw%2BWuIlwe5MGB4HqgEtAanuPiM8gDbYaSUJnmgiQt6U6XM6%2FY0is4lYBZCr6Ou2zscpjs1Kdq%0Ax0arBpNci84XTyuZbRY%3D%0A&platform=android&s_locale=en_US&seccode=3f9edf010b5cdd9708f65085a4151791%7Cjordan&statistics=%7B%22appId%22%3A1%2C%22platform%22%3A3%2C%22version%22%3A%226.5.0%22%2C%22abtest%22%3A%22%22%7D&ts=1595427258&username=84685638&validate=3f9edf010b5cdd9708f65085a4151791"))


//PlaygroundPage.current.needsIndefiniteExecution = true
