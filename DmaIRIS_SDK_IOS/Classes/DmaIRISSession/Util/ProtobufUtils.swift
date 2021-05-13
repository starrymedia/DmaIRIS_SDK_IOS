//
//  ProtobufUtils.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/16.
//

import Foundation

public class ProtobufUtils {
    
    public static func deserializeTx(code: String) -> Tx {

        let txResult = Tx()

        if code.isEmpty {
            print("tx can not be empty")
            return txResult
        }
        
        let txData = Data(base64Encoded: code)!
        let txObj = try? TxTx(serializedData: txData)
        
        if txObj?.body != nil && txObj?.body.messages != nil {
            let txBody = txObj?.body
            
            let body = Body()
            body.memo = txBody?.memo ?? ""
            body.timeoutHeight = txBody?.timeoutHeight ?? 0
            
            if let txBodyMessages = txBody?.messages {
                for msg in txBodyMessages {
                    if let message = unpackMsg(typeUrl: msg.typeURL, value: msg.value) {
                        body.messages.append(message)
                    }
                }
            }
            txResult.body = body
        }
        
        if txObj?.authInfo != nil {

            let authInfo = txObj?.authInfo
            
            let ai = AuthInfo()
            
            let fee = authInfo?.fee
            let amount = parseCoins(coinList: fee?.amount ?? [])
            let feeDto = FeeDto()
            feeDto.amountList = amount
            feeDto.gasLimit = fee?.gasLimit ?? 0
            feeDto.granter = fee?.granter ?? ""
            feeDto.payer = fee?.payer ?? ""
            ai.feeDto = feeDto
            
            var signerInfosList = [SignerInfo]()
            let signerInfos = authInfo?.signerInfos ?? []
            for signerInfo in signerInfos {
                let sign = SignerInfo()
                let any = signerInfo.publicKey
                
                let modeInfo = signerInfo.modeInfo
                let sequence = signerInfo.sequence
                
                let KeysPubKey = try? PubKey(serializedData: any.value)
                let pubKeyValue = KeysPubKey?.key.base64EncodedString() ?? ""
                
                let type = any.typeURL ?? ""
                let publicKey = PublicKey(type: type, value: pubKeyValue)
                sign.publicKey = publicKey
                
                sign.modeInfo = ModeInfo(single: Single(mode: modeInfo.single.mode.rawValue))
                sign.sequence = sequence
                signerInfosList.append(sign)
            }
            
            ai.signerInfosList = signerInfosList
            txResult.authInfo = ai
        }
        
        if txObj?.signatures != nil {
            var signaturesList = [String]()
            
            txObj?.signatures.forEach({ bytes in
                let bytesString = bytes.base64EncodedString()
                signaturesList.append(bytesString)
            })
            txResult.signaturesList = signaturesList
        }
        return txResult

    }
        
    public static func unpackMsg(typeUrl: String, value: Data) -> IrisMessage? {
        if typeUrl.isEmpty || value == nil { return nil }
        
        var txTypeString = typeUrl.replacingOccurrences(of: "/", with: "")
        let txType = TxType(rawValue: txTypeString)
                
        switch txType {
        case .msgSend:
            if let message = try? BankMsgSend(serializedData: value) {
                let msg = MsgSend(txTypeString)
                msg.fromAddress = message.fromAddress
                msg.toAddress = message.toAddress
                
                for coin in message.amount {
                    let msgCoin = Coin()
                    msgCoin.denom = coin.denom
                    msgCoin.amount = coin.amount
                    msg.amount.append(msgCoin)
                }
                return msg
            }
        case .msgMultiSend:
            if let message = try? BankMsgMultiSend(serializedData: value) {
                let msg = MsgMultiSend(txTypeString)
                let outputsList = message.outputs
                let inputsListput = message.inputs
                
                var outPuts = [Output]()
                for output in outputsList {
                    let o = Output()
                    o.address = output.address
                    let amount = self.parseCoins(coinList: output.coins)
                    o.coins = amount
                }
                msg.outputs = outPuts
                
                var inPuts = [Input]()
                for intput in inputsListput {
                    let i = Input()
                    i.address = intput.address
                    let amount = self.parseCoins(coinList: intput.coins)
                    i.coins = amount
                }
                msg.inputs = inPuts
                return msg
            }
        case .msgDelegate: break
        case .msgUndelegate: break
        case .msgBeginRedelegate: break
        case .msgWithdrawDelegatorReward: break
        case .msgSetWithdrawAddress: break
        case .msgIssueToken:
            if let message = try? TokenMsgIssueToken(serializedData: value) {
                let owner = message.owner
                let msgIssueToken = MsgIssueToken(txTypeString)
                msgIssueToken.owner = owner
                msgIssueToken.initialSupply = message.initialSupply
                msgIssueToken.maxSupply = message.maxSupply
                msgIssueToken.mintAble = message.mintable
                msgIssueToken.minUnit = message.minUnit
                msgIssueToken.name = message.name
                msgIssueToken.scale = message.scale
                msgIssueToken.symbol = message.symbol
                return msgIssueToken
            }
        case .msgEditToken:
            if let message = try? TokenMsgEditToken(serializedData: value) {
                let owner = message.owner
                let msgEditToken = MsgEditToken(txTypeString)
                msgEditToken.maxSupply = message.maxSupply
                msgEditToken.mintAble = message.mintable
                msgEditToken.name = message.name
                msgEditToken.symbol = message.symbol
                msgEditToken.owner = owner
                return msgEditToken
            }
        case .msgMintToken:
            if let message = try? TokenMsgMintToken(serializedData: value) {
                let owner = message.owner
                let to = message.to
                let msgMintToken = MsgMintToken(txTypeString)
                msgMintToken.amount = message.amount
                msgMintToken.symbol = message.symbol
                msgMintToken.owner = owner
                msgMintToken.to = to
                return msgMintToken
            }
        case .msgTransferTokenOwner:
            if let message = try? TokenMsgTransferTokenOwner(serializedData: value) {
                let dstOwner = message.dstOwner
                let srcOwner = message.srcOwner
                let msgTransferTokenOwner = MsgTransferTokenOwner(txTypeString)
                msgTransferTokenOwner.dstOwner = dstOwner
                msgTransferTokenOwner.srcOwner = srcOwner
                msgTransferTokenOwner.symbol = message.symbol
                return msgTransferTokenOwner
            }
        //coinswap
        case .msgAddLiquidity: break
        case .msgRemoveLiquidity: break
        case .msgSwapOrder: break
        //nft
        case .msgIssueDenom:
            if let message = try? NftMsgIssueDenom(serializedData: value) {
                let sender = message.sender
                let msgIssueNFT = MsgIssueNFT(txTypeString)
                msgIssueNFT.denom = message.id
                msgIssueNFT.name = message.name
                msgIssueNFT.schema = message.schema
                msgIssueNFT.sender = sender
                return msgIssueNFT
            }
        case .msgMintNFT:
            if let message = try? NftMsgMintNFT(serializedData: value) {
                let msgMintNFT = MsgMintNFT(txTypeString)
                let sender = message.sender
                let recipient = message.recipient
                
                msgMintNFT.data = message.data
                msgMintNFT.name = message.name
                msgMintNFT.denom = message.denomID
                msgMintNFT.tokenId = message.id
                msgMintNFT.uri = message.uri
                msgMintNFT.sender = sender
                msgMintNFT.recipient = recipient
                return msgMintNFT
            }
        case .msgEditNFT:
            if let message = try? NftMsgEditNFT(serializedData: value) {
                let msgEditNFT = MsgEditNFT(txTypeString)
                let sender = message.sender
                msgEditNFT.data = message.data
                msgEditNFT.name = message.name
                msgEditNFT.denom = message.denomID
                msgEditNFT.tokenId = message.id
                msgEditNFT.uri = message.uri
                msgEditNFT.sender = sender
                return msgEditNFT
            }
        case .msgTransferNFT:
            if let message = try? NftMsgTransferNFT(serializedData: value) {
                let msgTransferNFT = MsgTransferNFT(txTypeString)
                let sender = message.sender
                let recipient = message.recipient
                msgTransferNFT.data = message.data
                msgTransferNFT.name = message.name
                msgTransferNFT.denom = message.denomID
                msgTransferNFT.tokenId = message.id
                msgTransferNFT.uri = message.uri
                msgTransferNFT.sender = sender
                msgTransferNFT.recipient = recipient
                return msgTransferNFT
            }
        case .msgBurnNFT:
            if let message = try? NftMsgBurnNFT(serializedData: value) {
                let msgBurnNFT = MsgBurnNFT(txTypeString)
                let sender = message.sender
                msgBurnNFT.denom = message.denomID
                msgBurnNFT.tokenId = message.id
                msgBurnNFT.sender = sender
                return msgBurnNFT
            }
        default:
            break
        }
        
        return nil
    }
    
    
    public static func parseCoins(coinList: [BaseCoin]) -> [Coin] {
        
        var amount = [Coin]()
        for coin in coinList {
            let coinDto = Coin()
            coinDto.amount = coin.amount
            coinDto.denom = coin.denom
            amount.append(coinDto)
        }
        return amount
    }
}
