//
//  ApplicationInfo.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import MapKit

enum ApplicationType: String{
    case OfficeBuilding = "office-building.png"
    case Construction = "constructioncrane.png"
    case Demolition = "demolition.png"
}


/**
 Model class to hold the information relating to one application location, including application #, 
 address, geoLocation and so on.
*/
class ApplicationInfo : NSObject, MKAnnotation{
    let title: String?
    let type: ApplicationType
    let image: UIImage
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, type: ApplicationType, coordinate: CLLocationCoordinate2D, image: UIImage){
        self.title = title
        self.type = type
        self.coordinate = coordinate
        self.image = image
        
        super.init()
    }
}