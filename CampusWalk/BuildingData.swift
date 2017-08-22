//
//  BuildingData.swift
//  CampusWalk
//
//  Created by Julian Panucci on 11/1/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import MapKit

class Building: MKPointAnnotation, NSCoding
{
    
    var name:String
    var buildingCode:Int
    var year: Int
    var imageName:String
    var latitude:Double
    var longitude:Double
    var shouldBePinnedToMap:Bool
    var isFavorite:Bool
    //Added imageData so if user selects new image for building it will be saved as data object and then the image can be persist while the app runs
    var imageData:Data?
    
    init(name:String, buildingCode:Int, year:Int, imageName:String, latitude:Double, longitude:Double, isFavorite:Bool?, shouldBePinnedToMap: Bool?, imageData:Data?)
    {
        self.name = name
        self.buildingCode = buildingCode
        self.year = year
        self.imageName = imageName
        self.latitude = latitude
        self.longitude = longitude
        
        if isFavorite == nil {
            self.isFavorite = false
        }else {self.isFavorite = isFavorite!}
        
        if shouldBePinnedToMap == nil {
            self.shouldBePinnedToMap = false
        }else {self.shouldBePinnedToMap = shouldBePinnedToMap!}
        
        self.imageData = imageData
        
        
        
        super.init()
        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.subtitle = ""
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: BuildingKey.name)
        aCoder.encode(year, forKey: BuildingKey.year)
        aCoder.encode(imageName, forKey: BuildingKey.imageName)
        aCoder.encode(latitude, forKey: BuildingKey.latitude)
        aCoder.encode(longitude, forKey: BuildingKey.longitude)
        aCoder.encode(shouldBePinnedToMap, forKey: BuildingKey.shouldBePinnedToMap)
        aCoder.encode(isFavorite, forKey: BuildingKey.isFavorite)
        aCoder.encode(buildingCode, forKey: BuildingKey.buildingCode)
        
        if imageData != nil {
            aCoder.encode(imageData!)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: BuildingKey.name) as! String
        let year = aDecoder.decodeInteger(forKey: BuildingKey.year)
        let imageName = aDecoder.decodeObject(forKey: BuildingKey.imageName) as! String
        let latitude = aDecoder.decodeDouble(forKey: BuildingKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: BuildingKey.longitude)
        let isFavorite = aDecoder.decodeBool(forKey: BuildingKey.isFavorite)
        let shouldBePinnedToMap = aDecoder.decodeBool(forKey: BuildingKey.shouldBePinnedToMap)
        let buildingCode = aDecoder.decodeInteger(forKey: BuildingKey.buildingCode)
        let imageData = aDecoder.decodeData()
        
        self.init(name:name, buildingCode: buildingCode, year: year, imageName: imageName, latitude: latitude, longitude: longitude, isFavorite: isFavorite, shouldBePinnedToMap: shouldBePinnedToMap, imageData: imageData)
    }
    
    
}



class Archive : NSObject, NSCoding {
    let buildings : BuildingDict
    let allBuildings: [Building]
    
    init(buildings:BuildingDict, all:[Building]) {
        self.buildings = buildings
        self.allBuildings = all
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let buildings = aDecoder.decodeObject(forKey: ArchiveKey.buildings) as! BuildingDict
        let allBuildings = aDecoder.decodeObject(forKey: ArchiveKey.allBuildings) as! [Building]
        self.init(buildings:buildings, all: allBuildings)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(buildings, forKey: ArchiveKey.buildings)
        aCoder.encode(allBuildings, forKey: ArchiveKey.allBuildings)
    }
    
}

extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}
