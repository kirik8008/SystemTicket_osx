//
//  Messenger.swift
//  SystemTicket
//
//  Created by Admin on 08.02.2018.
//  Copyright © 2018 Smoks. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SwiftySound
import SocketIO

class Messenger: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let manager = SocketManager(socketURL: URL(string: "http://\(UserDefaults.standard.object(forKey: "ipMessanger") as! String)")!, config: [.log(true), .compress])
    var tableUser = [[String]]() // пользователи активные
    @IBOutlet weak var usersActive: NSTableView! // таблица с сотрудниками
    @IBOutlet weak var sid: NSTextField! // SID соединения
    @IBOutlet weak var userId: NSTextField! // id пользователя
    @IBOutlet weak var userFio: NSTextField! // фио пользователя
    @IBOutlet weak var speedConnect: NSTextField!
    @IBOutlet weak var storageUser: NSTextField! // размер истории
    @IBOutlet weak var channel: NSTextField! //канал
    @IBOutlet weak var informationString: NSTextField! // информационная строка
    @IBOutlet var window: NSTextView! // поле вывода сообщений
    @IBOutlet weak var text: NSTextField! // окно для ввода
    
//--------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersActive.target = self
        usersActive.action = #selector(userSelection(_:))
        UserDefaults.standard.set("", forKey: "idSocket")
        userId.stringValue = UserDefaults.standard.object(forKey: "id") as! String
        userFio.stringValue = UserDefaults.standard.object(forKey: "fio") as! String
        
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            self.sid.stringValue = socket.sid
            UserDefaults.standard.set(socket.sid, forKey: "idSocket")
            socket.emit("pong", [UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),UserDefaults.standard.object(forKey: "idSocket")])
            
            socket.on("userlist") {data, ack in
                self.userlist(data: data)
            }
            
            socket.on("eventmessage") {data,ack in
                self.informationString.stringValue = "\(data)"
            }
            
            socket.on("message") {data, ack in
                self.message(data: data)
            }
        }
        
        socket.on(clientEvent: .reconnect) { (data, ack) in
            self.sid.stringValue = "Reconnect server..."
        }
        
        socket.on(clientEvent: .error){ (data, ack) in
            UserDefaults.standard.set("-", forKey: "idSocket")
            self.tableUser = [[String]]()
            self.usersActive.reloadData()
            self.sid.stringValue = "Disconnect - Error"
        }
        
        socket.on(clientEvent: .ping) { (data, ack) in
            socket.emit("pong", [UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),UserDefaults.standard.object(forKey: "idSocket")])
        }
        
        socket.connect()
    }
    
//--------------------------------------------------------------
    //обновление листа подключенных пользователей
    func userlist(data:Any)
    {
        self.tableUser = [[String]]()
        let json = JSON(data)
        for mas in json[0]
        {
            let time = mas.1
            var tepmtable = [String]()
            tepmtable.append("\(time[1])")
            tepmtable.append("\(time[0])")
            tepmtable.append("\(time[2])")
            self.tableUser.append(tepmtable)
        }
        self.usersActive.reloadData()
    }
    
//--------------------------------------------------------------
    //отправка и прием сообщений
    func message(data:Any)
    {
        let json = JSON(data)
        let id:String = "\(json[0][1])"
        if id == UserDefaults.standard.object(forKey: "id") as! String
        {
            Sound.play(file: "Blum", fileExtension: "mp3", numberOfLoops: 0)
            if self.channel.stringValue == "\(json[0][3])"
            {
                print(tableUser)
                self.window.string = self.window.string + "\(json[0][0]) 💬 -> \(json[0][4]) \n"
                self.saveMessage()
            } else
            {
                let textInSave = UserDefaults.standard.object(forKey: "activeUserChat\(json[0][2])") as! String
                let savingText = textInSave + "\(json[0][0]) 💬 -> \(json[0][4]) \n"
                UserDefaults.standard.set(savingText, forKey: "activeUserChat\(json[0][2])")
            }
        }
    }
    
//--------------------------------------------------------------
    //кнопка отправки сообщений
    @IBAction func sendMessage(_ sender: Any) {
        if channel.stringValue == "Общий канал" { window.string = "Нужно выбрать пользователя перед тем как что то отправлять!" }else{
            if text.stringValue != "" && UserDefaults.standard.object(forKey: "activeChat") != nil
            {
                let socket = manager.defaultSocket
                let message = [dateTimeFunc(),UserDefaults.standard.object(forKey: "activeChat"),UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),text.stringValue]
                //socket.emit("message", message)
                socket.emit("message", message)
                //window.string = dateTimeFunc() + " \(fio) -> " + text.stringValue + "\n" + window.string
                window.string = window.string + dateTimeFunc() + " Я -> " + text.stringValue + "\n"
                text.stringValue = ""
                saveMessage()
            }
        }
    }
    
//--------------------------------------------------------------
    
    @IBAction func clearHistory(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "activeChat") != nil
        {
            let id = UserDefaults.standard.object(forKey: "activeChat") as! String
            UserDefaults.standard.set("", forKey: "activeUserChat\(id)")
            window.string = ""
        }
    }

//--------------------------------------------------------------
    
    //отображение истории пользователя
    @objc public func userSelection(_ sender:AnyObject)
    {
        if usersActive.selectedRow != -1 {
            // print(tableUser[usersActive.selectedRow])
            UserDefaults.standard.set(tableUser[usersActive.selectedRow][1], forKey: "activeChat")
            channel.stringValue = tableUser[usersActive.selectedRow][0]
            let activeUserChat = "activeUserChat\(tableUser[usersActive.selectedRow][1])"
            if (UserDefaults.standard.object(forKey: activeUserChat) != nil)
            {
                let textload = UserDefaults.standard.object(forKey: "activeUserChat\(tableUser[usersActive.selectedRow][1])") as! String
                window.string = textload
                window.scrollToEndOfDocument("")
                
            }else
            {
                UserDefaults.standard.set("", forKey: "activeUserChat\(tableUser[usersActive.selectedRow][1])")
                window.string = ""
            }
            //saveMessage()
        }
    }
    
//--------------------------------------------------------------
    
    public func saveMessage() // сохранение истории сообщений
    {
        if channel.stringValue == "Общий канал" {UserDefaults.standard.removeObject(forKey: "activeChat")}
        if UserDefaults.standard.object(forKey: "activeChat") != nil
        {
            let idUser = UserDefaults.standard.object(forKey: "activeChat") as! String
            let textSave = "activeUserChat" + idUser
            UserDefaults.standard.set("\(window.string)", forKey: textSave)
            window.scrollToEndOfDocument("")
        }
    }
  
//--------------------------------------------------------------
    
    public func clearHistory(id:Int) // очистка истории сообщений
    {
        UserDefaults.standard.removeObject(forKey: "activeUserChat\(id)")
    }
    
    //--------------------------------------------------------------
    
    func userConfSocket() -> Any // сборка информации о пользователе
    {
        let result = [UserDefaults.standard.object(forKey: "id"), UserDefaults.standard.object(forKey: "fio"), UserDefaults.standard.object(forKey: "idSocket")]
        return result
    }
    
//--------------------------------------------------------------
    
    //текущая дата и время
    @objc public func dateTimeFunc()->String {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm:ss"
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
//--------------------------------------------------------------
    
    public func numberOfRows(in tableView: NSTableView) -> Int { //  построения строк в таблице с пользователями
        
        return tableUser.count
    }
    
//--------------------------------------------------------------
    
    // построение таблицы
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.tableUser[row][0]
    }
    
    //--------------------------------------------------------------
}
