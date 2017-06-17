//
//  Constants.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/31/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation


struct UserDefaults {
    static let MapType = "mapType"
    static let FavsEnabled = "favsEnabled"
    static let LocationEnabled = "locationEnabled"
}

struct BuildingKey {
    static let name = "name"
    static let year = "year"
    static let imageName = "imageName"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let shouldBePinnedToMap = "shouldBePinnedToMap"
    static let isFavorite = "isFavorite"
    static let buildingCode = "buildingCode"
    static let imageData = "imageData"
}

struct ArchiveKey {
    static let buildings = "buildings"
    static let allBuildings = "allBuildings"
}