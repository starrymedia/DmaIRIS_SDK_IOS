//
//  MsgSend.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/16.
//

import Foundation
import HandyJSON

public class MsgSend: IrisMessage {

    public var fromAddress: String = ""
    public var toAddress: String = "-"
    public var amount: [Coin] = []
}


public class MsgMultiSend: IrisMessage {

    public var inputs: [Input] = []
    public var outputs: [Output] = []
}

public class Input: HandyJSON {

    required public init() {
        
    }
    public var address: String = ""
    public var coins: [Coin] = []
}

public class Output: HandyJSON {

    required public init() {
        
    }
    public var address: String = ""
    public var coins: [Coin] = []
}

 
public class MsgIssueToken: IrisMessage {
    
    public var symbol: String = ""
    public var name: String = ""
    public var scale: UInt32 = 0
    public var minUnit: String = ""
    public var initialSupply: UInt64 = 0
    public var maxSupply: UInt64 = 0
    public var mintAble: Bool = false
    public var owner: String = ""
}

public class MsgEditToken: IrisMessage {
    
    public var symbol: String = ""
    public var name: String = ""
    public var maxSupply: UInt64 = 0
    public var mintAble: String = ""
    public var owner: String = ""
}

public class MsgMintToken: IrisMessage {
    
    public var symbol: String = ""
    public var to: String = ""
    public var owner: String = ""
    public var amount: UInt64 = 0
}

public class MsgTransferTokenOwner: IrisMessage {
    
    public var srcOwner: String = ""
    public var dstOwner: String = ""
    public var symbol: String = ""

}

public class MsgIssueNFT: IrisMessage {
    
    public var denom: String = ""
    public var name: String = ""
    public var schema: String = ""
    public var sender: String = ""

}

public class MsgMintNFT: IrisMessage {
    
    public var tokenId: String = ""
    public var denom: String = ""
    public var name: String = ""
    public var uri: String = ""
    public var data: String = ""
    public var sender: String = ""
    public var recipient: String = ""
}

public class MsgEditNFT: IrisMessage {
    
    public var tokenId: String = ""
    public var denom: String = ""
    public var name: String = ""
    public var uri: String = ""
    public var data: String = ""
    public var sender: String = ""
 }

public class MsgTransferNFT: IrisMessage {
    
    public var tokenId: String = ""
    public var denom: String = ""
    public var name: String = ""
    public var uri: String = ""
    public var data: String = ""
    public var sender: String = ""
    public var recipient: String = ""
}

public class MsgBurnNFT: IrisMessage {
    
    public var tokenId: String = ""
    public var denom: String = ""
    public var sender: String = ""
 }
