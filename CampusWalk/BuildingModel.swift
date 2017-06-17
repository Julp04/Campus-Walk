//
//  BuildingModel.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/18/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation
import MapKit


typealias BuildingDict = [String:[Building]]

class BuildingModel
{
    var allBuildings = [Building]()   // just an array of all the buildings
    var buildings1 = [String:[Building]]()  // dictionary mapping letter to array of building beginning with that letter
    var allKeys = [String]()
    var favoriteBuildings = [Building]()
    let archive: Archive
    var buildings = [String:[Building]]()
    
    let fileName = "buildings"
    let buildingsURL:NSURL
    
    static let sharedInstance = BuildingModel()
    
    private init()
    {
            let fileManager = NSFileManager.defaultManager()
            let documentURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            buildingsURL = documentURL.URLByAppendingPathComponent(fileName + ".archive")
            
            let fileExists = fileManager.fileExistsAtPath(buildingsURL.path!)
            
            if fileExists {  // just read in the archive if it exists
                archive = NSKeyedUnarchiver.unarchiveObjectWithFile(buildingsURL.path!)! as! Archive
                buildings = archive.buildings
                allBuildings = archive.allBuildings
                
                allKeys = Array(buildings.keys).sort()
            }
            else {  // first time launching app
                
                    let bundle = NSBundle.mainBundle()
                    let srcURL = bundle.URLForResource(fileName, withExtension: "plist")!
                    do {
                        try  fileManager.copyItemAtURL(srcURL, toURL: buildingsURL)
                    } catch {
                        print("Error")
                    }
                    
                    if let array = NSArray(contentsOfURL: srcURL) as? [AnyObject] {
                        for element in array {
                            let name = element["name"] as! String
                            let buildingCode = element["opp_bldg_code"] as! Int
                            let year = element["year_constructed"] as! Int
                            let latitude = element["latitude"] as! Double
                            let longitude = element["longitude"] as! Double
                            let imageName = element["photo"] as! String
                            
                            let building = Building(name: name, buildingCode: buildingCode, year: year, imageName: imageName, latitude: latitude, longitude: longitude, isFavorite: false, shouldBePinnedToMap: false, imageData: nil)
                            
                            allBuildings.append(building)
                            
                            
                            
                            let firstLetter = building.name.firstLetter()
                            if buildings1[firstLetter!]?.append(building)  == nil {
                                buildings1[firstLetter!] = [building]
                            }
                        }
                    }
                
                for (key, building) in buildings1 {
                    
                    let sortedArray = building.sort({$0.name < $1.name})
                    buildings[key] = sortedArray
                }
                
                
                archive = Archive(buildings: buildings, all: allBuildings)
                NSKeyedArchiver.archiveRootObject(archive, toFile: buildingsURL.path!)
                
                allKeys = Array(buildings.keys).sort()
        }
        
        for building in allBuildings {
            if building.isFavorite == true {
                favoriteBuildings.append(building)
            }
        }
    }
    
    
    func saveArchive() {
        NSKeyedArchiver.archiveRootObject(archive, toFile: buildingsURL.path!)
    }
    
    
    
    //MARK: - Regular Buildings
    func numberOfBuildingSections() -> Int
    {
        return allKeys.count
    }
    
    func numberOfBuildingsInSection(section:Int) -> Int
    {
        let letter = allKeys[section]
        let buildingsWithThatLetter = buildings[letter]!
        return buildingsWithThatLetter.count
    }
    
    func titleForSection(section:Int) -> String
    {
        return allKeys[section]
    }
    
    func buildingAtIndexPath(indexPath:NSIndexPath) -> Building
    {
        let letter = allKeys[indexPath.section]
        let theBuildings = buildings[letter]!
        return theBuildings[indexPath.row]
    }
    
    func indexTitle() -> [String]
    {
        return allKeys
    }
    
    
    func pinToMap(building:Building)
    {
        building.shouldBePinnedToMap = true
        saveArchive()
    }
    
    func removePinFromMap(building:Building)
    {
        building.shouldBePinnedToMap = false
        saveArchive()
    }
    
    func addDataToBuilding(building:Building, data:NSData)
    {
        building.imageData = data;
        saveArchive()
    }
    
    
    
    //MARK: - Favorited Buildings
    func numberOfFavoritedBuildings() -> Int
    {
        return favoriteBuildings.count
    }
    
    func favoriteBuildingAtIndex(index:Int) -> Building
    {
        return favoriteBuildings[index]
    }
    
    func addBuildingToFavorites(building:Building) ->Bool
    {
        if favoriteBuildings.contains({$0.name == building.name}) {
            return false
        }else {
            building.isFavorite = true
            building.shouldBePinnedToMap = true
            favoriteBuildings.append(building)
            saveArchive()
            return true
        }
    }
    
    func removeFavoriteBuildingAtIndex(index:Int)
    {
        favoriteBuildings[index].isFavorite = false
        favoriteBuildings[index].shouldBePinnedToMap = false
        favoriteBuildings.removeAtIndex(index)
        saveArchive()
        
    }
}