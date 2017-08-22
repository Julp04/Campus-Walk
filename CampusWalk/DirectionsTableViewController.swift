//
//  DirectionsTableViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/26/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import MapKit

class DirectionsTableViewController: UITableViewController {

    var stepDirections:[MKRouteStep]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    func configueDirections(_ directions:[MKRouteStep]?)
    {
        self.stepDirections = directions
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.stepDirections == nil {
            return 1
        }else {
            return (self.stepDirections?.count)!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if stepDirections != nil {
            cell.textLabel?.text = stepDirections![indexPath.row].instructions
        }else {
            cell.textLabel?.text = "No directions to display"
        }
        
        return cell;
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      return UIView(frame: CGRect.zero)
    }

}
