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
    @IBAction func segmentControlAction(_ sender: AnyObject) {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 { //Regular list of Buildings
            return buildingModel.numberOfBuildingSections()
        }else
        { // One section for favorites
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.numberOfBuildingsInSection(section)
        }else {
            return buildingModel.numberOfFavoritedBuildings()
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath) as! BuildingCell
        
        if segmentControl.selectedSegmentIndex == 0 {
            
            let building = buildingModel.buildingAtIndexPath(indexPath)
            
            cell.nameLabel.text = building.name
            cell.indexPath = indexPath
            cell.favoriteButton.isHidden = false
            
            if building.isFavorite {
                cell.favoriteButton.setImage(UIImage(named: "star_fill"), for: UIControlState())
            }else {
                cell.favoriteButton.setImage(UIImage(named: "star_empty"), for: UIControlState())
            }
            
            return cell
            
        }else {
            let building = buildingModel.favoriteBuildingAtIndex(indexPath.row)
            cell.nameLabel.text = building.name
            cell.favoriteButton.isHidden = true
            
            return cell
        }

    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.titleForSection(section)
        }else{return nil}
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if segmentControl.selectedSegmentIndex == 0 {
            return buildingModel.indexTitle()
        }else{ return nil}
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if segmentControl.selectedSegmentIndex == 1 {
            if editingStyle == UITableViewCellEditingStyle.delete {
                buildingModel.removeFavoriteBuildingAtIndex(indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 0 {
            let building = buildingModel.buildingAtIndexPath(indexPath)
            performSegue(withIdentifier: "BuildingInfoSegue", sender:building)
        }else {
            let building = buildingModel.favoriteBuildingAtIndex(indexPath.row)
            performSegue(withIdentifier: "BuildingInfoSegue", sender:building)
        }
        
    }
    
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let building = sender as? Building{
            if segue.identifier == "BuildingInfoSegue" {
                let infoVC = segue.destination as! InfoViewController
                infoVC.configureInfoWithBuilding(building)
            }
        }
        
    }
    
    
    
}
