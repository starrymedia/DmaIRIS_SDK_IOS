//
//  Merchant.swift
//  DmaIRIS_SDK_IOS
//
//  Created by StarryMedia on 2020/11/19.
//

import Foundation

let onsaleUrl = "/api/1/merchant/onsale"//上架
let offsaleUrl = "/api/1/merchant/offsale"//下架
let transferUrl = "/api/1/merchant/transfer"//购买
let allAssetUrl = "/api/1/query/allAsset" //所有上架的
let getAssetByDenomUrl = "/api/1/query/getAssetByDenom"//根据denom查询已上架的资产
let getTokenUrl = "/api/1/query/getToken"//获取已上架NFT信息
let allAssetByAddressUrl = "/api/1/query/allAssetByAddress"//根据钱包地址查询已上架的所有资产种类
let getTokensByAddressUrl = "/api/1/query/getTokensByAddress"//根据钱包地址以及类型查询已上架的所有NFT
let onsaleByHashUrl = "/api/1/merchant/onsaleByHash"//根据hash上下架

public let MerchantService = Merchant.default

public class Merchant {
    
    public static let `default` = Merchant()
    open var nodeUrl = ""

    init() {}

    //MARK:- 获取平台上架中的所有资产种类
    public func getAllAsset(successCallback: @escaping (_ denoms: [String]? ) -> (),
                            errorCallback: @escaping FPErrorCallback) {
        let url = nodeUrl + allAssetUrl
        IRISAF.getRequest(url: url) { jsonString in
            if let responseModel = AllAssetModel.deserialize(from: jsonString) {
                successCallback(responseModel.data ?? [])
            } else {
                errorCallback("getAllAsset error")
            }
        } errorCallBack: { error in
            errorCallback(error)
        }

    }
    
    //MARK:- 根据资产种类获取上架的NFT
    public func getAssetByDenom(denom: String,
                                successCallback: @escaping (_ asset: AssetDenom ) -> (),
                                errorCallback: @escaping FPErrorCallback) {
        let url = nodeUrl + getAssetByDenomUrl + "?denom=\(denom)"
        IRISAF.getRequest(url: url) { jsonString in
            if let responseModel = AssetModel.deserialize(from: jsonString) {
                if let data = responseModel.data {
                    successCallback(data)
                }
            } else {
                errorCallback("getAssetByDenom error")
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    //MARK:- 根据denom tokenid 获取已上架NFT信息
    public func getToken(denom: String, tokenId: String,
                         successCallback: @escaping (_ token: TokenDataModel) -> (),
                         errorCallback: @escaping FPErrorCallback) {
        let url = nodeUrl + getTokenUrl + "?denom=\(denom)&tokenId=\(tokenId)"
        
        IRISAF.getRequest(url: url) { jsonString in
            if let responseModel = TokenModel.deserialize(from: jsonString) {
                if let data = responseModel.data {
                    successCallback(data)
                } else {
                    successCallback(TokenDataModel())
                }
            } else {
                errorCallback("getToken error")
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    
    //MARK:- 根据钱包地址查询已上架的所有资产种类
    public func getAllAssetByAddress(address: String,
                                     successCallback: @escaping (_ token: [String] ) -> (),
                                     errorCallback: @escaping FPErrorCallback) {
        
        let url = nodeUrl + allAssetByAddressUrl + "?address=\(address)"
        
        IRISAF.getRequest(url: url) { jsonString in
            if let responseModel = AllAssetModel.deserialize(from: jsonString) {
                if responseModel.success {
                    successCallback(responseModel.data ?? [])
                } else {
                    errorCallback(responseModel.msg ?? "getToken error")
                }
            } else {
                errorCallback("getToken error")
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    //MARK:- 根据钱包地址以及类型查询已上架的所有NFT
    public func getTokensByAddress(address: String,
                                   denom: String,
                                   successCallback: @escaping (_ token: [TokenDataModel]? ) -> (),
                                   errorCallback: @escaping FPErrorCallback) {
        
        let url = nodeUrl + getTokensByAddressUrl + "?address=\(address)&denom=\(denom)"
        
        IRISAF.getRequest(url: url) { jsonString in
            if let responseModel = TokensModel.deserialize(from: jsonString) {
                if responseModel.success {
                    successCallback(responseModel.data)
                } else {
                    errorCallback(responseModel.msg ?? "getTokensByAddress error")
                }
            } else {
                errorCallback("getToken error")
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    public func onsale(denom: String,
                       tokenids: [String],
                       price: String,
                       transfers: [String: String]? = nil,
                       privateKey: String,
                       callback: String = "",
                       successCallback: @escaping (_ value: String) -> (),
                       errorCallback: @escaping FPErrorCallback) {
        

        //转换位数
        let amount = self.toWei(tokenSymblol: IRISServive.defaultCoin,
                                amount: Decimal(Double(price) ?? 0.0))
        print("amount:\(amount)")
        self.onsaleRequset(denom: denom,
                           tokenids: tokenids,
                           price: amount,
                           transfers: transfers,
                           privateKey: privateKey,
                           callback: callback,
                           successCallback: successCallback,
                           errorCallback: errorCallback)
    }
    
    func onsaleRequset(denom: String,
                       tokenids: [String],
                       price: String,
                       transfers: [String: String]? = nil,
                       privateKey: String,
                       callback: String,
                       successCallback: @escaping (_ value: String) -> (),
                       errorCallback: @escaping FPErrorCallback) {
        
        var params = OnsaleRequest()
        params.denom = denom
        params.owner = WalletManager.exportBech32Address(privateKey: privateKey)
        params.callBack = callback
        
        var labels = [Labels]()
        for tokenid in tokenids {
            let label = Labels(tokenId: tokenid, price: Int(price))
            labels.append(label)
        }
        params.labels = labels
        
        //判断是否需要转账
        if (transfers != nil && transfers!.count > 0) {
            //需要转账数组
            var transferEntityList = [TransferEntity]()
            for (key,value) in transfers! {
                var transferEntity = TransferEntity()
                let amount = Decimal(string: value)!
                let result = MerchantService.toWei(tokenSymblol:IRISServive.defaultCoin, amount: amount)
                transferEntity.received = key
                transferEntity.amount = result
                transferEntityList.append(transferEntity)
            }
            params.transfers = transferEntityList
        }

        self.getOnSaleTxBody(url: nodeUrl + onsaleUrl,
                             parameters: params,
                             privateKey: privateKey,
                             successCallback: successCallback,
                             errorCallback: errorCallback)
    }
    
 
    public func newUserOnsale(denom: String,
                              tokenids: [String],
                              price: String,
                              hash: String,
                              transfers: [String: String]? = nil,
                              privateKey: String,
                              callback: String = "",
                              successCallback: @escaping (_ value: String) -> (),
                              errorCallback: @escaping FPErrorCallback) {
        

        //转换位数
        let amount = self.toWei(tokenSymblol: IRISServive.defaultCoin,
                                amount: Decimal(Double(price) ?? 0.0))
        print("amount:\(amount)")
        self.newUserOnsaleRequset(denom: denom,
                           tokenids: tokenids,
                           price: amount,
                           hash: hash,
                           transfers: transfers,
                           privateKey: privateKey,
                           callback: callback,
                           successCallback: successCallback,
                           errorCallback: errorCallback)
    }
    
    func newUserOnsaleRequset(denom: String,
                              tokenids: [String],
                              price: String,
                              hash: String,
                              transfers: [String: String]? = nil,
                              privateKey: String,
                              callback: String,
                              successCallback: @escaping (_ value: String) -> (),
                              errorCallback: @escaping FPErrorCallback) {
        
        var params = OnsaleRequest()
        params.denom = denom
        params.owner = WalletManager.exportBech32Address(privateKey: privateKey)
        params.callBack = callback
        params.hash = hash
        
        var labels = [Labels]()
        for tokenid in tokenids {
            let label = Labels(tokenId: tokenid, price: Int(price))
            labels.append(label)
        }
        params.labels = labels
        
        //判断是否需要转账
        if (transfers != nil && transfers!.count > 0) {
            //需要转账数组
            var transferEntityList = [TransferEntity]()
            for (key,value) in transfers! {
                var transferEntity = TransferEntity()
                let amount = Decimal(string: value)!
                let result = MerchantService.toWei(tokenSymblol:IRISServive.defaultCoin, amount: amount)
                transferEntity.received = key
                transferEntity.amount = result
                transferEntityList.append(transferEntity)
            }
            params.transfers = transferEntityList
        }

        IRISAF.postRequest(url: nodeUrl + onsaleByHashUrl, parameters: params) { jsonString in
            successCallback(jsonString)
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    
    //http请求merchant 获取 TxBody
    func getOnSaleTxBody(url: String,
                         parameters: OnsaleRequest,
                         privateKey: String,
                         successCallback: @escaping (_ jsonString: String) -> (),
                         errorCallback: @escaping FPErrorCallback)
    {

        IRISAF.postRequest(url: url, parameters: parameters) { jsonString in
            
            guard let responseModel = MerchantResponseModel.deserialize(from: jsonString) else {
                errorCallback("onsale data error")
                return
            }
            
            if responseModel.success == false {
                errorCallback(responseModel.msg ?? "")
                return
            }
            
            guard let dataBase64String = responseModel.data  else {
                errorCallback("onsale data error")
                return
            }
           
            
            guard let base64Data = Data(base64Encoded: dataBase64String, options: Data.Base64DecodingOptions(rawValue:0)) else {
                errorCallback("onsale base64Data error")
                return
            }
            guard let body = try? TxBody(serializedData: base64Data) else {
                errorCallback("onsale serializedTxbody error")
                return
            }
            
            self.getOnSaleSignatures(url: url,
                                     txBody: body,
                                     parameters: parameters,
                                     privateKey: privateKey,
                                     successCallback: successCallback,
                                     errorCallback: errorCallback)
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    //获取签名
    func getOnSaleSignatures(url: String,
                             txBody: TxBody,
                             parameters: OnsaleRequest,
                             privateKey: String,
                             successCallback: @escaping (_ jsonString: String) -> (),
                             errorCallback: @escaping FPErrorCallback) {
        
        TxService.signTx(txBody: txBody, privateKey: privateKey) { tx in
            guard  let txString = try? tx.serializedData().base64EncodedString() else {
                errorCallback("onsale signTx error")
                return
            }
            
            var params = parameters
            params.signatures = txString
            self.requestOnSaleWithSignatures(url: url,
                                             parameters: params,
                                             privateKey: privateKey,
                                             successCallback: successCallback,
                                             errorCallback: errorCallback)
        } errorCallBack: { error in
            errorCallback(error)
        }
        
    }
     
    //再次请求merchant,获取结果
    func requestOnSaleWithSignatures(url: String,
                                 parameters: OnsaleRequest,
                                 privateKey: String,
                                 successCallback: @escaping (_ jsonString: String) -> (),
                                 errorCallback: @escaping FPErrorCallback) {
        IRISAF.postRequest(url: url, parameters: parameters) { jsonString in
            if let responseModel = MerchantResponseModel.deserialize(from: jsonString) {
                if responseModel.success == true {
                    successCallback(responseModel.data as? String ?? "")
                } else {
                    errorCallback(responseModel.msg ?? "")
                }
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    //MARK:- 下架
    public func offsale(denom: String,
                        tokenIds: [String],
                        privateKey: String,
                        callback: String,
                        successCallback: @escaping () -> (),
                        errorCallback: @escaping FPErrorCallback) {
        
        guard let publicKeyData = try? WalletManager.exportPublicKey(privateKey: privateKey) else {
            print("publicKey error")
            return
        }
        let publicKeyString = publicKeyData.base64EncodedString() ?? ""
        let address = WalletManager.exportBech32Address(privateKey: privateKey)

        let param = MerchantOffSale(callBack: callback,
                                    pubKey: publicKeyString,
                                    denom: denom,
                                    owner: address,
                                    tokenIds: tokenIds)
        
        let url = nodeUrl + offsaleUrl
        IRISAF.postRequest(url: url, parameters: param) { jsonString in
            if let responseModel = TokensModel.deserialize(from: jsonString) {
                if responseModel.success {
                    successCallback()
                } else {
                    errorCallback(responseModel.msg ?? "")
                }
            }
        } errorCallBack: { error in
            errorCallback("\(error)")
        }
    }
    
    //MARK:- 购买
    public func transfer(denom: String,
                        tokenIds: [String],
                        shares: [String: Double]? = nil,
                        privateKey: String,
                        memo: String,
                        callback: String,
                        successCallback: @escaping (_ data: String) -> (),
                        errorCallback: @escaping FPErrorCallback) {
        
        var param = TransferRequest()
        param.denom = denom
        param.tokenIds = tokenIds
        param.recipien = WalletManager.exportBech32Address(privateKey: privateKey)
        param.memo = memo
        param.callBack = callback
        
        if shares != nil && shares!.count > 0 {
            var shareEntityArrayList = [ShareEntity]()
            var total: Double = 0
            for (key,value) in shares! {
                total = total + value
                var shareEntity = ShareEntity()
                shareEntity.received = key
                shareEntity.rate = value
                shareEntityArrayList.append(shareEntity)
            }
            if total > 1 {
                errorCallback("Total rate greater than 1")
                return
            }
            param.shares = shareEntityArrayList
        }
        
        self.transferRequest(url: nodeUrl + transferUrl,
                             parameters: param,
                             privateKey: privateKey,
                             successCallback: successCallback,
                             errorCallback: errorCallback)

    }
    
    func transferRequest(url: String,
                         parameters: TransferRequest,
                         privateKey: String,
                         successCallback: @escaping (_ data: String) -> (),
                         errorCallback: @escaping FPErrorCallback) {
        
        IRISAF.postRequest(url: url, parameters: parameters) { jsonString in
            
            guard let responseModel = MerchantResponseModel.deserialize(from: jsonString) else {
                errorCallback("transfer data error")
                return
            }
            
            if responseModel.success == false {
                errorCallback(responseModel.msg ?? "")
                return
            }
            
            guard let dataBase64String = responseModel.data  else {
                errorCallback("transfer data error")
                return
            }
           
            
            guard let base64Data = Data(base64Encoded: dataBase64String, options: Data.Base64DecodingOptions(rawValue:0)) else {
                errorCallback("transfer base64Data error")
                return
            }
            guard let body = try? TxBody(serializedData: base64Data) else {
                errorCallback("transfer serializedTxbody error")
                return
            }
            
            //如果存在message,签名，不存在传address
            if body.messages.count > 0 {
                self.getTransferSignatures(url: url,
                                           txBody: body,
                                           parameters: parameters,
                                           privateKey: privateKey,
                                           successCallback: successCallback,
                                           errorCallback: errorCallback)

            } else {
                var params = parameters
                params.signatures = parameters.recipien
                self.requestTransferResult(url: url,
                                           parameters: params,
                                           successCallback: successCallback,
                                           errorCallback: errorCallback)

            }
        } errorCallBack: { error in
            errorCallback(error)
        }

    }
    
    //获取签名
    func getTransferSignatures(url: String,
                               txBody: TxBody,
                               parameters: TransferRequest,
                               privateKey: String,
                               successCallback: @escaping (_ jsonString: String) -> (),
                               errorCallback: @escaping FPErrorCallback) {
        
        TxService.signTx(txBody: txBody, privateKey: privateKey) { tx in
            guard  let txString = try? tx.serializedData().base64EncodedString() else {
                errorCallback("onsale signTx error")
                return
            }
            
            var params = parameters
            params.signatures = txString
            self.requestTransferResult(url: url,
                                       parameters: params,
                                       successCallback: successCallback,
                                       errorCallback: errorCallback)
        } errorCallBack: { error in
            errorCallback(error)
        }
        
    }
    
    //再次请求merchant,获取结果
    func requestTransferResult(url: String,
                               parameters: TransferRequest,
                               successCallback: @escaping (_ jsonString: String) -> (),
                               errorCallback: @escaping FPErrorCallback) {
        IRISAF.postRequest(url: url, parameters: parameters) { jsonString in
            if let responseModel = MerchantResponseModel.deserialize(from: jsonString) {
                if responseModel.success == true {
                    successCallback(responseModel.data as? String ?? "")
                } else {
                    errorCallback(responseModel.msg ?? "")
                }
            }
        } errorCallBack: { error in
            errorCallback(error)
        }
    }
    
    
    /// 精度转换
    public func toWei(tokenSymblol: String,
               amount: Decimal) -> String {
     
        var resultstring = ""
        let group = DispatchGroup()
        group.enter()

        TokenService.tokenInfo(denom: tokenSymblol) { token in
            var amount = amount
            var result = Decimal()
            NSDecimalMultiplyByPowerOf10(&result, &amount, Int16(token.scale), .plain)
            var rounded = Decimal()
            NSDecimalRound(&rounded, &result, 0, .down)
            resultstring = NSDecimalString(&rounded, nil)
            group.leave()

        } errorCallBack: { error in
            group.leave()
        }
        
        group.wait()
        return resultstring


    }

}

