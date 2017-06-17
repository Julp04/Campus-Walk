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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = prefs.integerForKey(UserDefaults.MapType)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentControlChanged(sender: AnyObject) {
        
        prefs.setInteger(segmentControl.selectedSegmentIndex, forKey: UserDefaults.MapType)
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
