//
//  OnsaleRequest.swift
//  Alamofire
//
//  Created by StarryMedia on 2021/3/5.
//

import Foundation

struct OnsaleRequest: Encodable {
    var owner: String?
    var denom: String?
    var labels: [Labels]?
    var tokenIds: [String]?
    var signatures: String?
    var callBack: String?
    var hash: String?
    var transfers: [TransferEntity]?
}


struct Labels: Encodable {
    let tokenId: String?
    let price: Int?
}
