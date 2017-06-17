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
    var indexPath:NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func addBuildingToFavorites(sender: AnyObject) {
        
        let building  = buildingModel.buildingAtIndexPath(indexPath!)
        
        if !buildingModel.addBuildingToFavorites(building) {
            let index = buildingModel.favoriteBuildings.indexOf(building)
            buildingModel.removeFavoriteBuildingAtIndex(index!)
            favoriteButton.setImage(UIImage(named: "star_empty"), forState: .Normal)
        }else{
            favoriteButton.setImage(UIImage(named: "star_fill"), forState: .Normal)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
