//
//  newTicket.swift
//  SystemTicket
//
//  Created by Admin on 26.12.2017.
//  Copyright © 2017 Smoks. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class newTicket: NSViewController, NSTableViewDataSource, NSComboBoxDataSource {
    
    let staticStatus = ["Новая","Закрытая"]
    var baseArray = [[String]]()
    var countColum = -1
    var timeTable = ["","",""]
    var countTable = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    } 
    @IBAction func dismiss(_ sender: Any) { // кнопка отмены
        self.dismissViewController(self)
    }
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var viewTable: NSTableView!
    @IBOutlet weak var fio: NSTextField! // ФИО пользователя
    @IBOutlet weak var contract: NSTextField! // номер договора
    @IBOutlet weak var adress: NSTextField! // адрес пользователя
    @IBOutlet weak var telephone: NSTextField! // телефоны пользователя
    @IBOutlet weak var authorTicket: NSComboBox! // автор заявки
    @IBOutlet weak var themeTicket: NSComboBox! // тема заявки
    @IBOutlet weak var textTicket: NSTextField! // текст заявки
    @IBOutlet weak var statusTicket: NSComboBox! // статус заявки
    @IBOutlet weak var authorFio: NSTextField! // фио сотрудника
    @IBOutlet weak var telegram: NSButton!
    @IBOutlet weak var teamviewer: NSTextField!
    @IBOutlet weak var resultText: NSTextField!
    
    
    @IBAction func sendTicket(_ sender: Any) { // отправка заявки
        var error = 0
        if textTicket.stringValue.isEmpty { error += 1 }
        if statusTicket.stringValue.isEmpty { error += 1 }
        if themeTicket.stringValue.isEmpty { error += 1 }
        if error == 0 {
        self.resultText.stringValue = "Подождите..."
        sendButton.isEnabled = false
        let params: [String: Any] = [
            "fio": fio.stringValue,
            "dogovor": contract.stringValue,
            "adress": adress.stringValue,
            "telephone": telephone.stringValue,
            "author": UserDefaults.standard.object(forKey: "fio") as! String,
            "authorlogin": UserDefaults.standard.object(forKey: "login") as! String,
            "theme": themeTicket.stringValue,
            "status": statusTicket.stringValue,
            "text": textTicket.stringValue,
            "telegram": telegram.state,
            "teamviewer": teamviewer.stringValue,
            "userId": UserDefaults.standard.object(forKey: "id") as! String
        ]
            Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=newticket", method: .post, parameters: params).responseJSON { response in
                if let ticketid = response.result.value {
                    self.resultText.stringValue = "Заявка создана под № \(ticketid) "
                    self.cancelButton.title = "Закрыть"
                }
            }
        //self.dismissViewController(self)
        } else {self.resultText.stringValue = "Не все поля заполнены!"}
    }
    
    @IBAction func search(_ sender: Any) { // кнопка поиск
        searchUser()
        //if contract.stringValue.isEmpty { } else {sendButton.isEnabled = true}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.authorFio.stringValue = UserDefaults.standard.object(forKey: "fio") as! String
        statusTicket.addItems(withObjectValues: staticStatus) // сборка статусов заявки
        printTheme()
    }
    
      @objc public func printTheme()
    {
        Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=themeticket").responseJSON { response in
            if let json = response.result.value {
                let jsons = JSON(json)
                var xCode = 0
                while xCode <= jsons.count - 1
                {
                    if let theme = jsons[xCode].string {
                        self.themeTicket.addItem(withObjectValue: theme) // заносим в combobox
                    }
                    xCode += 1
                }
            }
        }
    }
   
    @objc public func searchUser() // отправка POST для поиска пользователя
    {
        let params: [String: Any] = [
            "fiosearch": fio.stringValue,
            "dogovor": contract.stringValue,
            "userId": UserDefaults.standard.object(forKey: "id") as! String
        ]
        Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=search", method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                let jsons = JSON(json)
                    if let userFio = jsons[0][0].string {
                        self.fio.stringValue = userFio
                    }
                    if let dogovorString = jsons[0][1].string {
                        self.contract.stringValue = dogovorString
                        if dogovorString.isEmpty
                        {
                            print("Clean Contract.")
                        } else
                        {
                            self.searchTicketuser()
                            print("Ok")
                        }
                    }
                    if let adressString = jsons[0][2].string {
                       self.adress.stringValue = adressString
                    }
                    if let telephoneString = jsons[0][3].string {
                        self.telephone.stringValue = telephoneString
                    }
                    if let teamviewerString = jsons[0][4].string {
                        self.teamviewer.stringValue = teamviewerString
                    }
            }
        }
    }
    
    @objc public func searchTicketuser()
    {
        let params: [String: Any] = [
            "fiosearch": fio.stringValue,
            "userId": UserDefaults.standard.object(forKey: "id") as! String
        ]

        Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=searchticket", method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                let jsons = JSON(json)
                var xCode = 0
                self.countTable = jsons.count
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
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.countTable
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
    
    
    
}
