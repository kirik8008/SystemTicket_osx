//
//  ViewController.swift
//  SystemTicket
//
//  Created by Admin on 13.11.2017.
//  Copyright © 2017 Smoks. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class ViewController: NSViewController, NSTableViewDataSource, NSTabViewDelegate {
    @IBOutlet weak var viewTable: NSTableView!
    @IBOutlet weak var clickTable: NSTextField!
    
    var countColum = -1
    var timeTable = ["","",""]
    var baseArray = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestsystemticket()
    }
    
    public func requestsystemticket() -> Bool
    {
        Alamofire.request("http://10.0.0.65/ticket2/alamofire.php").responseJSON { response in
            if let json = response.result.value {
                let jsons = JSON(json)
                var xCode = 0
                var tempArray = [String]()
                while xCode <= jsons.count - 1
                {
                    if let userNid = jsons[xCode][0].string {
                        tempArray.append(userNid)
                    }
                    if let userFio = jsons[xCode][1].string {
                        tempArray.append(userFio)
                    }
                    if let userPri = jsons[xCode][2].string {
                        tempArray.append(userPri)
                    }
                    xCode += 1
                    self.baseArray.append(tempArray)
                    tempArray = [String]()
                    
                }
                self.viewTable.reloadData()
                
            }
        }
            return true
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int
    {
        clickTable.stringValue = String(baseArray.count)
        return baseArray.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        
        let xmk = baseArray[row].count - 1
        if self.countColum == xmk { self.countColum = -1 } else { self.countColum += 1 }
        if self.countColum == -1
        {
            self.timeTable = baseArray[row]
            self.countColum = 0
        }
        if(self.timeTable == ["","",""]) { self.timeTable = baseArray[row] }
        return timeTable[countColum]
    }
    
    
    
    
    
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

