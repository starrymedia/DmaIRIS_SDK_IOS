//
//  NFTSession.swift
//  DmaIRIS_SDK_IOS
//
//  Created by StarryMedia on 2020/11/19.
//

import Foundation

public let NFTService = NFTSession.default

open class NFTSession {
    
    public static let `default` = NFTSession()

    /// 创建分类
    /// - Parameters:
    ///   - sender: 创建人地址
    ///   - nftName: 分类名称
    ///   - nftSchema: 简介
    ///   - denom: 唯一标识 3-64位字母/数组
    ///   - privateKey: 私钥
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func issueNft(sender: String,
                         nftName: String,
                         denom: String,
                         nftSchema: String,
                         gasLimit: UInt64 = 0,
                         privateKey: String,
                         method: RpcMethods,
                         successCallback: @escaping (_ res: BroadcastModel) -> (),
                         errorCallback: @escaping FPErrorCallback) {
        
        
//        //创建Nft.MsgIssueDenom
//        var msgIssueDenom = NftMsgIssueDenom()
//        msgIssueDenom.name = nftName
//        msgIssueDenom.schema = nftSchema
//        msgIssueDenom.id = denom
//        msgIssueDenom.sender = sender
//
//        //创建TxBody
//        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
//        if let any = TxUtils.getProtobufAny(message: msgIssueDenom, typePrefix: "") {
//            txBody.messages.append(any)
//        }
        
        let txBody = self.createMsgIssueDenom(sender: sender, nftName: nftName, denom: denom, nftSchema: nftSchema)
        //签名交易
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            //广播交易
            RpcService.broadcast(tx: tx, method: method) { res in
                print(res)
                successCallback(res)
            } errorCallBack: { error in
                errorCallback(error)
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    public func createMsgIssueDenom(sender: String,
                                    nftName: String,
                                    denom: String,
                                    nftSchema: String) -> TxBody {
        //创建Nft.MsgIssueDenom
        var msgIssueDenom = NftMsgIssueDenom()
        msgIssueDenom.name = nftName
        msgIssueDenom.schema = nftSchema
        msgIssueDenom.id = denom
        msgIssueDenom.sender = sender

        //创建TxBody
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: msgIssueDenom, typePrefix: "") {
            txBody.messages.append(any)
        }
        return txBody
    }
    
   
    
    /// 创建NFT资产
    /// - Parameters:
    ///   - sender: 创建人地址
    ///   - recipient: 接收人地址
    ///   - name: 分类名称
    ///   - data: 简介
    ///   - denom: 分类ID
    ///   - uri: 详细描述
    ///   - tokenIds: 同类型中多个ID不能重复 3-64位字母/数组，以字母开头
    ///   - privateKey: 私钥
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func mintToken(sender: String,
                          recipient: String,
                          denom: String,
                          tokenIds: [String],
                          name: String,
                          data: String,
                          uri: String,
                          gasLimit: UInt64 = 0,
                          privateKey: String,
                          method: RpcMethods,
                          successCallback: @escaping (_ res: BroadcastModel) -> (),
                          errorCallback: @escaping FPErrorCallback) {

        if (tokenIds == nil || tokenIds.count == 0) {
            print("Tokenid is empty");
        }
        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        for tokenId in tokenIds {
            var mintNft = NftMsgMintNFT()
            mintNft.data = data
            mintNft.denomID = denom
            mintNft.uri = uri
            mintNft.name = name
            mintNft.id = tokenId
            mintNft.sender = sender
            mintNft.recipient = recipient
            
            if let any =  TxUtils.getProtobufAny(message: mintNft,typePrefix: "") {
                txBody.messages.append(any)
            }
        }
        
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            
            RpcService.broadcast(tx: tx, method: method) { res in
                print(res)
                successCallback(res)
            } errorCallBack: { error in
                errorCallback(error)
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
        
    }
    
    /// 销毁NFT资产
    /// - Parameters:
    ///   - owner: 创建人地址
    ///   - denom: 分类ID
    ///   - tokenId: 资产ID
    ///   - privateKey: 私钥
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    func burnToken(owner: String,
                   denom: String,
                   tokenId: String,
                   privateKey: String,
                   gasLimit: UInt64 = 0,
                   method: RpcMethods,
                   successCallback: @escaping (_ string: BroadcastModel) -> (),
                   errorCallback: @escaping FPErrorCallback) {
        
        var msgBurnNFT = NftMsgBurnNFT()
        msgBurnNFT.sender = owner
        msgBurnNFT.denomID = denom
        msgBurnNFT.id = tokenId

        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: msgBurnNFT, typePrefix: "") {
            txBody.messages.append(any)
        }
                
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            
            RpcService.broadcast(tx: tx, method: method) { res in
                successCallback(res)
            }errorCallBack: { error in
                errorCallback(error)
            }
        }errorCallBack: { error in
            errorCallback(error)
        }
        
    }
    
    /**
      * 修改资产
      *
      * @param owner
      * @param denom
      * @param tokenId
      * @param data
      * @param name
      * @param uri
      * @param privateKey
      */
    public func editToken(owner: String,
                          denom: String,
                          tokenId: String,
                          data: String = "[do-not-modify]",
                          name: String = "[do-not-modify]",
                          uri: String = "[do-not-modify]",
                          gasLimit: UInt64 = 0,
                          privateKey: String,
                          method: RpcMethods,
                          successCallback: @escaping (_ res: BroadcastModel) -> (),
                          errorCallback: @escaping FPErrorCallback) {

        var nft = NftMsgEditNFT()
        nft.data = data
        nft.name = name
        nft.uri = uri
        nft.sender = owner
        nft.denomID = denom
        nft.id = tokenId

        if !uri.isEmpty {
            nft.name = uri
        }
        
        if !name.isEmpty {
            nft.uri = name
        }
        
        if !data.isEmpty {
            nft.data = data
        }
        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: nft, typePrefix: "") {
            txBody.messages.append(any)
        }

        
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            
            RpcService.broadcast(tx: tx, method: method) { res in
                successCallback(res)
            } errorCallBack: { error in
                errorCallback(error)
            }
        }errorCallBack: { error in
            errorCallback(error)
        }
        
    }
    
//    ///转送NFT
//    public func transferToken(sender: String,
//                              recipient: String,
//                              denom: String,
//                              tokenIds: [String],
//                              memo: String,
//                              privateKey: String,
//                              gasLimit: UInt64 = 0,
//                              method: RpcMethods,
//                              successCallback: @escaping (_ res: BroadcastModel) -> (),
//                              errorCallback: @escaping FPErrorCallback) {
//        self.transferToken(sender: sender,
//                           recipient: recipient,
//                           denom: denom,
//                           tokenIds: tokenIds,
//                           memo: memo,
//                           gasLimit: gasLimit,
//                           privateKey: privateKey,
//                           method: method,
//                           successCallback: successCallback,
//                           errorCallback: errorCallback)
//    }

    /// 批量转送NFT
    /// - Parameters:
    ///   - sender: 创建人地址
    ///   - recipient: 接收人地址
    ///   - name: 分类名称
    ///   - data: 简介
    ///   - denom: 分类
    ///   - uri: 详细描述
    ///   - tokenIds: 同类型中多个ID不能重复 3-64位字母/数组，以字母开头
    ///   - privateKey: 私钥
    public func transferToken(sender: String,
                              recipient: String,
                              denom: String,
                              tokenIds: [String],
                              memo: String,
                              gasLimit: UInt64 = 0,
                              privateKey: String,
                              method: RpcMethods,
                              successCallback: @escaping (_ res: BroadcastModel) -> (),
                              errorCallback: @escaping FPErrorCallback) {
        
//        var txBody = TxUtils.getBody(meno: memo, timeoutHeight: 0)
//        for tokenId in tokenIds {
//            var transferNFT = NftMsgTransferNFT()
//            transferNFT.denomID = denom
//            transferNFT.uri = "[do-not-modify]"
//            transferNFT.name = "[do-not-modify]"
//            transferNFT.data = "[do-not-modify]"
//            transferNFT.id = tokenId
//            transferNFT.sender = sender
//            transferNFT.recipient = recipient
//
//            if let any = TxUtils.getProtobufAny(message: transferNFT,typePrefix: "") {
//                txBody.messages.append(any)
//            }
//        }
        
        let txBody = self.getTransferTokenBody(sender: sender,
                                               recipient: recipient,
                                               denom: denom,
                                               tokenIds: tokenIds,
                                               memo: memo)
                
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            
            RpcService.broadcast(tx: tx, method: method) { res in
                successCallback(res)
            } errorCallBack: { error in
                errorCallback(error)
            }
        }errorCallBack: { error in
            errorCallback(error)
        }
        
    }
    
    public func getTransferTokenBody(sender: String,
                                     recipient: String,
                                     denom: String,
                                     tokenIds: [String],
                                     memo: String) -> TxBody {
        
        var txBody = TxUtils.getBody(meno: memo, timeoutHeight: 0)
        for tokenId in tokenIds {
            var transferNFT = NftMsgTransferNFT()
            transferNFT.denomID = denom
            transferNFT.uri = "[do-not-modify]"
            transferNFT.name = "[do-not-modify]"
            transferNFT.data = "[do-not-modify]"
            transferNFT.id = tokenId
            transferNFT.sender = sender
            transferNFT.recipient = recipient
            
            if let any = TxUtils.getProtobufAny(message: transferNFT,typePrefix: "") {
                txBody.messages.append(any)
            }
        }
        
        return txBody
    }
    
    
    
    /// 根据nft id 查询nftx信息
    /// - Parameters:
    ///   - denom: 分类ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func nftInfo(denom: String,
                        successCallback: @escaping (_ nft: NFT) -> (),
                        errorCallback: @escaping FPErrorCallback) {
        
        var request = NftQueryDenomRequest()
        request.denomID = denom
        
        let client = NftQueryClient(channel: IRISServive.channel)
        let response = client.denom(request).response
        response.whenComplete { result in
            switch result {
            case .success(let value):
                let nft = self.formatNft(value.denom)
                successCallback(nft)
            case .failure(let error):
                errorCallback("\(error)")
            }
        }
    }
    

    /// 查询链上所有nft信息
    /// - Parameter callback: callback description
    public func allNfts(successCallback: @escaping (_ denoms: [NFT]) -> (),
                        errorCallback: @escaping FPErrorCallback) {
        
        DispatchQueue.global().async {
            
            var pageRequest = PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var denoms = [NFT]()
            var errorResult = ""
            var flag = true

            while flag {
                
                let group = DispatchGroup()
                group.enter()

                var request = NftQueryDenomsRequest()
                request.pagination = pageRequest
                let client = NftQueryClient(channel: IRISServive.channel)
                let response = client.denoms(request).response

                response.whenComplete { result in
                    switch result {
                    case .success(let value):

                        let list = self.formatNftList(value.denoms)
                        denoms.append(contentsOf: list)
                        print(value.pagination.nextKey.count)
                        if value.pagination.nextKey.isEmpty {
                            flag = false
                            group.leave()
                        } else {
                            pageRequest.key = value.pagination.nextKey
                            group.leave()
                        }
                     case .failure(let error):
                        errorResult = error.localizedDescription
                        flag = false
                        group.leave()
                     }
                }
                
                group.wait()
            }
            
            if errorResult.isEmpty {
                successCallback(denoms)
            } else {
                errorCallback(errorResult)
            }
        }
    }
    
    
    /// 根据nft id查询nft token 详情
    /// - Parameters:
    ///   - denom: 分类ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func nftTokens(denom: String,
                          successCallback: @escaping (_ denom: NFT) -> (),
                          errorCallback: @escaping FPErrorCallback) {
        
        DispatchQueue.global().async {
            
            var pageRequest = PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var nftList = [NftBaseNFT]()
            var nftdenom = NftDenom()
            var errorResult = ""
            var flag = true

            while flag {
                
                let group = DispatchGroup()
                group.enter()

                var request = NftQueryCollectionRequest()
                request.denomID = denom
                request.pagination = pageRequest
                let client = NftQueryClient(channel: IRISServive.channel)
                let response = client.collection(request).response

                response.whenComplete { result in
                    switch result {
                    case .success(let value):
                        nftdenom = value.collection.denom
                        let baseNFTList = value.collection.nfts
                        nftList.append(contentsOf: baseNFTList)
                        print(value.pagination.nextKey.count)
                        if value.pagination.nextKey.isEmpty {
                            flag = false
                            group.leave()
                        } else {
                            pageRequest.key = value.pagination.nextKey
                            group.leave()
                        }
                     case .failure(let error):
                        errorResult = error.localizedDescription
                        flag = false
                        group.leave()
                     }
                }
                group.wait()
            }
            
            if errorResult.isEmpty {
                let nft = self.formatNft(nftdenom)
                let tokenList = self.formatNftTokenList(nftList)
                nft.tokens = tokenList
                successCallback(nft)
            } else {
                errorCallback(errorResult)
            }
 
        }

    }
    
    
    /// 查询资产基础信息
    /// - Parameters:
    ///   - denom: 分类ID
    ///   - tokenId: 资产ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func tokenInfo(denom: String,
                          tokenId: String,
                          successCallback: @escaping (_ value: NFTToken) -> (),
                          errorCallback: @escaping FPErrorCallback) {
        
        var request = NftQueryNFTRequest()
        request.denomID = denom
        request.tokenID = tokenId
        let client = NftQueryClient(channel: IRISServive.channel)
        let response = client.nFT(request).response
        response.whenComplete { result in
            switch result {
            case .success(let value):
                successCallback(self.formatNftToken(value.nft))
            case .failure(let error):
                errorCallback("\(error)")
            }
        }

    }
    
    /// 根据地址和分类查询拥有的NFT 资产
    /// - Parameters:
    ///   - owner: 钱包地址
    ///   - denom: 分类ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func balance(owner: String,
                        denom: String,
                        successCallback: @escaping (_ list: [NFT]) -> (),
                        errorCallback: @escaping FPErrorCallback) {

        
        
        DispatchQueue.global().async {
            
            var pageRequest = PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var map = [String: [String]]()
            var errorResult = ""
            var flag = true

            while flag {
                
                let group = DispatchGroup()
                group.enter()

                var request = NftQueryOwnerRequest()
                request.denomID = denom.lowercased()
                request.owner = owner
                request.pagination = pageRequest
                
                let client = NftQueryClient(channel: IRISServive.channel)
                let response = client.owner(request).response

                response.whenComplete { result in
                    switch result {
                    case .success(let value):
                        
                        let idCollectionsList = value.owner.idCollections
                        var tokens = [String]()
                        for item in idCollectionsList {
                            tokens = map[item.denomID] ?? []
                            tokens.append(contentsOf: item.tokenIds)
                            map[item.denomID] = tokens
                        }

                        if value.pagination.nextKey.isEmpty {
                            flag = false
                            group.leave()
                        } else {
                            pageRequest.key = value.pagination.nextKey
                            group.leave()
                        }
                     case .failure(let error):
                        errorResult = error.localizedDescription
                        flag = false
                        group.leave()
                     }
                }
                group.wait()
            }
            
            if errorResult.isEmpty {
                 successCallback(self.formatNfts(map))
            } else {
                errorCallback(errorResult)
            }
            
        }

    }
    
    
    /// 根据地址和分类查询拥有的NFT 资产
    /// - Parameters:
    ///   - owner: 钱包地址
    ///   - denom: 分类ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func balanceInfo(owner: String,
                            denom: String,
                            successCallback: @escaping (_ nftList: [NFT]) -> (),
                            errorCallback: @escaping FPErrorCallback) {

        DispatchQueue.global().async {
            
            var pageRequest = PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var idCollections = [NftIDCollection]()
            var map = [String:[String]]()
            var errorResult = ""
            var flag = true
            
            while flag {
                let group = DispatchGroup()
                group.enter()

                var request = NftQueryOwnerRequest()
                request.denomID = denom.lowercased()
                request.owner = owner
                request.pagination = pageRequest
                
                let client = NftQueryClient(channel: IRISServive.channel)
                let response = client.owner(request).response

                response.whenComplete { result in
                    switch result {
                    case .success(let value):
                        
                        let idCollectionsList = value.owner.idCollections
                        var tokens = [String]()
                        for item in idCollectionsList {
                            tokens = map[item.denomID] ?? []
                            tokens.append(contentsOf: item.tokenIds)
                            map[item.denomID] = tokens
                        }
                        
                        idCollections.append(contentsOf: idCollectionsList)
                        
                        if value.pagination.nextKey.isEmpty {
                            flag = false
                            group.leave()
                        } else {
                            pageRequest.key = value.pagination.nextKey
                            group.leave()
                        }
                    case .failure(let error):
                        errorResult = error.localizedDescription
                        flag = false
                        group.leave()

                    }
                }
                group.wait()
            }
            if errorResult.isEmpty {
                
                self.formatNftInfo(map) { list in
                    successCallback(list)
                } errorCallback: { error in
                    errorCallback(error)
                }
            } else {
                errorCallback(errorResult)
            }
            
        }
        
  
    }
    
    /// 根据地址和分类查询拥有资产总数
    /// - Parameters:
    ///   - owner: 钱包地址
    ///   - denom: 分类ID
    ///   - successCallback: successCallback description
    ///   - errorCallback: errorCallback description
    public func supply(owner: String,
                       denom: String,
                       successCallback: @escaping (_ amount: UInt64) -> (),
                       errorCallback: @escaping FPErrorCallback) {

        var request = NftQuerySupplyRequest()
        request.owner = owner
        request.denomID = denom
        
        let response = NftQueryClient(channel: IRISServive.channel).supply(request).response
        response.whenComplete { result in
            switch result {
            case .success(let value):
                successCallback(value.amount)
            case .failure(let error):
                errorCallback("\(error)")
            }
        }
    }
    
    func formatNft(_ denom: NftDenom) -> NFT {
        let nft = NFT()
        nft.creator = denom.creator
        nft.id = denom.id
        nft.name = denom.name
        nft.schema = denom.schema
        return nft
    }

    func formatNftList(_ denoms: [NftDenom]) -> [NFT] {
        var list = [NFT]()
        for demo in denoms {
            list.append(formatNft(demo))
        }
        
        return list
    }
 
    func formatNftToken(_ baseNFT: NftBaseNFT) -> NFTToken {
        let token = NFTToken()
        token.owner = baseNFT.owner
        token.id = baseNFT.id
        token.name = baseNFT.name
        token.data = baseNFT.data
        token.uri = baseNFT.uri
        return token
    }
    
    func formatNftTokenList(_ baseNFTs: [NftBaseNFT]) -> [NFTToken] {
        var list = [NFTToken]()
        for item in baseNFTs {
            list.append(formatNftToken(item))
        }
        return list
    }

    func formatNftInfo(_ map:[String:[String]],
                       successCallback: @escaping (_ nftList: [NFT]) -> (),
                       errorCallback: @escaping FPErrorCallback) {
        var nftList = [NFT]()
        for denom in map.keys {

            self.nftInfo(denom: denom) { nft in
                
                let tokenids = map[denom] ?? []
                let nftTokens = nft.tokens
                var nftTokenList = [NFTToken]()
                for nftToken in nftTokens {
                    if (tokenids.contains(nftToken.id)) {
                        nftTokenList.append(nftToken)
                    }
                }
                nft.tokens = nftTokenList
                nftList.append(nft)
                successCallback(nftList)
            } errorCallback: { error in
                errorCallback(error)
            }

        }
    }

    func formatNfts(_ map:[String:[String]]) -> [NFT] {
        var nftList = [NFT]()
        
        for denom in map.keys {

            let nft = NFT()
            nft.id = denom

            let tokenids = map[denom] ?? []
            
            var list = [NFTToken]()
            for tokenid in tokenids {
                let nftToken = NFTToken()
                nftToken.id = tokenid
                list.append(nftToken)
            }
            nft.tokens = list
            nftList.append(nft)
        }
        return nftList
    }
}
