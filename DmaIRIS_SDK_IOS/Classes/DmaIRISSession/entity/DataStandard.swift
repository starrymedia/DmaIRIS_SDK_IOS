//
//  DataStandard.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/15.
//

import Foundation
import HandyJSON

public class DataStandard<T:HandyJSON>: HandyJSON {
    
    public var protoc: String = ""
    public var body: T? = nil
    public var signature: Signature? = nil

    required public init() {
        
        
    }
    
    public func sign(signPriKey: String, pubKeyEnum: PublicKeyEnum) {

        let body = self.body
        if body != nil {
            let bodySort = dataSort()
            var signDataEntity: SignDataEntity!
            switch pubKeyEnum {
            case .base64:
                signDataEntity = SignUtils.doSignDataEntity(data: bodySort, privateKey: signPriKey)
                break
            default:
                print("Public key type not supported")
                break
            }
            
            let pubKey = PublicKey(type: pubKeyEnum.rawValue, value: signDataEntity.pubKey)
            
            let signature = Signature()
            signature.pubKey = pubKey
            signature.sigData = signDataEntity.sig
            
            self.signature = signature
        }
    }
    
    public func verify() -> Bool {
        return verify(verifyKey: nil);
    }

    
    public func verify(verifyKey: String? = nil) -> Bool {
        if (self.body != nil && self.signature != nil) {
            
            let pubKey = self.signature?.pubKey

            if (pubKey == nil) {
                
                return false
            }
            
            if (!verifyKey!.isEmpty) {
                if (!pubKey!.value!.isEmpty && verifyKey == pubKey!.value) {
                    
                } else {
                    return false
                }

            }
            
            let signType = pubKey!.type
            let pubKeyEnum = PublicKeyEnum(rawValue: signType!)

            var falg = false
            switch (pubKeyEnum) {
            case .base64:
                falg = base64Verify(sig: self.signature!.sigData, base64PubKey: pubKey!.value!);
            default:
                print("Public key type not supported")
            }

            return falg

        }
        return false

    }
    
    public func base64Verify(sig: String, base64PubKey:String) -> Bool {
        let bodySort = dataSort()        
        return SignUtils.verify(data: bodySort, sig: sig, base64PubKey: base64PubKey);
        return false

    }


    
    public func dataSort() -> String {
        if (self.body == nil) {
            return "";
        }
        let bodyStr = self.body?.toJSONString()
        let bodySort = String((bodyStr?.sorted())!)
        return bodySort
    }

}


public enum PublicKeyEnum: String {
    case base64 = "/uptick.base64"
}

public class Signature: HandyJSON  {
    required public init() {
        
    }
    var sigData: String = ""
    var pubKey: PublicKey? = nil
}

public class PublicKey: HandyJSON {
    public required init() {
        
    }
    
    public init(type:String, value: String) {
        self.type = type
        self.value = value
    }
    public var type:String?
    public var value: String?
}



