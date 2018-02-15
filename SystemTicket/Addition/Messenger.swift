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
import Sodium
import SystemConfiguration

extension String {
    func toData() -> Data? {
        return self.data(using: .utf8, allowLossyConversion: false)
    }
}

extension Dictionary {
    func toData() -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: self) as Data?
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
    
    func toDictionary() -> [String: AnyObject]? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? [String: AnyObject]
    }
}
    let sodium = Sodium()

class Messenger: NSViewController, NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate {
    var manager = SocketManager(socketURL: URL(string: "http://192.168.1.200:8008")!, config: [.log(true), .compress])
    var tableUser = [[String]]() // пользователи активные
    let KeyPair = sodium.box.keyPair()! //мой ключ
    var publicKey:Any = ""
    var viewcont = ""
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
        if UserDefaults.standard.object(forKey: "authentication") != nil
        {
        if UserDefaults.standard.object(forKey: "ipMessanger") == nil
        {
            UserDefaults.standard.set("192.168.1.200:8008", forKey: "ipMessanger")
            window.string = "Мессенджер ожидает правильных настроек! Зайди в настройки и укажи правильный сервер и перезагрузи приложение!"
        }
        manager = SocketManager(socketURL: URL(string: "http://\(UserDefaults.standard.object(forKey: "ipMessanger") as! String)")!, config: [.log(true), .compress])
        var idMessage = ""
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
                if data.count == 7 {
                /* Получение сообщения:
                     |0: Дата и время |1:получатель |2:отправитель |3:имя отправителя |4: зашифрованное сообщение |5: публичный ключ|6: id
                */
                    if idMessage != "\(data[6])"
                    {
                            let encryptionText:Data = data[4] as! Data
                            let sendpublickey:Data = data[5] as! Data
                            let text = self.decryptionMessage(encryptedMessage: encryptionText, publicSendKey: sendpublickey) // получаем текст
                            let objData = [data[0] as! String, data[1], data[2],data[3] as! String, text] // собираем массив
                            self.message(data:objData) // передаем в обработчик
                            idMessage = "\(data[6])"
                    }
                }
            }
            
            //получение публичного ключа
            socket.on("sendpublickey") {data, ack in
                self.publicKey = data[1] as! Data
            }
            
            socket.on("publickey"){data, ack in
                socket.emit("sendpublickey", [data[0],self.KeyPair.publicKey])
            }
            
            socket.on("prints") {data, ack in
                self.userPrints(data: data)
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
            if UserDefaults.standard.object(forKey: "authentication") == nil
            {
                socket.disconnect()
                UserDefaults.standard.removeObject(forKey: "activeChat")
                self.window.string = ""
                self.tableUser = [[String]]()
                self.usersActive.reloadData()
            }else{
            socket.emit("pong", [UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),UserDefaults.standard.object(forKey: "idSocket")])
            }
        }
            
            socket.on(clientEvent: .disconnect) {(data,ack) in
                self.sid.stringValue = "Пока пока !"
            }
        socket.connect()
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.cleanInformation), userInfo: nil, repeats: true)
        } else { window.string = "Вы не прошли процедуру ау­тен­ти­фи­ка­ции, в связи с чем вам будут недоступны некоторые функции. Выполните вход в акаунт СистемыЗаявок сейчас, открыв Настройки и раздел Аутентификация. При успешной Аутентификации перезагрузите приложение!" }
        
    }
    
//--------------------------------------------------------------
    //действие при вводе текста
    @objc override func controlTextDidChange(_ obj: Notification) {
        let socket = manager.defaultSocket
        if channel.stringValue != "Общий канал"
        {
            if UserDefaults.standard.object(forKey: "activeChat") != nil
            {
                socket.emit("prints",  [UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),UserDefaults.standard.object(forKey: "activeChat")])
            }
        }
    }
 //--------------------------------------------------------------
    //шифрование
    public func encryptionMessage(text:String)
    {
        let socket = manager.defaultSocket
        let message = text.data(using:.utf8)!
        let encryptedMessage: Data =
            sodium.box.seal(message: message,
                            recipientPublicKey: self.publicKey as! Box.PublicKey,
                            senderSecretKey: KeyPair.secretKey)!
       let messagess = [dateTimeFunc(),UserDefaults.standard.object(forKey: "activeChat"),UserDefaults.standard.object(forKey: "id"),UserDefaults.standard.object(forKey: "fio"),encryptedMessage,KeyPair.publicKey]
        socket.emit("message", messagess)
    }
    
//--------------------------------------------------------------
    //шифрование
    public func decryptionMessage(encryptedMessage: Data, publicSendKey:Data) -> String
    {
        let messageVerified =
            sodium.box.open(nonceAndAuthenticatedCipherText: encryptedMessage,
                            senderPublicKey: publicSendKey,
                            recipientSecretKey: KeyPair.secretKey)
        let result = messageVerified!.toString()
        return result!
    }
    
//--------------------------------------------------------------
    
    @objc func cleanInformation()
    {
        self.informationString.stringValue = "Информационная строка"
    }
    
//--------------------------------------------------------------
    //получение от сервра что пользователь печатает
    func userPrints(data:Array<Any>)
    {
        let id:String = data[2] as! String
        if id == UserDefaults.standard.object(forKey: "id") as! String
        {
            self.informationString.stringValue = "\(data[1]) печатает..."
        }
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
    func message(data:Array<Any>)
    {
        let id:String = data[1] as! String
        if id == UserDefaults.standard.object(forKey: "id") as! String
        {
            self.cleanInformation()
            Sound.play(file: "Blum", fileExtension: "mp3", numberOfLoops: 0)
            if self.channel.stringValue == "\(data[3])"
            {
                self.window.string = self.window.string + "\(data[0]) \(data[3]) 💬 -> \(data[4]) \n"
                self.saveMessage()
            } else
            {
                if UserDefaults.standard.object(forKey: "activeUserChat\(data[2])") == nil
                {
                    UserDefaults.standard.set("", forKey: "activeUserChat\(data[2])")
                }
                let textInSave = UserDefaults.standard.object(forKey: "activeUserChat\(data[2])") as! String
                let savingText = textInSave + "\(data[0]) \(data[3]) 💬 -> \(data[4]) \n"
                UserDefaults.standard.set(savingText, forKey: "activeUserChat\(data[2])")
                
            }
        }
    }
    
//--------------------------------------------------------------
    //кнопка отправки сообщений
    @IBAction func sendMessage(_ sender: Any) {
        if channel.stringValue == "Общий канал" { window.string = "Нужно выбрать пользователя перед тем как что то отправлять!" }else{
            if text.stringValue != "" && UserDefaults.standard.object(forKey: "activeChat") != nil
            {
                self.encryptionMessage(text: text.stringValue)
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
            let socket = manager.defaultSocket
            socket.emit("publickey", [tableUser[usersActive.selectedRow][1],UserDefaults.standard.object(forKey: "id")])
            text.stringValue = ""
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
                text.stringValue = ""
                UserDefaults.standard.set("", forKey: "activeUserChat\(tableUser[usersActive.selectedRow][1])")
                window.string = ""
            }
        }else {
            channel.stringValue = "Общий канал"
            UserDefaults.standard.removeObject(forKey: "activeChat")
            window.string = ""
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
