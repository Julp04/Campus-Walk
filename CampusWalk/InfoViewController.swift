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
        imageView.isUserInteractionEnabled = true
        plotButton.backgroundColor = UIColor.blue
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func configureInfoWithBuilding(_ building:Building)
    {
        self.building = building
        self.yearBuilt = building.year
        self.buildingName = building.name
        self.imageName = building.imageName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = building?.imageData {
            let image = UIImage(data: data as Data)
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
            self.yearBuiltLabel.isHidden = true
        }else{
            self.yearBuiltLabel.isHidden = false
            self.yearBuiltLabel.text = "Year Built: \(yearBuilt)"
        }
        buildingNameLabel.text = buildingName
    }
    
    func configurePlotButton()
    {
        if building?.shouldBePinnedToMap == false {
            plotButton.addTarget(self, action: #selector(InfoViewController.plotBuilding), for: .touchUpInside)
            plotButton.setTitle("Plot Building On Map", for: UIControlState())
        }else{
            plotButton.addTarget(self, action: #selector(InfoViewController.showOnMap), for: .touchUpInside)
            plotButton.setTitle("Show Building On Map", for: UIControlState())
        }
    }
    
    func plotBuilding()
    {
        performSegue(withIdentifier: "BuildingPinSegue", sender: self)
    }
    
    func showOnMap()
    {
       performSegue(withIdentifier: "ShowPinSegue", sender: self)
    }
    
    func presentImagePicker()
    {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func alertForCamera()
    {
        let alert = UIAlertController(title: "Select Photo From", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = imageView
        
        
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
    
                self.imagePicker.sourceType = .camera
                self.presentImagePicker()
            })
        
        let libraryAction = UIAlertAction(title: "Photos", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.presentImagePicker()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(cameraAction)
        }
        
        alert.addAction(libraryAction)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Image Picker Delegate
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        let imageData = UIImageJPEGRepresentation(image, kImageCompression)
        building!.imageData = imageData
        
        buildingModel.addDataToBuilding(building!, data: imageData!)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    

}
