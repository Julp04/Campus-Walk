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
    
    var locationEnabledButton = UIButton(type: .Custom)
    var locationDisabledButton = UIButton(type: .Custom)
    var favoritesEnabledButton = UIButton(type: .Custom)
    var favoritesDisabledButton = UIButton(type: .Custom)
    
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
            case .Denied:
                self.locationManager.stopUpdatingLocation()
                self.locationManager.startUpdatingHeading()
                self.locationButton.tag = 0
                self.locationButton.enabled = false
            case .NotDetermined:
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
        
        locationEnabledButton.frame = CGRectMake(0, 0, kToolBarButtonLenght, kToolBarButtonLenght)
        locationDisabledButton.frame = CGRectMake(0, 0, kToolBarButtonLenght, kToolBarButtonLenght)
        favoritesEnabledButton.frame = CGRectMake(0, 0, kToolBarButtonLenght, kToolBarButtonLenght)
        favoritesDisabledButton.frame = CGRectMake(0, 0, kToolBarButtonLenght, kToolBarButtonLenght)
        
        locationEnabledButton.setImage(UIImage(named: "arrow_filled"), forState: .Normal)
        locationEnabledButton.addTarget(self, action: #selector(MapViewController.hideUserLocation), forControlEvents: .TouchDown)
        
        locationDisabledButton.setImage(UIImage(named: "arrow_empty"), forState: .Normal)
        locationDisabledButton.addTarget(self, action: #selector(MapViewController.showUserLocation), forControlEvents: .TouchDown)
        
        favoritesEnabledButton.setImage(UIImage(named:"full_star"), forState: .Normal)
        favoritesEnabledButton.addTarget(self, action: #selector(MapViewController.hideFavoritePins), forControlEvents: .TouchDown)
        
        favoritesDisabledButton.setImage(UIImage(named:"empty_star"), forState: .Normal)
        favoritesDisabledButton.addTarget(self, action: #selector(MapViewController.showFavoritePins), forControlEvents: .TouchDown)
        
        favoritesButton.customView = favoritesEnabledButton
        locationButton.customView = locationEnabledButton
    }
    
    override func viewWillAppear(animated: Bool) {
        //If app is coming from favorites it needs to recheck and reload the favorite pins
        updateMapView()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let favoritesEnabled = prefs.boolForKey(UserDefaults.FavsEnabled)
        if favoritesEnabled {
            showFavoritePins()
        }else {
            hideFavoritePins()
        }
        
        
        let locationEnabled = prefs.boolForKey(UserDefaults.LocationEnabled)
        if locationEnabled {
            showUserLocation()
        }else {
            hideUserLocation()
        }

    }
    
    func updateMapView()
    {
        let prefs = NSUserDefaults.standardUserDefaults()
        let mapType = prefs.integerForKey(UserDefaults.MapType)
        
        switch mapType {
        case 0:
            mapView.mapType = .Standard
        case 1:
            mapView.mapType = .Satellite
        case 2:
            mapView.mapType = .Hybrid
        default:
            mapView.mapType = .Standard
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is Building {
            let building = annotation as! Building
            let pinColor = (building.isFavorite) ? UIColor.yellowColor() : UIColor.blueColor()
            
            let identifier = "BuildingPin"
            var view: MKPinAnnotationView

            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.pinTintColor = pinColor
            view.animatesDrop = true
            view.draggable = true
            
            if !building.isFavorite {
                let removeButton = UIButton(type: .Custom)
                removeButton.setImage(UIImage(named: "trash"), forState: .Normal)
                removeButton.frame = CGRect(x: 0.0, y: 0.0, width: KButtonLegnth, height: KButtonLegnth)

                removeButton.addTarget(self, action: #selector(MapViewController.removePin(_:)), forControlEvents: .TouchUpInside)
                view.rightCalloutAccessoryView = removeButton
            }
            
            return view
        }
        
        return nil
    }
    
    
    func removePin(sender:AnyObject)
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
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: UserDefaults.FavsEnabled)
    }
    
    func hideFavoritePins()
    {
        mapView.removeAnnotations(buildingModel.favoriteBuildings)
        favoritesButton.customView = favoritesDisabledButton
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(false, forKey: UserDefaults.FavsEnabled)
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
  
    
    func addPinForBuilding(building:Building)
    {
        let span = MKCoordinateSpan(latitudeDelta: kPinSpanLat, longitudeDelta: kPinSpanLong)
        let region = MKCoordinateRegion(center: building.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        buildingModel.pinToMap(building)
        mapView.addAnnotation(building)
    }
    

    @IBAction func buildingPinSegue(segue:UIStoryboardSegue) {
        if let infoVC = segue.sourceViewController as? InfoViewController {
            let building = infoVC.building!
            addPinForBuilding(building)
        }
    }
    
    @IBAction func showPinSegue(segue:UIStoryboardSegue){
        if let infoVC = segue.sourceViewController as? InfoViewController {
            let building = infoVC.building!
            let span = MKCoordinateSpan(latitudeDelta: kPinSpanLat, longitudeDelta: kPinSpanLong)
            let region = MKCoordinateRegion(center: building.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK:- Location Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         self.userLocation = locations.first
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways{
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
            self.locationButton.enabled = true
            self.locationButton.tag = 1

        } else {
            self.locationButton.enabled = false
            self.locationButton.tag = 0
            self.locationManager.stopUpdatingHeading()
            self.locationManager.stopUpdatingLocation()


        }
        
        checkLocationPrefs()
    }
    
    func checkLocationPrefs()
    {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        let locationEnabled = prefs.boolForKey(UserDefaults.LocationEnabled)
        if locationEnabled {
            showUserLocation()
        }else {
            hideUserLocation()
        }
    }
    
    func zoomToUserLocation(location:CLLocation)
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
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: UserDefaults.LocationEnabled)
    }
    
    func hideUserLocation()
    {
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
        locationButton.customView = locationDisabledButton
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(false, forKey: UserDefaults.LocationEnabled)
    }
    
    
    @IBAction func dimissDirections(segue:UIStoryboardSegue){
        getDirections()
    }
    
    func getDirections() {
        let walkingRouteRequest = MKDirectionsRequest()
        
        walkingRouteRequest.source = source
        walkingRouteRequest.destination = destination
        walkingRouteRequest.transportType = .Walking
        walkingRouteRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: walkingRouteRequest)
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            if error != nil {
                assert(false, "Error getting directions.")
            } else {
                self.showDirections(response!)
                self.configureScrollView()
                self.addDirectionsToScrollView()
                self.configureETA(response!)
            }
        }
    }
    
    func configureETA(response:MKDirectionsResponse)
    {
        let route = response.routes.first
        //Divide by 60 so its in minutes
        let eta = Int((route?.expectedTravelTime)!)/60
        
        
        let startDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let endDate = calendar.dateByAddingUnit(.Minute, value:eta , toDate: startDate, options: [])
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = NSLocale.currentLocale()
        
        let stringForEta = dateFormatter.stringFromDate(endDate!)
        
        self.navigationItem.title = "ETA:" + stringForEta
        
    }
    
    func showDirections(response: MKDirectionsResponse) {
        mapView.removeOverlays(mapView.overlays)
        
        let route = response.routes.first!
        
        stepByStepDirections = route.steps
        
        mapView.addOverlay(route.polyline)
        
        let region = MKCoordinateRegionMakeWithDistance(route.polyline.coordinate, kPolygonRegion, kPolygonRegion)
        mapView.setRegion(region, animated: true)
    }
    
    func setSourceAndDestination(source:MKMapItem?, destination:MKMapItem?)
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polylineRenderer.strokeColor = UIColor.redColor()
            polylineRenderer.lineWidth = 4.0
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let directionsListVC = segue.destinationViewController as? DirectionsTableViewController
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
            directionsScrollView.pagingEnabled = true
            directionsScrollView.directionalLockEnabled = true
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
                pageView.backgroundColor = UIColor.whiteColor()
                
                let step = directions[index].instructions
                
                let labelFrame = CGRect(x: 0.0, y: 0.0, width: size.width, height: 30.0)
                let label = UILabel(frame: labelFrame)
                label.textColor = UIColor.blackColor()
                label.textAlignment = .Center
    
                label.text = "\(index + 1).)\(step)"
                pageView.addSubview(label)
                
                self.directionsScrollView.addSubview(pageView)
                }
        }
    }
    


}
