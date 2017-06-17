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
    var imageData:NSData?
    
    init(name:String, buildingCode:Int, year:Int, imageName:String, latitude:Double, longitude:Double, isFavorite:Bool?, shouldBePinnedToMap: Bool?, imageData:NSData?)
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
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: BuildingKey.name)
        aCoder.encodeInteger(year, forKey: BuildingKey.year)
        aCoder.encodeObject(imageName, forKey: BuildingKey.imageName)
        aCoder.encodeDouble(latitude, forKey: BuildingKey.latitude)
        aCoder.encodeDouble(longitude, forKey: BuildingKey.longitude)
        aCoder.encodeBool(shouldBePinnedToMap, forKey: BuildingKey.shouldBePinnedToMap)
        aCoder.encodeBool(isFavorite, forKey: BuildingKey.isFavorite)
        aCoder.encodeInteger(buildingCode, forKey: BuildingKey.buildingCode)
        
        if imageData != nil {
            aCoder.encodeDataObject(imageData!)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(BuildingKey.name) as! String
        let year = aDecoder.decodeIntegerForKey(BuildingKey.year)
        let imageName = aDecoder.decodeObjectForKey(BuildingKey.imageName) as! String
        let latitude = aDecoder.decodeDoubleForKey(BuildingKey.latitude)
        let longitude = aDecoder.decodeDoubleForKey(BuildingKey.longitude)
        let isFavorite = aDecoder.decodeBoolForKey(BuildingKey.isFavorite)
        let shouldBePinnedToMap = aDecoder.decodeBoolForKey(BuildingKey.shouldBePinnedToMap)
        let buildingCode = aDecoder.decodeIntegerForKey(BuildingKey.buildingCode)
        let imageData = aDecoder.decodeDataObject()
        
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
        let buildings = aDecoder.decodeObjectForKey(ArchiveKey.buildings) as! BuildingDict
        let allBuildings = aDecoder.decodeObjectForKey(ArchiveKey.allBuildings) as! [Building]
        self.init(buildings:buildings, all: allBuildings)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(buildings, forKey: ArchiveKey.buildings)
        aCoder.encodeObject(allBuildings, forKey: ArchiveKey.allBuildings)
    }
    
}

extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substringToIndex(self.startIndex.successor()))
    }
}