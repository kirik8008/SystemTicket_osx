//
//  Settings.swift
//  SystemTicket
//
//  Created by Admin on 19.01.2018.
//  Copyright © 2018 Smoks. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class Settings: NSViewController {
    
    @IBOutlet weak var ipServer: NSTextField! // сервер СистемыЗаявок
    @IBOutlet weak var surname: NSTextFieldCell! // фамилия сотрудника
    @IBOutlet weak var name: NSTextFieldCell! // имя сотрудника
    @IBOutlet weak var pass: NSSecureTextFieldCell! //пароль
    @IBOutlet weak var infoError: NSTextField! // строка для ошибок
    @IBOutlet weak var authentication: NSButton! // кнопка вход
    @IBOutlet weak var saveSettings: NSButton! // кнопка сохранить
    @IBOutlet weak var updateTicket: NSComboBoxCell! // combobox с временем обновления таблицы

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ipServer.stringValue = UserDefaults.standard.object(forKey: "ipserver") as! String
        let timeUpdate:Int = UserDefaults.standard.object(forKey: "timeupdate") as! Int
        self.updateTicket.title = "\(timeUpdate) с."
        if UserDefaults.standard.object(forKey: "authentication") == nil
        {
            authentication.title = "Авторизоваться"
        }else{
            authentication.title = "Выйти"
            self.name.stringValue = UserDefaults.standard.object(forKey: "name") as! String
            self.surname.stringValue = UserDefaults.standard.object(forKey: "surname") as! String
        }
        // Do view setup here.
    }
    
// ---------------------------------------------------
    //кнопка сохранить
    @IBAction func save(_ sender: Any) {
        UserDefaults.standard.set(self.ipServer.stringValue, forKey: "ipserver")
       switch self.updateTicket.stringValue {
        case "5 с.": UserDefaults.standard.set(5, forKey: "timeupdate")
        case "10 с.": UserDefaults.standard.set(10, forKey: "timeupdate")
        case "30 с.": UserDefaults.standard.set(30, forKey: "timeupdate")
        case "60 с.": UserDefaults.standard.set(60, forKey: "timeupdate")
        case "1 с.": UserDefaults.standard.set(1, forKey: "timeupdate")
        default:
            UserDefaults.standard.set(10, forKey: "timeupdate")
        }
        self.infoError.stringValue = "Настройки сохранены! Таблица с заявками скоро обновиться."
    }
// ---------------------------------------------------
    
    // аутентификация
    @IBAction func connectTicket(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "authentication") == nil
        {
            let params: [String: Any] = [
                "name": name.stringValue,
                "surname": surname.stringValue,
                "pass": pass.stringValue,
                "userId": 0
            ]
            Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=authentication", method: .post, parameters: params).responseJSON { response in
                if let json = response.result.value {
                    let jsons = JSON(json)
                    if let error = jsons["error"].string {
                        self.infoError.stringValue = error
                    }
                    if let info = jsons["info"].bool {
                        if info {
                            UserDefaults.standard.set(true, forKey: "authentication")
                            self.authentication.title = "Выйти"
                            if let fio = jsons["fio"].string {
                                UserDefaults.standard.set(fio, forKey: "fio")
                            }
                            
                            if let name = jsons["name"].string {
                                UserDefaults.standard.set(name, forKey: "name")
                            }
                            
                            if let surname = jsons["surname"].string {
                                UserDefaults.standard.set(surname, forKey: "surname")
                            }
                            
                            if let id = jsons["id"].string {
                                UserDefaults.standard.set(id, forKey: "id")
                            }
                            
                            if let login = jsons["login"].string {
                                UserDefaults.standard.set(login, forKey: "login")
                            }
                            
                            if let key = jsons["key"].string {
                                UserDefaults.standard.set(key, forKey: "key")
                            }
                            
                            if let idconnect = jsons["idconnect"].string {
                                UserDefaults.standard.set(idconnect, forKey: "idconnect")
                            }
                        }
                    }
                }
            }
        } else
        {
            authentication.title = "Авторизоваться"
            UserDefaults.standard.set(nil, forKey: "idconnect")
            UserDefaults.standard.set(nil, forKey: "key")
            UserDefaults.standard.set(nil, forKey: "login")
            UserDefaults.standard.set(nil, forKey: "id")
            UserDefaults.standard.set(nil, forKey: "surname")
            UserDefaults.standard.set(nil, forKey: "name")
            UserDefaults.standard.set(nil, forKey: "fio")
            UserDefaults.standard.set(nil, forKey: "authentication")
            UserDefaults.standard.set(nil, forKey: "informationAuthentication")
            self.name.stringValue = ""
            self.surname.stringValue = ""
        }
    }
// ---------------------------------------------------
    
}
