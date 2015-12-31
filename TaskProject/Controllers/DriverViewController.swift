//
//  DriverViewController.swift
//  TaskProject
//
//  Created by Maheep Kaushal on 26/12/15.
//  Copyright © 2015 Maheep Kaushal. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DriverViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var theMap: MKMapView!    
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var destination: UITextField!
    
    let dataProvider = DataProvider()
    let geoCoder = CLGeocoder()
    
    var locationManager = CLLocationManager()
    var myLocations: [CLLocation] = []
    
// MARK: - View Life Cycle..
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup our Location Manager
        locationManager.delegate = self
        
        if locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")){
            locationManager.requestWhenInUseAuthorization()
        }else{
            locationManager.startUpdatingLocation()
        }
        
        //Setup our Map View
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        theMap.showsUserLocation = true
    }
    
    
// MARK: - IBActions..
    
    @IBAction func goPressed(sender: AnyObject) {
        
        dataProvider.getCoordinatesFromAddress(self.destination.text!) { (destinationCoordinates) -> Void in
            
            print(destinationCoordinates)
            print(self.locationManager.location?.coordinate)
        
            self.dataProvider.getStepFromCoordinates((self.locationManager.location?.coordinate)!,
                destination: destinationCoordinates,
                alternateRoutes:"false",
                mode: "DRIVING",
                completion: { (routes) -> Void in
                    
                    if routes.count > 0 {
                        
                        self.theMap.removeAnnotations(self.theMap.annotations)
                        
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            
                            routes.enumerateObjectsWithOptions(NSEnumerationOptions.Reverse , usingBlock: { (route, index, stop) -> Void in
                                
                                let steps = route["legs"]!![0]["steps"] as! NSArray
                                
                                steps.enumerateObjectsUsingBlock({ (step, count, stop) -> Void in
                                    
                                    var  lat = (step["start_location"]!!["lat"])!!.doubleValue
                                    var  lng  = (step["start_location"]!!["lng"])!!.doubleValue
                                    
                                    let start_loc = CLLocationCoordinate2DMake(lat,lng) as CLLocationCoordinate2D
                                    
                                    lat = (step["end_location"]!!["lat"])!!.doubleValue
                                    lng  = (step["end_location"]!!["lng"])!!.doubleValue
                                    
                                    let end_loc = CLLocationCoordinate2DMake(lat,lng)
                                    
                                    var points: [CLLocationCoordinate2D]
                                    points = [start_loc, end_loc]
                                    
                                    self.theMap.addOverlay(MKPolyline(coordinates: &points, count: points.count))
                                })
                                
                            })
                        }
                    }
            })
        }
    }
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK:- Get Address
    
    func getAddress (location: CLLocation){
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error \(error?.localizedDescription)")
                return
            }
            
            if placeMarks?.count > 0 {
                self.currentLocation.text = (placeMarks![0].locality! + " " + placeMarks![0].subLocality! + "," + placeMarks![0].country!)
            }
        }
    }
    
// MARK:- Location Delegates..
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            locationManager.stopUpdatingLocation()
            
            let spanX = 0.007
            let spanY = 0.007
            let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: true)
            
            self.getAddress(location)
        }
    }
    
// MARK:- MapView Delegates..
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        
        return polylineRenderer
    }
}

