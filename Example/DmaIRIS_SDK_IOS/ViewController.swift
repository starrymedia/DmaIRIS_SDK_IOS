//
//  ViewController.swift
//  DmaIRIS_SDK_IOS
//
//  Created by 447690182@qq.com on 11/14/2020.
//  Copyright (c) 2020 447690182@qq.com. All rights reserved.
//

import UIKit
import UptickProtocolIRISnet
import GRPC
import Logging
import web3swift
import secp256k1_swift
import Alamofire

public struct PublicKey {
    var type:String = ""
    var value: String = ""

}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let url = "34.80.22.255"
        let chainId = "bifrost-2"
        let merchantUrl = "http://merchantiris.starrymedia.com"

        IRISServive.host = url
        IRISServive.port = 9090
        IRISServive.chainId = chainId
        IRISServive.defaultCoin = "ubif"
        MerchantService.nodeUrl = merchantUrl
        RpcService.rpcUrl = "http://\(url):26657"
        
  
        let wallet = WalletManager.create()
        print(wallet.mnemonics)
        
//        let tokenId = "uptick\(TxUtils.identifier)"
//
//        let cardInfo = SouvenirCardInfo()
//        cardInfo.tokenId = tokenId
//        cardInfo.denomId = "dhjvc"
//        cardInfo.name = "Fuchs"
//        cardInfo.description = "测试奇怪的bug"
//        cardInfo.backgroundColor = "#ffe2a9"
//        cardInfo.minter = "Uptick"
//        cardInfo.imgUrl = "测试奇怪的bug"
//        cardInfo.minterLogoUrl = "测试奇怪的bug"
//        cardInfo.issuerName = "nickName"
//        cardInfo.issuerAddr = "address"
//        cardInfo.issuerLogoUrl = "userImage"
//        cardInfo.issuesTime = Int64(Date().timeIntervalSince1970) * 1000
//
//        SouvenirCardService.mintTokenGas(ticketEntities: [cardInfo],
//                                         sender: "iaa1ml6lgn7phwmtq60zdcrta84d7phn500uc0kc60",
//                                         recipient: "iaa1ml6lgn7phwmtq60zdcrta84d7phn500uc0kc60",
//                                         privateKey: "81918ab0e59a68dd84a18c2e8e9aa5f8f514e81431f4513673ea64bc56bc0181",
//                                         isSign: false,
//                                         feeAddress: "iaa1ml6lgn7phwmtq60zdcrta84d7phn500uc0kc60",
//                                         fee: "1",
//                                         method: .broadcastTxAsync) { tx in
//
//            SouvenirCardService.mintToken(tx: tx,
//                                         method: .broadcastTxAsync) { value in
//             print(value)
//
//            } errorCallback: { error in
//
//            }
//
//         } errorCallback: { error in
//
//         }
        

     }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

struct Login: Encodable {
    let email: String
    let password: String
}


