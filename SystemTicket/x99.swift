//
//  x99.swift
//  SystemTicket
//
//  Created by Admin on 04.04.2018.
//  Copyright © 2018 Smoks. All rights reserved.
//

import Cocoa
import Foundation


extension Int {
    var toDecimal: String {
        return String(self, radix: 10)
    }
    var toHexa: String {
        return String(self, radix: 16)
    }
}

extension String {
    var checkHexa: Int {
        return Int(strtoul(self, nil, 16))
    }
    var hexaToDecimal: String {
        return checkHexa.toDecimal
    }
    var ceckDecimal: Int {
        return Int(strtoul(self, nil, 10))
    }
    var decimalToHexa: String {
        return ceckDecimal.toHexa
    }
}

// ----------------------------------------
class x99: NSObject {
var alfavitTwo  = ["Cube","99","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","0_0","А","Б","В","Г","Д","Е","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","?","(","@",";","$","#","]","&","*",":",",","!",")","_","+","|","%","/","[","."," ","Ё","-","1","2","3","4","5","6","7","8","9","0"]
func coding(text:String) -> String
{
    var result:String
    let oneRandom = Int(arc4random_uniform(UInt32(4)) + UInt32(1));
    let twoRandom = Int(arc4random_uniform(UInt32(10)) + UInt32(0));
    result = "\(oneRandom)\(twoRandom)"
    var arrayText: [String] = []
    for xin in text
    {
        let upCash:String = String(xin)
        if alfavitTwo.index(of: upCash.uppercased()) != nil
        {
            arrayText.append(upCash.uppercased())
            let timePP = alfavitTwo.index(of: upCash.uppercased())! - oneRandom
            result += "\(timePP)".decimalToHexa
        }
        
        
    }
    
    return result
}

func decoding(text: String) -> String
{
    var result = ""
    var allCount = 0
    var textCount = 0
    var textDecode = ""
    var code = 0
    var checkText = 0
    for kin in text
    {
        allCount += 1
        if allCount != 2
        {
            if allCount == 1 {code = Int(String(kin))! }else
            {
                if (textCount == 1) && (allCount>2)
                {
                    textDecode += String(kin)
                    checkText = Int(textDecode.hexaToDecimal)!
                    let xoms = checkText + code
                    result += alfavitTwo[xoms]
                    textCount = 0
                }else { textCount += 1; textDecode = String(kin) }
            }
        }
    }
    return result
}

}
