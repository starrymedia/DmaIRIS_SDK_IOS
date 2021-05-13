//
//  SouvenirCardService.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2021/2/24.
//

import Foundation
public let SouvenirCardService = SouvenirCardServiceSession.default

open class SouvenirCardServiceSession: AbstractService  {
    
    public static let `default` = SouvenirCardServiceSession()
    
    
    /**
     * 卡信息签名
     *
     * @param ticketEntity
     * @param privateKey
     * @return
     */
    public func doSign(ticketEntity: SouvenirCardInfo, privateKey:String) -> DataStandard<SouvenirCardInfo> {
        let dataStandard = DataStandard<SouvenirCardInfo>()
        dataStandard.body = ticketEntity
        dataStandard.protoc = ProtocEnum.souvenirCard.rawValue
        dataStandard.sign(signPriKey: privateKey, pubKeyEnum: .base64)
        return dataStandard
    }
    
    
    /**
     * 创建票实卡
     *
     * @param ticket
     * @param privateKey
     * @return
     * @throws ServiceException
     */
    public func issueDenom(denom: Denom<SouvenirCardInfo>,
                           privateKey: String,
                           method: RpcMethods,
                           successCallback: @escaping (_ res: BroadcastModel) -> (),
                           errorCallback: @escaping FPErrorCallback) {
        
        NFTService.issueNft(sender: denom.create,
                            nftName: denom.name,
                            denom: denom.denom,
                            nftSchema: Schema.souvenirCard.toJSONString(),
                            privateKey: privateKey,
                            method: method) { broadcastModel in
            successCallback(broadcastModel)
        } errorCallback: { error in
            errorCallback(error)
        }
    }
    
    public func issueDenomTxBody(denom: Denom<SouvenirCardInfo>) -> TxBody {
        
        let txBody = NFTService.createMsgIssueDenom(sender: denom.create, nftName: denom.name, denom: denom.denom, nftSchema: Schema.souvenirCard.toJSONString())
        return txBody
    }
    /**
     * 发行卡
     *
     * @param ticketEntities
     * @param sender
     * @param recipient
     * @param privateKey
     * @param isSign
     * @return
     * @throws ServiceException
     */
    public func mintToken( tx: TxTx,
                           method: RpcMethods,
                           successCallback: @escaping (_ res: BroadcastModel) -> (),
                           errorCallback: @escaping FPErrorCallback) {
        
        RpcService.broadcast(tx: tx, method: method) { res in
            successCallback(res)
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    public func mintTokenGas(ticketEntities: [SouvenirCardInfo],
                            sender: String,
                            recipient: String,
                            privateKey: String,
                            isSign: Bool,
                            gasLimit: UInt64 = 0,
                            feeAddress: String = "",
                            fee: String = "",
                            method: RpcMethods,
                            successCallback: @escaping (_ tx: TxTx) -> (),
                            errorCallback: @escaping FPErrorCallback) {
        
//        var builder = TxBody()
//        
//        for ticketEntity in ticketEntities {
//            
//            var dataStandard = DataStandard<SouvenirCardInfo>()
//            
//            dataStandard.body = ticketEntity
//            dataStandard.protoc = ProtocEnum.souvenirCard.rawValue
//            if (isSign) {
//                dataStandard.sign(signPriKey: privateKey, pubKeyEnum: .base64)
//            }
//            
//            var nft = NftMsgMintNFT()
//            nft.data = dataStandard.toJSONString() ?? ""
//            nft.recipient = recipient
//            nft.sender = sender
//        
//            nft.denomID = ticketEntity.denomId
//            nft.name = ticketEntity.name
//            nft.id = ticketEntity.tokenId
//            nft.uri = ticketEntity.imgUrl
//            
//            if let any =  TxUtils.getProtobufAny(message: nft, typePrefix: "") {
//                builder.messages.append(any)
//            }
//        }
//        
//        builder.memo = ""
//        builder.timeoutHeight = 0
        
        var builder = self.getCardsTxBody(ticketEntities: ticketEntities,
                                          sender: sender,
                                          recipient: recipient,
                                          privateKey: privateKey,
                                          isSign: isSign)
        //转手续费
        if feeAddress != "" && fee != "" {
            let bankMsgSend = TokenService.getBankMsgSend(from: sender,
                                                          to: feeAddress,
                                                          denom: IRISServive.defaultCoin,
                                                          amount: fee)
            if let any =  TxUtils.getProtobufAny(message: bankMsgSend, typePrefix: "") {
                builder.messages.append(any)
            }
        }
        
        TxService.signTx(txBody: builder,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            successCallback(tx)
         } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    public func getCardsTxBody(ticketEntities: [SouvenirCardInfo],
                               sender: String,
                               recipient: String,
                               privateKey: String,
                               isSign: Bool) -> TxBody {
        var builder = TxBody()
        
        for ticketEntity in ticketEntities {
            
            var dataStandard = DataStandard<SouvenirCardInfo>()
            
            dataStandard.body = ticketEntity
            dataStandard.protoc = ProtocEnum.souvenirCard.rawValue
            if (isSign) {
                dataStandard.sign(signPriKey: privateKey, pubKeyEnum: .base64)
            }
            
            var nft = NftMsgMintNFT()
            nft.data = dataStandard.toJSONString() ?? ""
            nft.recipient = recipient
            nft.sender = sender
        
            nft.denomID = ticketEntity.denomId
            nft.name = ticketEntity.name
            nft.id = ticketEntity.tokenId
            nft.uri = ticketEntity.imgUrl
            
            if let any =  TxUtils.getProtobufAny(message: nft, typePrefix: "") {
                builder.messages.append(any)
            }
        }
        
        builder.memo = ""
        builder.timeoutHeight = 0
        
        return builder
    }
    
    public func newUserBuild(from: String, to: String) -> TxBody {
        
        
        var body = TxBody()
        body.memo = ""
        body.timeoutHeight = 0

        let bankMsgSend = TokenService.getBankMsgSend(from: from,
                                                      to: to,
                                                      denom: IRISServive.defaultCoin,
                                                      amount: "100")
        if let any =  TxUtils.getProtobufAny(message: bankMsgSend, typePrefix: "") {
            body.messages.append(any)
        }

        return body
    }

    /**
     * 获取票详情
     *
     * @param nftId
     * @param tokenId
     * @return
     * @throws ServiceException
     */
    public func getTokenInfo(denomId: String,
                              tokenId: String,
                              successCallback: @escaping (_ ticketInfo: SouvenirCardInfo) -> (),
                              errorCallback: @escaping FPErrorCallback) {
        
        NFTService.tokenInfo(denom: denomId,
                             tokenId: tokenId) { nftToken in
                        
            let dataStandard = DataStandard<SouvenirCardInfo>.deserialize(from: nftToken.data)
            if let ticketInfo = dataStandard?.body {
                successCallback(ticketInfo)
            } else {
                errorCallback("ticketInfo is empty")
            }
        } errorCallback: { error in
            errorCallback(error)
        }

    }
    
    /**
     * 获取所有票
     *
     * @param nftId
     * @return
     * @throws ServiceException
     */
    public func getTokens(denomId: String,
                           successCallback: @escaping (_ ticket: Denom<SouvenirCardInfo>) -> (),
                           errorCallback: @escaping FPErrorCallback) {
        
        NFTService.nftTokens(denom: denomId) { nft in
            if let ticket = self.formatInfo(nft, schema: .souvenirCard) {
                successCallback(ticket)
            } else {
                errorCallback("error data")
            }
        } errorCallback: { error in
            errorCallback(error)
        }

    }
    
    /**
     * 根据账号获取所有票
     *
     * @param owner
     * @param nftId
     * @return
     * @throws ServiceException
     */
    public func myTokensByDenomId(owner: String,
                                  denomId: String,
                                  successCallback: @escaping (_ ticketList: [Denom<SouvenirCardInfo>]) -> (),
                                  errorCallback: @escaping FPErrorCallback) {
        
        self.getInfo(owner: owner,
                     denomId: denomId,
                     schema: .souvenirCard) { ticketList in
            successCallback(ticketList)
        } errorCallback: { error in
            errorCallback(error)
        }
    
    }
    
    public func getInfo(owner: String,
                        denomId: String,
                        schema: Schema,
                        successCallback: @escaping (_ ticketList: [Denom<SouvenirCardInfo>]) -> (),
                        errorCallback: @escaping FPErrorCallback) {
       
        NFTService.balanceInfo(owner: owner,
                               denom: denomId) { nftTokenList in
            var denomList = [Denom<SouvenirCardInfo>]()
            for nft in nftTokenList {
                let ticket = self.formatInfo(nft, schema: schema)
                if ticket != nil {
                    denomList.append(ticket!)
                }
            }
            successCallback(denomList)
            
        } errorCallback: { error in
            errorCallback(error)
        }

    }
    
    public func formatInfo(_ nft: NFT, schema: Schema) -> Denom<SouvenirCardInfo>? {
        
        var schemaType = schema.getJSONValue(nft.schema)

        if schemaType != schema.rawValue {
            return nil
        }
        
        let denom = Denom<SouvenirCardInfo>()
        denom.create = nft.creator
        denom.denom = nft.id
        denom.name = nft.name
 
        let nftTokenList = nft.tokens
        var ticketInfos = [SouvenirCardInfo]()

        for nftToken in nftTokenList {
            if let dataStandard = DataStandard<SouvenirCardInfo>.deserialize(from: nftToken.data) {
                dataStandard.verify();
                if let body = dataStandard.body {
                    ticketInfos.append(body)
                }
            }
        }
        denom.infos = ticketInfos
        return denom
    }

}
