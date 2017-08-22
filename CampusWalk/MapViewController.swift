//
//  MapViewController.swift
//  CampusWalk
//
//  Created by Julian Panucci on 10/19/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate {

    
    let buildingModel = BuildingModel.sharedInstance
    let locationManager = CLLocationManager()
    
    let kCenterLatitude = 40.798188
    let kCenterLongitude = -77.861026
    let kStartLat = 0.02
    let kStartLong = 0.02
    let KButtonLegnth = 32.0
    let kToolBarButtonLenght:CGFloat = 35.0
    let kPolygonRegion = 1500.0
    let kPinSpanLat = 0.01
    let kPinSpanLong = 0.01
    
    var source:MKMapItem?
    var destination:MKMapItem?
    var stepByStepDirections:[MKRouteStep]?
    var buildingToPin:Building?
    var selectedBuilding:Building?
    var userLocation:CLLocation?
    
    var locationEnabledButton = UIButton(type: .custom)
    var locationDisabledButton = UIButton(type: .custom)
    var favoritesEnabledButton = UIButton(type: .custom)
    var favoritesDisabledButton = UIButton(type: .custom)
    
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var favoritesButton: UIBarButtonItem!

    //Using bar button item to show eta because I can't put label in nav bar
   
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var directionsScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = ""
        
        configureMapView()
        configureLocationManager()
        
        setupToolBarButtons()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied:
                self.locationManager.stopUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                self.locationButton.tag = 0
                self.locationButton.isEnabled = false
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                self.locationManager.startUpdatingLocation()
            }
        }
        
       
   
     
        
       displayPins()
    }
    
    override func viewDidLayoutSubviews() {
        configureScrollView()
        addDirectionsToScrollView()
    }
    
    
    //Setting up tool bar buttons so they can change states and images when selected.
    func setupToolBarButtons()
    {
        
        locationEnabledButton.frame = CGRect(x: 0, y: 0, width: kToolBarButtonLenght, height: kToolBarButtonLenght)
        locationDisabledButton.frame = CGRect(x: 0, y: 0, width: kToolBarButtonLenght, height: kToolBarButtonLenght)
        favoritesEnabledButton.frame = CGRect(x: 0, y: 0, width: kToolBarButtonLenght, height: kToolBarButtonLenght)
        favoritesDisabledButton.frame = CGRect(x: 0, y: 0, width: kToolBarButtonLenght, height: kToolBarButtonLenght)
        
        locationEnabledButton.setImage(UIImage(named: "arrow_filled"), for: UIControlState())
        locationEnabledButton.addTarget(self, action: #selector(MapViewController.hideUserLocation), for: .touchDown)
        
        locationDisabledButton.setImage(UIImage(named: "arrow_empty"), for: UIControlState())
        locationDisabledButton.addTarget(self, action: #selector(MapViewController.showUserLocation), for: .touchDown)
        
        favoritesEnabledButton.setImage(UIImage(named:"full_star"), for: UIControlState())
        favoritesEnabledButton.addTarget(self, action: #selector(MapViewController.hideFavoritePins), for: .touchDown)
        
        favoritesDisabledButton.setImage(UIImage(named:"empty_star"), for: UIControlState())
        favoritesDisabledButton.addTarget(self, action: #selector(MapViewController.showFavoritePins), for: .touchDown)
        
        favoritesButton.customView = favoritesEnabledButton
        locationButton.customView = locationEnabledButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //If app is coming from favorites it needs to recheck and reload the favorite pins
        updateMapView()
        
        let prefs = Foundation.UserDefaults.standard
        let favoritesEnabled = prefs.bool(forKey: UserDefaults.FavsEnabled)
        if favoritesEnabled {
            showFavoritePins()
        }else {
            hideFavoritePins()
        }
        
        
        let locationEnabled = prefs.bool(forKey: UserDefaults.LocationEnabled)
        if locationEnabled {
            showUserLocation()
        }else {
            hideUserLocation()
        }

    }
    
    func updateMapView()
    {
        let prefs = Foundation.UserDefaults.standard
        let mapType = prefs.integer(forKey: UserDefaults.MapType)
        
        switch mapType {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
        
    }
    
    func configureMapView() {
        
        let startingCenter = CLLocationCoordinate2D(latitude:kCenterLatitude , longitude: kCenterLongitude)
        let startingSpan = MKCoordinateSpan(latitudeDelta: kStartLat, longitudeDelta: kStartLong)
        let startingRegion = MKCoordinateRegion(center: startingCenter, span: startingSpan)
        mapView.setRegion(startingRegion, animated: true)
        
        mapView.delegate = self
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    
    
    //MARK: -Map View Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is Building {
            let building = annotation as! Building
            let pinColor = (building.isFavorite) ? UIColor.yellow : UIColor.blue
            
            let identifier = "BuildingPin"
            var view: MKPinAnnotationView

            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.pinTintColor = pinColor
            view.animatesDrop = true
            view.isDraggable = true
            
            if !building.isFavorite {
                let removeButton = UIButton(type: .custom)
                removeButton.setImage(UIImage(named: "trash"), for: UIControlState())
                removeButton.frame = CGRect(x: 0.0, y: 0.0, width: KButtonLegnth, height: KButtonLegnth)

                removeButton.addTarget(self, action: #selector(MapViewController.removePin(_:)), for: .touchUpInside)
                view.rightCalloutAccessoryView = removeButton
            }
            
            return view
        }
        
        return nil
    }
    
    
    func removePin(_ sender:AnyObject)
    {
        let buildingToRemove = mapView.selectedAnnotations.first as! Building
        mapView.removeAnnotation(buildingToRemove)
        buildingModel.removePinFromMap(buildingToRemove)
    }
    
    func showFavoritePins()
    {
     //Iterate through annoations if it is a building pin and it is not contained in favorite pins and it shouldnt be pinned to map then remove it to clear all favorite pins, then we add all favorite pins back
        for annoation in mapView.annotations {
            if annoation is Building {
                let b = annoation as! Building
                if !buildingModel.favoriteBuildings.contains(b) && b.shouldBePinnedToMap == false  {
                    mapView.removeAnnotation(b)
                }
            }
        }
        
        mapView.addAnnotations(buildingModel.favoriteBuildings)
        favoritesButton.customView = favoritesEnabledButton
        
        let prefs = Foundation.UserDefaults.standard
        prefs.set(true, forKey: UserDefaults.FavsEnabled)
    }
    
    func hideFavoritePins()
    {
        mapView.removeAnnotations(buildingModel.favoriteBuildings)
        favoritesButton.customView = favoritesDisabledButton
        
        let prefs = Foundation.UserDefaults.standard
        prefs.set(false, forKey: UserDefaults.FavsEnabled)
    }
    
    func displayPins()
    {
        for building in buildingModel.allBuildings
        {
            if building.shouldBePinnedToMap {
                mapView.addAnnotation(building)
            }
        }
    }
  
    
    func addPinForBuilding(_ building:Building)
    {
        let span = MKCoordinateSpan(latitudeDelta: kPinSpanLat, longitudeDelta: kPinSpanLong)
        let region = MKCoordinateRegion(center: building.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        buildingModel.pinToMap(building)
        mapView.addAnnotation(building)
    }
    

    @IBAction func buildingPinSegue(_ segue:UIStoryboardSegue) {
        if let infoVC = segue.source as? InfoViewController {
            let building = infoVC.building!
            addPinForBuilding(building)
        }
    }
    
    @IBAction func showPinSegue(_ segue:UIStoryboardSegue){
        if let infoVC = segue.source as? InfoViewController {
            let building = infoVC.building!
            let span = MKCoordinateSpan(latitudeDelta: kPinSpanLat, longitudeDelta: kPinSpanLong)
            let region = MKCoordinateRegion(center: building.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK:- Location Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         self.userLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
            self.locationButton.isEnabled = true
            self.locationButton.tag = 1

        } else {
            self.locationButton.isEnabled = false
            self.locationButton.tag = 0
            self.locationManager.stopUpdatingHeading()
            self.locationManager.stopUpdatingLocation()


        }
        
        checkLocationPrefs()
    }
    
    func checkLocationPrefs()
    {
        let prefs = Foundation.UserDefaults.standard
        
        let locationEnabled = prefs.bool(forKey: UserDefaults.LocationEnabled)
        if locationEnabled {
            showUserLocation()
        }else {
            hideUserLocation()
        }
    }
    
    func zoomToUserLocation(_ location:CLLocation)
    {
        let span = MKCoordinateSpan(latitudeDelta: kPinSpanLat, longitudeDelta: kPinSpanLong)
        
        let userRegion = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(userRegion, animated: true)
    }
    
    func showUserLocation()
    {
        mapView.showsUserLocation = true
        if userLocation != nil {
            zoomToUserLocation(userLocation!)
        }
        locationButton.customView = locationEnabledButton
        
        let prefs = Foundation.UserDefaults.standard
        prefs.set(true, forKey: UserDefaults.LocationEnabled)
    }
    
    func hideUserLocation()
    {
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
        locationButton.customView = locationDisabledButton
        
        let prefs = Foundation.UserDefaults.standard
        prefs.set(false, forKey: UserDefaults.LocationEnabled)
    }
    
    
    @IBAction func dimissDirections(_ segue:UIStoryboardSegue){
        getDirections()
    }
    
    func getDirections() {
        let walkingRouteRequest = MKDirectionsRequest()
        
        walkingRouteRequest.source = source
        walkingRouteRequest.destination = destination
        walkingRouteRequest.transportType = .walking
        walkingRouteRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: walkingRouteRequest)
        directions.calculate { (response, error) in
            if error != nil {
//                assert(false, "Error getting directions.")
                let alertController = UIAlertController(title: "Oops", message: "Could not get directions!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.showDirections(response!)
                self.configureScrollView()
                self.addDirectionsToScrollView()
                self.configureETA(response!)
            }
        }
    }
    
    func configureETA(_ response:MKDirectionsResponse)
    {
        let route = response.routes.first
        //Divide by 60 so its in minutes
        let eta = Int((route?.expectedTravelTime)!)/60
        
        
        let startDate = Date()
        let calendar = Calendar.current
        let endDate = (calendar as NSCalendar).date(byAdding: .minute, value:eta , to: startDate, options: [])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale.current
        
        let stringForEta = dateFormatter.string(from: endDate!)
        
        self.navigationItem.title = "ETA:" + stringForEta
        
    }
    
    func showDirections(_ response: MKDirectionsResponse) {
        mapView.removeOverlays(mapView.overlays)
        
        let route = response.routes.first!
        
        stepByStepDirections = route.steps
        
        mapView.add(route.polyline)
        
        let region = MKCoordinateRegionMakeWithDistance(route.polyline.coordinate, kPolygonRegion, kPolygonRegion)
        mapView.setRegion(region, animated: true)
    }
    
    func setSourceAndDestination(_ source:MKMapItem?, destination:MKMapItem?)
    {
        if source == nil { //User location
            let placemark = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
            self.source = MKMapItem(placemark: placemark)
        }else {
            self.source = source
        }
        
        if destination == nil { //User Location
            let placemark = MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil)
            self.destination = MKMapItem(placemark: placemark)
        }else {
            self.destination = destination
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let directionsListVC = segue.destination as? DirectionsTableViewController
        {
            directionsListVC.configueDirections(stepByStepDirections)
        }
    }
    
    
    //MARK: - Scroll View Methods
    
    //Using scroll view to show directions so user can swip from one to the next.
    
    func configureScrollView() {
        
        if let directions = stepByStepDirections {
            let horizontalPageCount = directions.count
            
            let width = directionsScrollView.bounds.size.width
            let height = directionsScrollView.bounds.size.height
            
            let contentSize = CGSize(width:width * CGFloat(horizontalPageCount), height: height)
            
            directionsScrollView.contentSize = contentSize
            directionsScrollView.isPagingEnabled = true
            directionsScrollView.isDirectionalLockEnabled = true
            directionsScrollView.bounces = false
            
            directionsScrollView.delegate = self
        }
       
    }
    
    func addDirectionsToScrollView()
    {
        if let directions = stepByStepDirections {
            for view in directionsScrollView.subviews {
                directionsScrollView.willRemoveSubview(view)
            }
            
            let size = directionsScrollView.bounds.size
            
            for index in 0..<directions.count {
                let xOffset = size.width*CGFloat(index)
                let origin = CGPoint(x: xOffset,y: 0.0)
                let frame = CGRect(origin: origin, size: size)
                let pageView = UIView(frame: frame)
                pageView.backgroundColor = UIColor.white
                
                let step = directions[index].instructions
                
                let labelFrame = CGRect(x: 0.0, y: 0.0, width: size.width, height: 30.0)
                let label = UILabel(frame: labelFrame)
                label.textColor = UIColor.black
                label.textAlignment = .center
    
                label.text = "\(index + 1).)\(step)"
                pageView.addSubview(label)
                
                self.directionsScrollView.addSubview(pageView)
                }
        }
    }
    


}
