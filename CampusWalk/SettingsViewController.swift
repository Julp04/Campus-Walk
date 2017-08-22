//
//  SettingsViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/31/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let prefs = Foundation.UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = prefs.integer(forKey: UserDefaults.MapType)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentControlChanged(_ sender: AnyObject) {
        
        prefs.set(segmentControl.selectedSegmentIndex, forKey: UserDefaults.MapType)
    }
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
