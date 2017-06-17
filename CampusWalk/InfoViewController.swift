//
//  InfoViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/25/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var plotButton: UIButton!
    @IBOutlet weak var yearBuiltLabel: UILabel!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var yearBuilt = 0
    var buildingName = ""
    var imageName = ""
    var building:Building?
    let kImageCompression:CGFloat = 0.5
    var imagePicker = UIImagePickerController()
    
    let buildingModel = BuildingModel.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViews()
        configurePlotButton()
        
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InfoViewController.alertForCamera)))
        imageView.userInteractionEnabled = true
        plotButton.backgroundColor = UIColor.blueColor()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func configureInfoWithBuilding(building:Building)
    {
        self.building = building
        self.yearBuilt = building.year
        self.buildingName = building.name
        self.imageName = building.imageName
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let data = building?.imageData {
            let image = UIImage(data: data)
            imageView.image = image
        }
    }
    
    func loadViews()
    {
        
        if imageName != "" {
            let image = UIImage(named: self.imageName)!
            self.imageView.image = image
        }else {
            let notAvailableImage = UIImage(named: "no_image")!
            self.imageView.image = notAvailableImage
        }
        
        if yearBuilt == 0 {
            self.yearBuiltLabel.hidden = true
        }else{
            self.yearBuiltLabel.hidden = false
            self.yearBuiltLabel.text = "Year Built: \(yearBuilt)"
        }
        buildingNameLabel.text = buildingName
    }
    
    func configurePlotButton()
    {
        if building?.shouldBePinnedToMap == false {
            plotButton.addTarget(self, action: #selector(InfoViewController.plotBuilding), forControlEvents: .TouchUpInside)
            plotButton.setTitle("Plot Building On Map", forState: .Normal)
        }else{
            plotButton.addTarget(self, action: #selector(InfoViewController.showOnMap), forControlEvents: .TouchUpInside)
            plotButton.setTitle("Show Building On Map", forState: .Normal)
        }
    }
    
    func plotBuilding()
    {
        performSegueWithIdentifier("BuildingPinSegue", sender: self)
    }
    
    func showOnMap()
    {
       performSegueWithIdentifier("ShowPinSegue", sender: self)
    }
    
    func presentImagePicker()
    {
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func alertForCamera()
    {
        let alert = UIAlertController(title: "Select Photo From", message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.sourceView = imageView
        
        
            let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: { (action) in
    
                self.imagePicker.sourceType = .Camera
                self.presentImagePicker()
            })
        
        let libraryAction = UIAlertAction(title: "Photos", style: .Default) { (action) in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentImagePicker()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(cameraAction)
        }
        
        alert.addAction(libraryAction)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Image Picker Delegate
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        let imageData = UIImageJPEGRepresentation(image, kImageCompression)
        building!.imageData = imageData
        
        buildingModel.addDataToBuilding(building!, data: imageData!)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
