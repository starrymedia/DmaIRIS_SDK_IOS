//
//  BroadcastDataModel.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/14.
//

import Foundation
import HandyJSON

public struct BroadcastModel: HandyJSON {
    public init() { }
    public var jsonrpc: String?
    public var id: String?
    public var result: BroadcastResult?
}

public struct BroadcastResult: HandyJSON {
    public init() { }
    public var hash: String?
    public var height: String?
    public var check_tx: BroadcastTx?
    public var deliver_tx: BroadcastTx?
}

public struct BroadcastTx: HandyJSON {
    public init() { }
    public var code: Int?
    public var data: Any?
    public var log: String?
    public var info: String?
    public var gas_wanted: String?
    public var gas_used: String?
    public var codespace: String?
    public var events: [Any]?
}

public struct BroadcastRequest<T:Encodable>: Encodable {
    public let id: String
    public let jsonrpc: String
    public let method: String
    public let params: T
    
    public init(id: String, jsonrpc: String, method: String, params: T) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.method = method
        self.params = params
    }

}

public struct BroadcastRequestParams: Encodable {
    public let tx: String
    
    public init(tx: String) {
        self.tx = tx
    }
}
