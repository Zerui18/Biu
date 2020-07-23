//
//  BiliKeys.swift
//  Bili
//
//  Created by Zerui Chen on 4/7/20.
//

import Foundation

/**
 * 客户端固有属性. 包括版本号, 密钥以及硬件编码.
 * 默认值对应 5.37.0(release-b220051) 版本.
 */
enum BKKeys: String {
    /**
     * 默认 UA, 用于大多数访问
     */
    case defaultUserAgent = "Mozilla/5.0 BiliDroid/6.5.0 (bbcallen@gmail.com) os/android model/Android SDK built for x86_64 mobi_app/android build/6050500 channel/bili innerVer/6050500 osVer/9 network/2"

    /**
     * Android 平台的 appKey(该默认值为普通版客户端, 非概念版)
     */
    case appKey = "1d8b6e7d45233436"

    /**
     * 由反编译 so 文件得到的 appSecret, 与 appKey 必须匹配
     */
    case appSecret = "560c52ccd288fed045859ed18bffd973"

    /**
     * 获取视频播放地址使用的 appKey, 与访问其他 RestFulAPI 所用的 appKey 是不一样的
     */
    case videoAppKey = "iVGUTjsxvpLeuDCf"

    /**
     * 获取视频播放地址所用的 appSecret
     */
    case videoAppSecret = "aHRmhWMLkdeMuILqORnYZocwMBpMEOdt"

    /**
     * 客户端平台
     */
    case platform = "android"

    /**
     * 客户端类型
     * 此属性在旧版客户端不存在
     */
    case channel = "bili"

    /**
     * 硬件 ID, 尚不明确生成算法
     */
    case hardwareId = "Pw09DT0NOQ04DTsNcQ1x"

    /**
     * 屏幕尺寸, 大屏手机(已经没有小屏手机了)统一为 xxhdpi
     * 此参数在新版客户端已经较少使用
     */
    case scale = "xxhdpi"

    /**
     * 版本号
     */
    case version = "6.4.0"

    /**
     * 构建版本号
     */
    case build = "6040500"

    /**
     * 构建版本 ID, 可能是某种 Hash
     */
    case buildVersionId = "XY0BB210515E35F2DBD8DFF2C75B2263BA9F6"
}
