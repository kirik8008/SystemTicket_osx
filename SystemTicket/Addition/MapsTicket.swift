//
//  MapsTicket.swift
//  SystemTicket
//
//  Created by Admin on 03.04.2018.
//  Copyright © 2018 Smoks. All rights reserved.

import Cocoa
import MapKit

class MapsTicket: NSViewController {
    var baseArray = [[String]]()
    var idTicket:String = ""
    var locationOne:Double = 0.0
    var locationTwo:Double = 0.0
    var locationArray: [Double] = []
    let regionRadius: CLLocationDistance = 300000
    @IBOutlet weak var maps: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapOnLocation()
        if (baseArray.count != 0)
        {
            for i in baseArray
            {
                let arrayFunc = [i[0],i[2],"Sculpture",Double(i[6])!,Double(i[7])!] as [Any]
                self.addTicketMap(ticket: arrayFunc)
            }
        }
        // Do view setup here.
    }
    
    
// ------------------------------------------------------------
    //центр карты
    func centerMapOnLocation() {
        let location = CLLocation(latitude: 51.051653, longitude: 39.974883) // отображение
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius, regionRadius)
        maps.setRegion(coordinateRegion, animated: true)
    }
    
// ------------------------------------------------------------
    // создание точки заявки
    //["Номер заявки", "Текст заявки",discipline "Sculpture",Double кординаты,Double кординаты]
    func addTicketMap(ticket: [Any])
    {
        let artwork = Artwork(title: "Заявка № \(ticket[0])",
                              locationName: ticket[1] as! String,
                              discipline: ticket[2] as! String,
                              coordinate: CLLocationCoordinate2D(latitude: ticket[3] as! CLLocationDegrees, longitude: ticket[4] as! CLLocationDegrees))
        maps.addAnnotation(artwork)
    }
    
}
