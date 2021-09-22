//
//  TokenService.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/15.
//

import Foundation

public let TokenService = TokenServiceSession.default

open class TokenServiceSession {
        
    public static let `default` = TokenServiceSession()
    
    
    /// 创建同质化Token
    /// - Parameters:
    ///   - initialSupply: 初始化数量
    ///   - maxSupply: 最大数量
    ///   - name: 名称
    ///   - symbol: 简称
    ///   - mintable: 是否可增发
    ///   - owner: token所有者钱包地址
    ///   - privateKey: 私钥
    public func issueToken(initialSupply: UInt64,
                           maxSupply: UInt64,
                           tokenName: String,
                           denom: String,
                           mintAble: Bool,
                           owner: String,
                           gasLimit: UInt64 = 0,
                           privateKey: String,
                           method: RpcMethods = .broadcastTxAsync,
                           successCallback: @escaping (_ res: BroadcastModel) -> (),
                           errorCallBack: @escaping FPErrorCallback) {
    
        var token = TokenMsgIssueToken()
        token.symbol = denom
        token.initialSupply = initialSupply
        token.maxSupply = maxSupply
        token.mintable = true
        token.scale = 6
        token.name = tokenName
        token.minUnit = denom
        token.mintable = mintAble
        token.owner = owner
        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: token, typePrefix: "") {
            txBody.messages.append(any)
        }
        
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            RpcService.broadcast(tx: tx, method: method) { broadcast in
                successCallback(broadcast)
            } errorCallBack: { error in
                errorCallBack(error)
            }
            
        }errorCallBack: { error in
            errorCallBack(error)
        }
    }
    
    /// 根据简称 增发同质化Token
    /// - Parameters:
    ///   - to: 地址
    ///   - symbol: 简称
    ///   - owner: token所有者钱包地址
    ///   - amount: 价格
    ///   - privateKey: 私钥
    public func mintToken(denom: String,
                          amount: UInt64,
                          tokenOwner: String,
                          recipient: String,
                          gasLimit: UInt64 = 0,
                          privateKey: String,
                          method: RpcMethods = .broadcastTxAsync,
                          successCallback: @escaping (_ res: BroadcastModel) -> (),
                          errorCallBack: @escaping FPErrorCallback) {
        
        
        var token = TokenMsgMintToken()
        token.symbol = denom
        token.amount = amount

        token.owner = tokenOwner
        token.to = recipient
        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: token, typePrefix: "") {
            txBody.messages.append(any)
        }
        
        let fee = TxUtils.getFee(gasLimit: txGasLimit, amount: txAmount, denom: txDenom)
        
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            RpcService.broadcast(tx: tx, method: method) { broadcast in
                successCallback(broadcast)
            } errorCallBack: { error in
                errorCallBack(error)
            }
            
        }errorCallBack: { error in
            errorCallBack(error)
        }
    }
    
    /**
     * 更换同质化Token Owner
     *
     * @param denom
     * @param tokenOwner
     * @param recipient
     * @param privateKey
     */
    public func transferOwnership(denom: String,
                                  tokenOwner: String,
                                  recipient: String,
                                  gasLimit: UInt64 = 0,
                                  privateKey: String,
                                  method: RpcMethods = .broadcastTxAsync,
                                  successCallback: @escaping (_ res: BroadcastModel) -> (),
                                  errorCallBack: @escaping FPErrorCallback) {

        var token = TokenMsgTransferTokenOwner()
        token.symbol = denom
  
        token.srcOwner = tokenOwner
        token.dstOwner = recipient
        
        var txBody = TxUtils.getBody(meno: "", timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: token, typePrefix: "") {
            txBody.messages.append(any)
        }
        
        let fee = TxUtils.getFee(gasLimit: txGasLimit, amount: txAmount, denom: txDenom)
        
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            RpcService.broadcast(tx: tx, method: method) { res in
                successCallback(res)
            } errorCallBack: { error in
                errorCallBack(error)
            }
            
        }errorCallBack: { error in
            errorCallBack(error)
        }
    }
    
    
    /**
     * 转送同质化token
     *
     * @param from
     * @param to
     * @param denom
     * @param amount
     * @param privateKey
     */
    public func transfer(from: String,
                         to: String,
                         denom: String,
                         amount: Decimal,
                         privateKey: String,
                         successCallback: @escaping (_ res: BroadcastModel) -> (),
                         errorCallBack: @escaping FPErrorCallback) {
        self.transfer(from: from,
                      to: to,
                      denom: denom,
                      amount: amount,
                      memo: "",
                      privateKey: privateKey,
                      successCallback: successCallback,
                      errorCallBack: errorCallBack)
    }
    
    /**
       * 转送同质化token
       * @param from
       * @param to
       * @param denom
       * @param amount
       * @param privateKey
    */
    public func transfer(from: String,
                         to: String,
                         denom: String,
                         amount: Decimal,
                         memo: String,
                         privateKey: String,
                         successCallback: @escaping (_ res: BroadcastModel) -> (),
                         errorCallBack: @escaping FPErrorCallback) {
        
        self.toWei(tokenSymblol: denom,
                   amount: amount) { amount in
            self.sendTransfer(from: from,
                              to: to,
                              denom: denom,
                              amount: amount,
                              memo: memo,
                              privateKey: privateKey,
                              successCallback: successCallback,
                              errorCallBack: errorCallBack)
        } errorCallBack: { error in
            errorCallBack(error)
        }

       
    }
    
    func sendTransfer(from: String,
                      to: String,
                      denom: String,
                      amount: String,
                      memo: String,
                      gasLimit: UInt64 = 0,
                      privateKey: String,
                      method: RpcMethods = .broadcastTxAsync,
                      successCallback: @escaping (_ res: BroadcastModel) -> (),
                      errorCallBack: @escaping FPErrorCallback) {
        
//        var coin = BaseCoin()
//        coin.amount = amount
//        coin.denom = denom

        let msgSend = self.getBankMsgSend(from: from, to: to, denom: denom, amount: amount)
//        msgSend.fromAddress = from
//        msgSend.toAddress = to
//        msgSend.amount.append(coin)

        var txBody = TxUtils.getBody(meno: memo, timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: msgSend, typePrefix: "") {
            txBody.messages.append(any)
        }
        
 
        //调用签名方法
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            
            RpcService.broadcast(tx: tx, method: method) { result in
                successCallback(result)
            } errorCallBack: { error in
                errorCallBack(error)
            }

        } errorCallBack: { error in
            errorCallBack(error)
        }
        
    }
    
    func getBankMsgSend(from: String,
                                to: String,
                                denom: String,
                                amount: String) -> BankMsgSend {
        
        var coin = BaseCoin()
        coin.amount = amount
        coin.denom = denom
        
        var msgSend = BankMsgSend()
        msgSend.fromAddress = from
        msgSend.toAddress = to
        msgSend.amount.append(coin)
        
        return msgSend
    }
    
    
    func gasLimit(from: String,
                  to: String,
                  denom: String,
                  amount: String,
                  memo: String = "",
                  gasLimit: UInt64 = 0,
                  privateKey: String,
                  method: RpcMethods = .broadcastTxAsync,
                  successCallback: @escaping (_ gasLimit: UInt64) -> (),
                  errorCallBack: @escaping FPErrorCallback) {
        
        var coin = BaseCoin()
        coin.amount = amount
        coin.denom = denom
        
        var msgSend = BankMsgSend()
        msgSend.fromAddress = from
        msgSend.toAddress = to
        msgSend.amount.append(coin)
        
        var txBody = TxUtils.getBody(meno: memo, timeoutHeight: 0)
        if let any = TxUtils.getProtobufAny(message: msgSend, typePrefix: "") {
            txBody.messages.append(any)
        }
        
        //调用签名方法
        TxService.signTx(txBody: txBody,
                         gasLimit: gasLimit,
                         privateKey: privateKey) { tx in
            let gasLimit = tx.authInfo.fee.gasLimit
            successCallback(gasLimit)
        } errorCallBack: { error in
            errorCallBack(error)
        }
        
    }
        
    /// 根据denom(创建时的symbol)查询token信息
    /// - Parameters:
    ///   - denom: 分类ID
    ///   - callback: token信息
    /// - Returns:
    public func tokenInfo(denom: String,
                          successCallback: @escaping (_ token: Token) -> (),
                          errorCallBack: @escaping FPErrorCallback)  {
       
        var request = TokenQueryTokenRequest()
        request.denom = denom
        
        let client = TokenQueryClient(channel: IRISServive.channel)
        let response = client.token(request).response
        
        response.whenComplete { result in
            switch result {
            case .success(let value):
                if let token = try? TokenToken(serializedData: value.token.value) {
                    successCallback(self.formatToken(token))
                } else {
                    errorCallBack("Invalid data")
                }
            case .failure(let error):
                errorCallBack("\(error)")
            }
        }
    }
    

    /**
     * 根据地址查询拥有的token
     *
     * @param address
     * @return
     * @throws InvalidProtocolBufferException
     */
    public func tokensByOwner(owner: String,
                              successCallback: @escaping (_ list: [Token]) -> (),
                              errorCallBack: @escaping FPErrorCallback) {
        
        
        
        DispatchQueue.global().async {
            
            var pageRequest = PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var anyList = [ProtobufAny]()
            var errorResult = ""
            var flag = true
            
            while flag {
                let group = DispatchGroup()
                group.enter()

                var request = TokenQueryTokensRequest()
                request.pagination = pageRequest
                request.owner = owner
         
                let client = TokenQueryClient(channel: IRISServive.channel)
                let response = client.tokens(request).response
                response.whenComplete { result in
                    switch result {
                    case .success(let value):
                        let dataList = value.tokens
                        anyList.append(contentsOf: dataList)
                        
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
            
            var tokenList = [Token]()
            for item in anyList {
                if let token = try? TokenToken(serializedData: item.value) {
                    tokenList.append(self.formatToken(token))
                }
            }
            
            if errorResult.isEmpty {
                successCallback(tokenList)
            } else {
                errorCallBack(errorResult)
            }
        }
    }
    
    /**
     * mint资产，估算交易费
     *
     * @param denom
     * @return
     * @throws ServiceException
     */
    public func issueFees(denom: String,
                          successCallback: @escaping (_ coin: Coin) -> (),
                          errorCallBack: @escaping FPErrorCallback) {
        
        var request = TokenQueryFeesRequest()
        request.symbol = denom
        
        let response = TokenQueryClient(channel: IRISServive.channel).fees(request).response
        response.whenComplete { result in
            switch result {
            case .success(let value):
                self.formatCoin(coinOuter: value.issueFee) { coin in
                    successCallback(coin)
                } errorCallBack: { error in
                    errorCallBack(error)
                }
            case .failure(let error):
                errorCallBack("\(error)")
            }
        }
    }
    
    /**
       * 查询拥有的token
       * @param address
       * @param denom
       * @return
       * @throws ServiceException
    */
    public func balance(address: String,
                        denom: String = IRISServive.defaultCoin,
                        successCallback: @escaping (_ coin: Coin) -> (),
                        errorCallback: @escaping FPErrorCallback) {
                
        let client = BankQueryClient(channel: IRISServive.channel)
        var req = BankQueryBalanceRequest()
        req.address = address
        req.denom = denom
        let res = client.balance(req)
        res.response.whenComplete { result in
            switch result {
            case .success(let value):
               
                self.formatCoin(coinOuter: value.balance) { coin in
                    successCallback(coin)
                } errorCallBack: { error in
                    errorCallback(error)
                }
                
            case .failure(let error):
                errorCallback("\(error)")
            }
        }
    }
    

    /**
      * 查询所拥有的token
      * @param owner
    */
    public func allBalances(owner: String,
                            successCallback: @escaping (_ coins: [Coin]) -> (),
                            errorCallback: @escaping FPErrorCallback) {
                
        
        DispatchQueue.global().async {
            
            var pageRequest = Cosmos_Base_Query_V1beta1_PageRequest()
            pageRequest.countTotal = true
            pageRequest.limit = 100
            
            var coinList = [BaseCoin]()
            var errorResult = ""
            var flag = true
            
            while flag {
                let group = DispatchGroup()
                group.enter()

                let client = BankQueryClient(channel: IRISServive.channel)
                var request = BankQueryAllBalancesRequest()
                request.address = owner
                request.pagination = pageRequest
                let response = client.allBalances(request)
                response.response.whenComplete { result in
                    switch result {
                    case .success(let value):
                        
                        coinList.append(contentsOf: value.balances)
                        
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
                self.formatCoinArray(coinList: coinList) { list in
                    successCallback(list)
                } errorCallBack: { error in
                    errorCallback(error)
                }
            } else {
                errorCallback(errorResult)
            }
        }

    }
    
    /**
     * 总共的token
     *
     * @return
     * @throws ServiceException
     */
    public func totalSupply(successCallback: @escaping (_ coins: [Coin]) -> (),
                            errorCallback: @escaping FPErrorCallback) {
                
        let client = BankQueryClient(channel: IRISServive.channel)
        let req = BankQueryTotalSupplyRequest()

        let res = client.totalSupply(req)
        res.response.whenComplete { result in
            switch result {
            case .success(let value):
                let coinList = value.supply
                self.formatCoinArray(coinList: coinList) { coins in
                    successCallback(coins)
                } errorCallBack: { error in
                    errorCallback(error)
                }
            case .failure(let error):
                errorCallback("\(error)")
            }
        }
    }
    
    /**
     * token总量
     *
     * @param denom
     * @return
     * @throws ServiceException
     */
    public func supplyOf(denom: String,
                         successCallback: @escaping (_ coin: Coin) -> (),
                         errorCallback: @escaping FPErrorCallback) {
                
        let client = BankQueryClient(channel: IRISServive.channel)
        var req = BankQuerySupplyOfRequest()
        req.denom = denom
        let res = client.supplyOf(req)
        res.response.whenComplete { result in
            switch result {
            case .success(let value):
                self.formatCoin(coinOuter: value.amount) { coin in
                    successCallback(coin)
                } errorCallBack: { error in
                    errorCallback(error)
                }
            case .failure(let error):
                errorCallback("\(error)")
            }
        }
    }
    
    /// 精度转换
    public func toWei(tokenSymblol: String,
                      amount: Decimal,
                      successCallback: @escaping (_ amount: String) -> (),
                      errorCallBack: @escaping FPErrorCallback) {
     
        self.tokenInfo(denom: tokenSymblol) { token in
            var amount = amount
            var result = Decimal()
            NSDecimalMultiplyByPowerOf10(&result, &amount, Int16(token.scale), .plain)
            var rounded = Decimal()
            NSDecimalRound(&rounded, &result, 0, .down)
            let resultstring = NSDecimalString(&rounded, nil)
            successCallback(resultstring)
        } errorCallBack: { error in
            errorCallBack(error)
        }

    }
    
    /// 精度转换
    public func gettToWei(tokenSymblol: String) {
     
        self.tokenInfo(denom: tokenSymblol) { token in
            IRISServive.scale = Int(token.scale)
        } errorCallBack: { error in
//            errorCallBack(error)
        }

    }
    
    /// 精度转换
    public func forWei(tokenSymblol: String,
                            amount: Decimal,
                            successCallback: @escaping (_ amount: String) -> (),
                            errorCallBack: @escaping FPErrorCallback) {
     
        self.tokenInfo(denom: tokenSymblol) { token in
            var amount = amount
            var result = Decimal()
            NSDecimalMultiplyByPowerOf10(&result, &amount, -Int16(token.scale), .plain)
            let resultstring = NSDecimalString(&result, nil)
            successCallback(resultstring)
        } errorCallBack: { error in
            print(error)
            errorCallBack(error)
        }
    }
    
    func formatToken(_ token: TokenToken) -> Token {
        
        let entity = Token()
        entity.initialSupply = token.initialSupply
        entity.maxSupply = token.maxSupply
        entity.mintAble = token.mintable
        entity.minUnit = token.minUnit
        entity.name = token.name
        entity.scale = token.scale
        entity.symbol = token.symbol
        entity.owner = token.owner
        return entity
    }
    
    func formatCoin(coinOuter: BaseCoin,
                    successCallback: @escaping (_ coin: Coin) -> (),
                    errorCallBack: @escaping FPErrorCallback) {
        
        guard let amount = Decimal(string: coinOuter.amount) else {
            print("amount error")
            return
        }
        self.forWei(tokenSymblol: coinOuter.denom,
                   amount: amount) { amount in
            var coin = Coin()
            coin.denom = coinOuter.denom
            coin.amount = amount
            successCallback(coin)
        } errorCallBack: { error in
            errorCallBack(error)
        }

    }
        
    func formatCoinArray(coinList: [BaseCoin],
                         successCallback: @escaping (_ coins: [Coin]) -> (),
                         errorCallBack: @escaping FPErrorCallback) {
       
        for item in coinList {
            self.toWei(tokenSymblol: item.denom,
                       amount: Decimal(string: item.amount)!) { amount in
                var coins = [Coin]()
                var coin = Coin()
                coin.denom = item.denom
                coin.amount = amount
                coins.append(coin)
                successCallback(coins)
            } errorCallBack: { error in
                errorCallBack(error)
            }

        }
    }
}
