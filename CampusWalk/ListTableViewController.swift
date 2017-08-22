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
    
    override func numberOfSections(in tableView: UITableView) -> Int {

            return buildingModel.numberOfBuildingSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return buildingModel.numberOfBuildingsInSection(section)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath) as! BuildingCell
        
        
            
        let building = buildingModel.buildingAtIndexPath(indexPath)
        
        cell.nameLabel.text = building.name
        cell.indexPath = indexPath
        
        return cell

    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return buildingModel.titleForSection(section)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            return buildingModel.indexTitle()
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedBuilding = buildingModel.buildingAtIndexPath(indexPath)
            performSegue(withIdentifier: "DismissListSegue", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let directionsVC = segue.destination as? DirectionsViewController
        {
            directionsVC.setTextField(selectedBuilding!)
        }
        
    }
    
    
}
