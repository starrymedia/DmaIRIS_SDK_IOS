//
//  IrisMessage.swift
//  UptickProtocolIRISnet
//
//  Created by StarryMedia on 2020/12/16.
//

import Foundation
import HandyJSON

public class IrisMessage: HandyJSON {
    public required init() {
        
    }
    
    public required  init(_ type: String) {
        self.type = type
    }

    public var type: String = ""    
}


