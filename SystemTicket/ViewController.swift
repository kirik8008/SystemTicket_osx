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
import SwiftySound
import Foundation

class ViewController: NSViewController, NSTableViewDataSource, NSTabViewDelegate {
    //@IBOutlet weak var viewTable: NSTableView!
    @IBOutlet weak var viewTable: NSTableView!
   // @IBOutlet weak var clickTable: NSTextField! // количество активных заявок
    @IBOutlet weak var clickTable: NSTextField!
    //@IBOutlet weak var newTicketButton: NSButton! // кнопка Новая заявка
    @IBOutlet weak var newTicketButton: NSButton!
    //текущее время
   // @IBOutlet weak var timeDataOnline: NSTextField!
    @IBOutlet weak var timeDataOnline: NSTextField!
    //@IBOutlet weak var informationLabel: NSTextField! // информационная строка снизу таблицы
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var boxFio: NSTextField! // блок пользователь
    @IBOutlet weak var boxDogovor: NSTextField! // блок договор
    @IBOutlet weak var boxAddress: NSTextField! //блок адрес
    @IBOutlet weak var boxPhone: NSTextField! //блок телефон
    @IBOutlet weak var boxTicket: NSTextField! //блок текст заявки
    @IBOutlet weak var SearchText: NSSearchField! // текстовое поле поиска
    
    
    
    var baseArray = [[String]]()
    var searchArray = [[String]]()
    var timeCheck = 1
    var timerGlobal = 10
    var baseArrayCount = 0 // количество заявок
    
// --------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "ipserver") == nil
            {
            UserDefaults.standard.set("192.168.0.1", forKey: "ipserver")
        } // в случае если запуск первый и в настройках ничего нет
        if UserDefaults.standard.object(forKey: "timeupdate") == nil { UserDefaults.standard.set(10, forKey: "timeupdate") }else
        {
            timerGlobal = UserDefaults.standard.object(forKey: "timeupdate") as! Int
        }//если настроек на таймер нет то, забиваем стандартные.
        requestsystemticket() // для первого отображения
        viewTable.target = self
        viewTable.doubleAction = #selector(tableViewDoubleClick(_:))
        viewTable.action = #selector(viewInformationTicket(_:))
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.check), userInfo: nil, repeats: true)
        SearchText.target = self
        SearchText.action = #selector(searchUser(_ :))
    }
    
 // --------------------------------------------------------------
    // поиск по пользователям в открытых заявках
    @objc public func searchUser(_ sender:AnyObject)
    {
        searchArray = [[String]]()
        if SearchText.stringValue.isEmpty
        {
            searchArray = baseArray
        }else{
        for base in baseArray
        {
            let strings = base[1]
            //print(base[1]) string.containsString
            let ress = strings.contains(SearchText.stringValue)
            if ress { searchArray.append(base) }
        }
        print(searchArray.count)
        }
        viewTable.reloadData()
    }
    
// --------------------------------------------------------------
    @objc func check()
    {
       dateTimeFunc() // обновление времени
        if UserDefaults.standard.object(forKey: "authentication") == nil // проверка аутентификации
        {
            self.informationLabel.stringValue = ""
            if UserDefaults.standard.object(forKey: "informationAuthentication") == nil // проверка было ли сообщение
            {
            _ = dialogOKCancel(question: "Не пройдена ау­тен­ти­фи­ка­ция!", text: "Вы не прошли процедуру ау­тен­ти­фи­ка­ции, в связи с чем вам будут недоступны некоторые функции. Выполните вход в акаунт СистемыЗаявок сейчас, открыв Настройки и раздел Аутентификация")
            UserDefaults.standard.set(true, forKey: "informationAuthentication") // при одном показе сообщения записываем что мы его отобразили
            }
            viewTable.isEnabled = false // отключаем таблицу
            newTicketButton.isEnabled = false // отключаем кнопку новая заявка
        }else{
            if self.informationLabel.stringValue == "" { self.informationLabel.stringValue = UserDefaults.standard.object(forKey: "fio") as! String }
            if newTicketButton.isEnabled == false {newTicketButton.isEnabled = true} // включаем кнопку новая заявка
            if viewTable.isEnabled == false {viewTable.isEnabled = true} // включаем таблицу
            let time:Int = UserDefaults.standard.object(forKey: "timeupdate") as! Int // получаем из конфига время обновления
            // проверяем не изменилось ли время, если изменилось то записываем новое время и сбрасываем счетчик
            if time != timerGlobal {timeCheck = 1; timerGlobal = UserDefaults.standard.object(forKey: "timeupdate") as! Int }
            if  time == timeCheck //сам счетчик, кривой но работает)
            {
                timeCheck = 1
                requestsystemticket()
            }else {
                timeCheck += 1
                if timeCheck >= 60 {timeCheck = 1} // защита на не более минуты.
            }
        }
    }
    
    
// --------------------------------------------------------------
// получение списка заявок
    @objc public func requestsystemticket()
    {
        self.baseArray = [[String]]()
        Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=allticket").responseJSON { response in
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
                    if let userAddress = jsons[xCode][3].string {
                        tempArray.append(userAddress)
                    }
                    if let userDogovor = jsons[xCode][4].string {
                        tempArray.append(userDogovor)
                    }
                    if let userPhone = jsons[xCode][5].string {
                        tempArray.append(userPhone)
                    }
                    xCode += 1
                    self.baseArray.append(tempArray)
                    tempArray = [String]()
                    
                }
               if self.baseArray.count != self.baseArrayCount
                {
                    self.searchArray = self.baseArray // заносим для отображения
                    self.viewTable.reloadData()
                    Sound.play(file: "NewTicket", fileExtension: "mp3", numberOfLoops: 0)
                    self.baseArrayCount = self.baseArray.count
                }
               
            }
        }
    }
// --------------------------------------------------------------
    //отображение информации о заявке на малом окне
    @objc public func viewInformationTicket(_ sender:AnyObject)
    {
        let select = viewTable.selectedRow
        self.boxFio.stringValue = searchArray[select][1]
        self.boxAddress.stringValue = searchArray[select][3]
        self.boxDogovor.stringValue = searchArray[select][4]
        self.boxPhone.stringValue = searchArray[select][5]
        self.boxTicket.stringValue = searchArray[select][2]
    }
    
// --------------------------------------------------------------
 //построение таблицы, подсчет количество заявок и создание такого же количества строк
    public func numberOfRows(in tableView: NSTableView) -> Int
    {
        clickTable.stringValue = String(baseArray.count)
        return searchArray.count
    }

// --------------------------------------------------------------
   //заполнение таблицы заявками
var hight = -1
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        hight += 1
        let cell = hight % 3 // получаем остаток это может быть 0,1 или 2
        return searchArray[row][cell]
    }
    
// --------------------------------------------------------------
  //двойное нажатие на заявку
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        UserDefaults.standard.set(searchArray[viewTable.selectedRow][0], forKey: "idTicket") // запись номера заявки
        performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showViewTicket"), sender: self) // открытие окна просмотре заявки
        }
    
// --------------------------------------------------------------
    //функция всплывающих сообщений
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

// --------------------------------------------------------------
    //дата и время
    @objc public func dateTimeFunc() {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date as Date)
        self.timeDataOnline.stringValue = dateString
    }

// --------------------------------------------------------------
    
    }
    

    
    
var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    


