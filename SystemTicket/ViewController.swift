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
    @IBOutlet weak var clickTable: NSTextField! // количество активных заявок
    @IBOutlet weak var newTicketButton: NSButton! // кнопка Новая заявка
     //текущее время
    @IBOutlet weak var timeDataOnline: NSTextField!
    @IBOutlet weak var informationLabel: NSTextField! // информационная строка снизу таблицы
    
 //   var countColum = -1
 //   var timeTable = ["","",""]
    var baseArray = [[String]]()
    var timeCheck = 1
    var timerGlobal = 10
    var baseArrayCount = 0 // количество заявок
    var xop = 0
    
// --------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "ipserver") == nil {UserDefaults.standard.set("192.168.0.1", forKey: "ipserver")} // в случае если запуск первый и в настройках ничего нет
        if UserDefaults.standard.object(forKey: "timeupdate") == nil { UserDefaults.standard.set(10, forKey: "timeupdate") }else
        {
            timerGlobal = UserDefaults.standard.object(forKey: "timeupdate") as! Int
        }//если настроек на таймер нет то, забиваем стандартные.
        requestsystemticket() // для первого отображения
        viewTable.target = self
        viewTable.doubleAction = #selector(tableViewDoubleClick(_:))
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.check), userInfo: nil, repeats: true)
        
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
                    xCode += 1
                    self.baseArray.append(tempArray)
                    tempArray = [String]()
                    
                }
               if self.baseArray.count != self.baseArrayCount
                {
                    self.viewTable.reloadData()
                    self.baseArrayCount = self.baseArray.count
                }
               
            }
        }
    }
    
// --------------------------------------------------------------
 //построение таблицы, подсчет количество заявок и создание такого же количества строк
    public func numberOfRows(in tableView: NSTableView) -> Int
    {
        clickTable.stringValue = String(baseArray.count)
        return baseArray.count
    }

// --------------------------------------------------------------
   //заполнение таблицы заявками
var hight = -1
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        hight += 1
        let cell = hight % 3 // получаем остаток это может быть 0,1 или 2
        return baseArray[row][cell]
    }
    
// --------------------------------------------------------------
  //двойное нажатие на заявку
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        UserDefaults.standard.set(baseArray[viewTable.selectedRow][0], forKey: "idTicket") // запись номера заявки
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
    
    


