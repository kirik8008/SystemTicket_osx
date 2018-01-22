//
//  viewTicket.swift
//  SystemTicket
//
//  Created by Admin on 18.01.2018.
//  Copyright © 2018 Smoks. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import MapKit

class viewTicket: NSViewController {
    @IBOutlet weak var label: NSTextField! //фио пользователя
    @IBOutlet weak var nomberTicket: NSTextField! // # заявки
    @IBOutlet weak var dateOpen: NSTextField! // дата создания
    @IBOutlet weak var themeTicket: NSTextField! // тема заявки
    @IBOutlet weak var authorTicket: NSTextField! // автор заявки
    @IBOutlet weak var meetTicket: NSTextField! // ответственный
    @IBOutlet weak var dataexTicket: NSTextField! // запланировано
    @IBOutlet weak var statusTicket: NSTextField! // статус заявки
    @IBOutlet weak var textTicket: NSTextField! // текст заявки
    @IBOutlet weak var dogovor: NSTextField! //договор пользователя
    @IBOutlet weak var teamviewer: NSTextField! // номер teamviewer
    @IBOutlet weak var addres: NSTextField! // адрес пользователя
    @IBOutlet weak var phone: NSTextField! // телефон пользователя
    @IBOutlet weak var labelCloseTicket: NSTextField! // строка для ошибок в разделе закрыть заявку
    @IBOutlet weak var addresMap: NSTextField! //адрес в разделе карты
    @IBOutlet weak var maps: MKMapView! //карта
    @IBOutlet weak var textCloseTicket: NSTextField! // текст закрытия заявки
    @IBOutlet weak var closeButton: NSButtonCell! //кнопка закрытия заявки
    
    
    var idTicket:String = ""
    var locationOne:Double = 0.0
    var locationTwo:Double = 0.0
    var locationArray: [Double] = []
    let regionRadius: CLLocationDistance = 1000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.idTicket = UserDefaults.standard.object(forKey: "idTicket") as! String
        loadViewTicket()
    }
    
    @objc public func loadViewTicket()
    {
        self.nomberTicket.stringValue = self.idTicket
        let params: [String: Any] = [
            "idTicket": self.idTicket,
            "userId": UserDefaults.standard.object(forKey: "id") as! String
        ]
        
        Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=viewticket", method: .post, parameters: params).responseJSON { response in
            if let json = response.result.value {
                let jsons = JSON(json)
                
                if let fio = jsons["fio"].string {
                    self.label.stringValue = fio
                }
                
                if let addres = jsons["addres"].string {
                    self.addres.stringValue = addres
                    self.addresMap.stringValue = addres
                }
                
                if let date = jsons["date"].string {
                    self.dateOpen.stringValue = date
                }
                
                if let dataex = jsons["dataex"].string {
                    self.dataexTicket.stringValue = dataex
                }
                
                if let pri = jsons["pri"].string {
                    self.textTicket.stringValue = pri
                }
                
                if let dogovor = jsons["dogovor"].string {
                    self.dogovor.stringValue = dogovor
                }
                
                if let author = jsons["author"].string {
                    self.authorTicket.stringValue = author
                }
                
                if let meet = jsons["meet"].string {
                    self.meetTicket.stringValue = meet
                }
                
                if let theme = jsons["theme"].string {
                    self.themeTicket.stringValue = theme
                }
                
                if let status = jsons["statusx"].string {
                    self.statusTicket.stringValue = status
                }
                
                if let phone = jsons["phone"].string {
                    self.phone.stringValue = phone
                }
                
                if let teamviewer = jsons["teamviewer"].string {
                    self.teamviewer.stringValue = teamviewer
                }
                
                if let locationOne = jsons["location"].string {
                    let arraySplit = locationOne.split(separator: "_")
                    self.locationOne = Double(arraySplit[0])!
                    self.locationTwo = Double(arraySplit[1])!
                }
                
                self.title = "Заявка #\(self.idTicket) от \(self.dateOpen.stringValue)"
                let inicil = CLLocation(latitude: self.locationOne, longitude: self.locationTwo) // записываем кординаты
                self.centerMapOnLocation(location: inicil, idTicketMaps: self.idTicket) // отправляем кординаты и id заявки
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation, idTicketMaps: String) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        maps.setRegion(coordinateRegion, animated: true)
        let artwork = Artwork(title: "Заявка № \(idTicketMaps)",
            locationName: "Текст обращения находится в разделе Заявка",
            discipline: "Sculpture",
            coordinate: CLLocationCoordinate2D(latitude: self.locationOne, longitude: self.locationTwo))
        maps.addAnnotation(artwork)
    }
    @IBAction func closeTicket(_ sender: Any) {
        if textCloseTicket.stringValue.isEmpty
        {labelCloseTicket.stringValue = "Нужно заполнить поле!"}
        else{
            labelCloseTicket.stringValue = ""
            let params: [String: Any] = [
                "closeticket": self.nomberTicket.stringValue,
                "closeresult": self.textCloseTicket.stringValue,
                "userId": UserDefaults.standard.object(forKey: "id") as! String
            ]
            Alamofire.request("http://\(UserDefaults.standard.object(forKey: "ipserver") as! String)/alamofire.php?code=closeticket", method: .post, parameters: params)
        }
        self.dismiss(viewTicket.self)
    }
    
    
    
}
