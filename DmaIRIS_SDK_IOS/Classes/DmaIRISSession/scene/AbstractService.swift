//
//  AbstractService.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2021/2/24.
//

import Foundation
import HandyJSON

open class AbstractService  {
    
    /**
     * 修改nftData
     *
     * @param nftId
     * @param tokenId
     * @param owner
     * @param ownerPrivateKey
     * @param signData
     * @return
     * @throws ServiceException
     */
    public func editData(denomId: String,
                         tokenId: String,
                         owner: String,
                         ownerPrivateKey: String,
                         signData: String,
                         method: RpcMethods,
                         successCallback: @escaping (_ broadcastModel: BroadcastModel) -> (),
                         errorCallback: @escaping FPErrorCallback) {
        
        NFTService.editToken(owner: owner,
                             denom: denomId,
                             tokenId: tokenId,
                             data: signData,
                             name: "",
                             uri: "",
                             privateKey: ownerPrivateKey,
                             method: method) { broadcastModel in
            
            successCallback(broadcastModel)
        } errorCallback: { error in
            errorCallback(error)
        }

    }

    /**
     * 验证票
     *
     * @param nftId
     * @param tokenId
     * @param base64PubKey
     * @return
     * @throws ServiceException
     */
    public func verifySign<T:BaseInfo>(denomId: String,
                                        tokenId:String,
                                        typeInfo: T,
                                        base64PubKey:String,
                                        successCallback: @escaping (_ verify: Bool) -> (),
                                        errorCallback: @escaping FPErrorCallback) {
        
        NFTService.tokenInfo(denom: denomId,
                             tokenId: tokenId) { nftToken in
            
            let dataStandard = DataStandard<T>.deserialize(from: nftToken.data)
            let verify = dataStandard!.verify(verifyKey: base64PubKey)
            successCallback(verify)
        } errorCallback: { error in
            errorCallback(error)
        }
    }
    public func verifySign<T:BaseInfo>(denomId: String,
                                       tokenId: String,
                                       typeInfo: T,
                                       successCallback: @escaping (_ verify: Bool) -> (),
                                       errorCallback: @escaping FPErrorCallback) {
        self.verifySign(denomId: denomId,
                        tokenId: tokenId,
                        typeInfo: typeInfo,
                   base64PubKey: "") { verify in
            successCallback(verify)
        } errorCallback: { error in
            errorCallback(error)
        }
    }
    
    /**
     * 销毁票
     *
     * @param owner
     * @param nftId
     * @param tokenId
     * @param privateKey
     * @return
     * @throws ServiceException
     */
    public func burnToken(owner: String,
                           nftId: String,
                           tokenId: String,
                           privateKey: String,
                           method: RpcMethods,
                           successCallback: @escaping (_ broadcastModel: BroadcastModel) -> (),
                           errorCallback: @escaping FPErrorCallback) {
        
        NFTService.burnToken(owner: owner,
                             denom: nftId,
                             tokenId: tokenId,
                             privateKey: privateKey,
                             method: method) { broadcastModel in
            successCallback(broadcastModel)
        } errorCallback: { error in
            errorCallback(error)
        }

    }
    
    ///转送NFT
    public func transferToken(sender: String,
                              recipient: String,
                              denom: String,
                              tokenIds: [String],
                              memo: String,
                              privateKey: String,
                              gasLimit: UInt64 = 0,
                              method: RpcMethods,
                              successCallback: @escaping (_ res: BroadcastModel) -> (),
                              errorCallback: @escaping FPErrorCallback) {
        NFTService.transferToken(sender: sender,
                           recipient: recipient,
                           denom: denom,
                           tokenIds: tokenIds,
                           memo: memo,
                           gasLimit: gasLimit,
                           privateKey: privateKey,
                           method: method,
                           successCallback: successCallback,
                           errorCallback: errorCallback)
    }
    
 
   
}


