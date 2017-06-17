//
//  TableViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/18/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit


class TableViewController: UITableViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func segmentControlAction(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    let buildingModel = BuildingModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentControl.selectedSegmentIndex = 0
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 { //Regular list of Buildings
            return buildingModel.numberOfBuildingSections()
        }else
        { // One section for favorites
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.numberOfBuildingsInSection(section)
        }else {
            return buildingModel.numberOfFavoritedBuildings()
        }
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuildingCell", forIndexPath: indexPath) as! BuildingCell
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            let building = buildingModel.buildingAtIndexPath(indexPath)
            
            cell.nameLabel.text = building.name
            cell.indexPath = indexPath
            cell.favoriteButton.hidden = false
            
            if building.isFavorite {
                cell.favoriteButton.setImage(UIImage(named: "star_fill"), forState: .Normal)
            }else {
                cell.favoriteButton.setImage(UIImage(named: "star_empty"), forState: .Normal)
            }
            
            return cell
            
        }else {
            let building = buildingModel.favoriteBuildingAtIndex(indexPath.row)
            cell.nameLabel.text = building.name
            cell.favoriteButton.hidden = true
            
            return cell
        }

    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.titleForSection(section)
        }else{return nil}
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.indexTitle()
        }else{ return nil}
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if segmentControl.selectedSegmentIndex == 1 {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                buildingModel.removeFavoriteBuildingAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            let building = buildingModel.buildingAtIndexPath(indexPath)
            performSegueWithIdentifier("BuildingInfoSegue", sender:building)
        }else {
            let building = buildingModel.favoriteBuildingAtIndex(indexPath.row)
            performSegueWithIdentifier("BuildingInfoSegue", sender:building)
        }
        
    }
    
    
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let building = sender as? Building{
            if segue.identifier == "BuildingInfoSegue" {
                let infoVC = segue.destinationViewController as! InfoViewController
                infoVC.configureInfoWithBuilding(building)
            }
        }
        
    }
    
    
    
}
