//
//  RiderViewController.swift
//  TaskProject
//
//  Created by Maheep Kaushal on 26/12/15.
//  Copyright © 2015 Maheep Kaushal. All rights reserved.
//

import UIKit
import GoogleMaps

class RiderViewController : UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var destinationPoint: UITextField!
    @IBOutlet weak var startPoint: UITextField!
    @IBOutlet weak var drivingMode: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    let dataProvider = DataProvider()
    
// Mark: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }

    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.startPoint.text = lines.joinWithSeparator("\n")
            }
        }
    }
    
// MARK: - IBActions    
    
    @IBAction func goPressed(sender: AnyObject) {
        
        self.mapView.clear()
        
        dataProvider.getCoordinatesFromAddress(self.destinationPoint.text!) { destinationCoordinates in
            print(destinationCoordinates)
            print(self.locationManager.location?.coordinate)
            
            self.dataProvider.getStepFromCoordinates((self.locationManager.location?.coordinate)!,
                destination:destinationCoordinates ,
                alternateRoutes:"true",
                mode:self.drivingMode.titleForSegmentAtIndex(self.drivingMode.selectedSegmentIndex)!,
                completion: { (routes) -> Void in                
                    if routes.count > 0 {
                        self.drawRouteBetweenTwoPoints((self.locationManager.location?.coordinate)!, destination: destinationCoordinates, routes: routes)
                    }
            })
        }
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}

// MARK:- Draw Route..

extension RiderViewController {
    
    func drawRouteBetweenTwoPoints(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, routes:NSArray){
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            routes.enumerateObjectsWithOptions(NSEnumerationOptions.Reverse , usingBlock: { (route, index, stop) -> Void in
                
                let steps = route["legs"]!![0]["steps"] as! NSArray
                
                steps.enumerateObjectsUsingBlock({ (step, count, stop) -> Void in
                    
                    let path = step["polyline"]!!["points"]
                    
                    let polygon = GMSPath(fromEncodedPath: path as! String)
                    
                    let polyline = GMSPolyline(path: polygon)
                    
                    polyline.map = self.mapView
                    polyline.strokeWidth = 5.0
                    polyline.geodesic = true
                    polyline.strokeColor = UIColor.lightGrayColor()
                    
                    if index == 0 {
                        polyline.strokeColor = UIColor.blueColor()
                    }
                })

            })
            
            
//            let path = routes[0]["overview_polyline"]!!["points"] as! NSString
//            
//            let polygon = GMSPath(fromEncodedPath: path as String)
//            let polyline = GMSPolyline(path: polygon)
//            
//            polyline.map = self.mapView
//            polyline.strokeWidth = 5.0
//            polyline.geodesic = true
//            polyline.strokeColor = UIColor.blueColor()
        }
    }
    
}

// MARK: - GMSMapViewDelegate
extension RiderViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
}

