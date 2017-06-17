//
//  DirectionsViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/26/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import MapKit

class DirectionsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    var source:MKMapItem?
    var destination:MKMapItem?
    
    var fromBuilding:Building?
    var toBuilding:Building?
    
    var lastTappedField:UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fromTextField.delegate = self
        toTextField.delegate = self
        
        fromTextField.tag = 0
        toTextField.tag = 1
    }

   //MARK: - Textfield Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        lastTappedField = textField
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        displayActionAlert()

    }
    
    
    
    
    @IBAction func dismissList(segue: UIStoryboardSegue) {
    }
    
    func setTextField(building:Building)
    {
        lastTappedField?.text = building.name
        if lastTappedField?.tag == 0 {
            fromBuilding = building
        }else {
            toBuilding = building
        }
        
    }
    
    
    func displayActionAlert()
    {
        
        let actionAlert = UIAlertController(title: "Select a Location", message: nil, preferredStyle: .ActionSheet)
        actionAlert.popoverPresentationController?.sourceView = lastTappedField
        
        let listOfBuildings = UIAlertAction(title: "List of buildings", style: .Default) { (action) in
            self.performSegueWithIdentifier("ListSegue", sender: self)
        }
        
        let currentLocation = UIAlertAction(title: "Current Location", style: .Default) { (action) in
            self.lastTappedField?.text = "Current Location"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        
        
        let prefs = NSUserDefaults.standardUserDefaults()
        currentLocation.enabled = prefs.boolForKey(UserDefaults.LocationEnabled)
        
        actionAlert.addAction(listOfBuildings)
        actionAlert.addAction(currentLocation)
        actionAlert.addAction(cancel)
        
        
        self.presentViewController(actionAlert, animated: true, completion: nil)
    }
    
    
    func createMKMapItems()
    {
        if fromTextField.text == "Current Location" {
            source = nil
        }else {
            let placemark = MKPlacemark(coordinate: fromBuilding!.coordinate, addressDictionary: nil)
            source = MKMapItem(placemark: placemark)
        }
        
        if toTextField.text == "Current Location" {
            destination = nil
        }else {
            let placemark = MKPlacemark(coordinate: toBuilding!.coordinate, addressDictionary: nil)
            destination = MKMapItem(placemark: placemark)
        }
        
        
    }
    
    @IBAction func getDirections(sender: AnyObject) {
        
        if !(toTextField.text?.isEmpty)! && !(fromTextField.text?.isEmpty)! {
            createMKMapItems()
            self.performSegueWithIdentifier("DismissDirections", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mapVC = segue.destinationViewController as? MapViewController {
            mapVC.setSourceAndDestination(source, destination: destination)
        }
    }
    
    

}
