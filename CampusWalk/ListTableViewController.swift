//
//  TableViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/18/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit


class ListTableViewController: UITableViewController {
    
   
    
    let buildingModel = BuildingModel.sharedInstance
    var selectedBuilding:Building?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

            return buildingModel.numberOfBuildingSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return buildingModel.numberOfBuildingsInSection(section)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuildingCell", forIndexPath: indexPath) as! BuildingCell
        
        
            
        let building = buildingModel.buildingAtIndexPath(indexPath)
        
        cell.nameLabel.text = building.name
        cell.indexPath = indexPath
        
        return cell

    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return buildingModel.titleForSection(section)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
            return buildingModel.indexTitle()
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            selectedBuilding = buildingModel.buildingAtIndexPath(indexPath)
            performSegueWithIdentifier("DismissListSegue", sender: self)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let directionsVC = segue.destinationViewController as? DirectionsViewController
        {
            directionsVC.setTextField(selectedBuilding!)
        }
        
    }
    
    
}
