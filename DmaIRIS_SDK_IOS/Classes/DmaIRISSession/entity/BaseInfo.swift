//
//  BaseInfo.swift
//  Alamofire
//
//  Created by StarryMedia on 2021/2/24.
//

import Foundation
import HandyJSON

public class BaseInfo: HandyJSON {
    
    required public init() {
        
    }
    
    public var denomId: String = ""//分类
    public var tokenId: String = ""// 资产tokenID
    public var name: String = ""//资产名称
    public var imgUrl: String = ""//资产封面图片（大图）
    public var iconUrl: String = ""//资产图标（小图）
    public var backgroundColor: String = "" //资产可视展示时的底色（例如票的背景颜色）
    public var issuesTime: Int64 = 0 //发行时间
    public var description: String = "" //内容介绍

    public var issuesNumber: Int64 = 0 //单次发行数量
    public var issuesBatch: String = "" //发行批次

    //资产发行平台及发行方属性
    public var minter: String = "" //铸造资产平台名称（例如 Uptick Ticket）
    public var minterLogoUrl: String = "" //铸造者的Logo图片
    public var issuerName: String = "" //资产发布方名称
    public var issuerAddr: String = "" // 资产发布方唯一地址
    public var issuerLogoUrl: String = "" //资产发布方的Logo图片
 }
