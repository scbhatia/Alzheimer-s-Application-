//
//  NavegateHomeViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/23/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import Foundation

class NavegateHomeViewController:UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destAddress: UILabel!
    
    @IBOutlet weak var directionsLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D! // stores current location
    var destPlacemark = MKPlacemark() // stores destination placemark
    
    var homeLat = CLLocationDegrees()
    var homeLong = CLLocationDegrees()
    
    var steps = [MKRouteStep]() // initialize array of the steps for directions
    let speechSynthesizer = AVSpeechSynthesizer() // add speech for directions
    
    var stepCounter = 0
    
    var dest_address = "19878 Sea Gull Way, Saratoga, CA" // set the destination address here
    
    var geocoder = CLGeocoder()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard;
        if (userDefaults.object(forKey: "homeAddress") != nil){
            let home = userDefaults.object(forKey: "homeAddress") as! String;
            destAddress.text = "Home Address: " + home;
            dest_address = home
        }
        headtoHome()
        mapView.delegate = self
    }
    @IBAction func doneBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "gotHome", sender: Any?.self)
    }
    
    func headtoHome() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
        geocoder.geocodeAddressString(dest_address) { // turns string address into destPlacemark
            (placemarks: [CLPlacemark]?
            , error: Error?) in
            let placemark = placemarks?.first
            let lat = (placemark?.location?.coordinate.latitude)! // get latitude
            let lon = (placemark?.location?.coordinate.longitude)! // get longitude
            let newcoordinate = CLLocationCoordinate2DMake(lat, lon)
            let mkPlacemark = MKPlacemark(coordinate: newcoordinate)
            let destCoordinate = MKMapItem(placemark: mkPlacemark)
            self.getDirections(to: destCoordinate) // get directions to home address
        }
        print(dest_address)
        
    }
    
    func getDirections(to destination: MKMapItem) {
        //currentCoordinate = CLLocationCoordinate2DMake(homeLat, homeLong)
        //print(currentCoordinate)
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate) // start point ( current coordinate )
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark) // turn placemark into mapitem
        
        let directionsRequest = MKDirectionsRequest() // initialize request
        directionsRequest.source = sourceMapItem // define source
        directionsRequest.destination = destination // define destinatoin
        directionsRequest.transportType = .walking // transportation type to walking
        
        let directions = MKDirections(request: directionsRequest) // initialize directions to direction request
        
        // can calcuate ETA
        directions.calculate { (response, _) in // calculate directions
            guard let response = response else { return } // get the response
            guard let primaryRoute = response.routes.first else { return } // use the first route
            
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            let polyline = primaryRoute.polyline
            print("adding polyline")
            self.mapView.add(polyline) // add the polyine( directions ) to the map
            //loop through and remove each region so we can search again, does not double up
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
            self.steps = primaryRoute.steps // save the steps of the primary route
            for i in 0 ..< primaryRoute.steps.count { // for the amount of steps
                let step = primaryRoute.steps[i] // assign the ith steph
                print(step.instructions) // print step
                print(step.distance) // print distance
                let region = CLCircularRegion(center: step.polyline.coordinate, // create a region for that step
                    radius: 20,
                    identifier: "\(i)")
                self.locationManager.startMonitoring(for: region) // add region to start being monitored
                let circle = MKCircle(center: region.center, radius: region.radius) //create geolocation at each step
                self.mapView.add(circle) // add it to the map
            }
            
            //update directions label
            //initialize the first message to be printed
            let initialMessage = "In \(self.steps[0].distance) meters, \(self.steps[0].instructions) then in \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
            self.directionsLabel.text = initialMessage // set directions label to initial message
            let speechUtterance = AVSpeechUtterance(string: initialMessage)
            self.speechSynthesizer.speak(speechUtterance) // speaks the directions
            self.stepCounter += 1 // increment stepCounter
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return } // gets the users location
        currentCoordinate = currentLocation.coordinate // sets the current location
        print(currentCoordinate)
        //mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading // zoom into user location and point map in direction your looking
    }
    
    private func locationManager(_ manager: CLLocationManager, didEnterRegion region: [CLRegion]) {
        print("ENTERED")
        stepCounter += 1
        if stepCounter < steps.count { // make sure step counter is not out of range
            let currentStep = steps[stepCounter] //
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)" // set message to current step
            directionsLabel.text = message // set directions label to message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance) // speak out message
        } else { // out of range and we are at destination
            let message = "Arrived at destination"
            directionsLabel.text = message // update label
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance) // tell us that we have arrived
            stepCounter = 0 // reinitialize
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) }) // stop monitoring
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("mapview render")
        if overlay is MKPolyline { // if polyine
            print("mkpolyline")
            let renderer = MKPolylineRenderer(overlay: overlay) // set renderer to polyline
            renderer.strokeColor = .blue // set color of line to blue
            renderer.lineWidth = 10 // set width
            return renderer // return renderer
        }
        if overlay is MKCircle { // if at the geolocation
            print("mkpolycircle")
            let renderer = MKCircleRenderer(overlay: overlay) // create renderer
            renderer.strokeColor = .blue
            renderer.fillColor = .blue
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}


