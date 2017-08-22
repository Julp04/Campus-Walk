//
//  BuildingCell.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/18/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class BuildingCell: UITableViewCell {

    let buildingModel = BuildingModel.sharedInstance
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func addBuildingToFavorites(_ sender: AnyObject) {
        
        let building  = buildingModel.buildingAtIndexPath(indexPath!)
        
        if !buildingModel.addBuildingToFavorites(building) {
            let index = buildingModel.favoriteBuildings.index(of: building)
            buildingModel.removeFavoriteBuildingAtIndex(index!)
            favoriteButton.setImage(UIImage(named: "star_empty"), for: UIControlState())
        }else{
            favoriteButton.setImage(UIImage(named: "star_fill"), for: UIControlState())
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
