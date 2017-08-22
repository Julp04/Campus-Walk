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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lastTappedField = textField
        textField.resignFirstResponder()
        textField.endEditing(true)
        
        displayActionAlert()

    }
    
    
    
    
    @IBAction func dismissList(_ segue: UIStoryboardSegue) {
    }
    
    func setTextField(_ building:Building)
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
        
        let actionAlert = UIAlertController(title: "Select a Location", message: nil, preferredStyle: .actionSheet)
        actionAlert.popoverPresentationController?.sourceView = lastTappedField
        
        let listOfBuildings = UIAlertAction(title: "List of buildings", style: .default) { (action) in
            self.performSegue(withIdentifier: "ListSegue", sender: self)
        }
        
        let currentLocation = UIAlertAction(title: "Current Location", style: .default) { (action) in
            self.lastTappedField?.text = "Current Location"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        
        let prefs = Foundation.UserDefaults.standard
        currentLocation.isEnabled = prefs.bool(forKey: UserDefaults.LocationEnabled)
        
        actionAlert.addAction(listOfBuildings)
        actionAlert.addAction(currentLocation)
        actionAlert.addAction(cancel)
        
        
        self.present(actionAlert, animated: true, completion: nil)
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
    
    @IBAction func getDirections(_ sender: AnyObject) {
        
        if !(toTextField.text?.isEmpty)! && !(fromTextField.text?.isEmpty)! {
            createMKMapItems()
            self.performSegue(withIdentifier: "DismissDirections", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapVC = segue.destination as? MapViewController {
            mapVC.setSourceAndDestination(source, destination: destination)
        }
    }
    
    

}
