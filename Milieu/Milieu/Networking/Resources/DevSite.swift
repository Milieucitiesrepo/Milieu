//
//  DevSite.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import Mapbox

typealias JSONDictionary = [String: AnyObject]

let url = NSURL(string: "https://milieu.io/dev_sites")!

struct DevSite{
    // Basic Info
    let id: Int
    let latitude: Double
    let longitude: Double
    
    // Display Info - Mandantory
    let devId: String
    let applicationType: String
    let status: String
    
    // Dispaly Info - Optional
    let statusDate: String?
    let address: String?
    let description: String?
    let imageUrl: String?
    let images: [JSONDictionary]?
    let comments: [JSONDictionary]?
}

// MARK: - Static fields
extension DevSite{
    static let all = Resource<[DevSite]>(url: url, parseJSON: { json in
        guard let count = json["total"] as? Int else {return nil}
        guard let dictionaries = json["dev_sites"] as? [JSONDictionary] else {return nil}
        return dictionaries.flatMap(DevSite.init)
    })
    
    static func nearby(coordinate: CLLocationCoordinate2D) -> Resource<[DevSite]>{
        let url = NSURL(string: "https://milieu.io/dev_sites?limit=20&latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)")!
        return Resource(url: url, parseJSON: {
            json in
            guard (json["total"] as? Int) != nil else {return nil}
            guard let dictionaries = json["dev_sites"] as? [JSONDictionary] else {return nil}
            return dictionaries.flatMap(DevSite.init)
        })
    }
}

// MARK: - Constructors
extension DevSite{
    init?(dictionary: JSONDictionary){
        guard let id = dictionary["id"] as? Int,
            devId = dictionary["devID"] as? String,
            latitude = dictionary["latitude"] as? Double,
            longitude = dictionary["longitude"] as? Double,
            applicationType = dictionary["application_type"] as? String,
            status = dictionary["status"] as? String
            else {return nil}
        self.id = id
        self.devId = devId
        self.latitude = latitude
        self.longitude = longitude
        self.applicationType = applicationType
        self.status = status
        
        statusDate = dictionary["status_date"] as? String
        self.address = dictionary["address"] as? String
        self.description = dictionary["description"] as? String
        self.imageUrl = dictionary["image_url"] as? String
        self.images = dictionary["images"] as? [JSONDictionary]
        self.comments = dictionary["comments"] as? [JSONDictionary]
    }
}

// MARK: - Methods
extension DevSite{
    func more() -> Resource<DevSite>{
        let url = NSURL(string: "https://milieu.io/dev_sites/\(id)")!
        return Resource(url: url, parseJSON:{
            json in
            guard let dictionary = json as? JSONDictionary else {return nil}
            return DevSite(dictionary: dictionary)
        })
    }
}