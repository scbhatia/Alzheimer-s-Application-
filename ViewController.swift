//
//  ViewController.swift
//  MapLocation
//
//  Created by Satyajit Simhadri on 4/9/18.
//  Copyright © 2018 Satyajit Simhadri. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D! // stores current location
    
    var steps = [MKRouteStep]() // initialize array of the steps for directions
    let speechSynthesizer = AVSpeechSynthesizer() // add speech for directions
    
    var stepCounter = 0
    
    var listPolyline: [MKPolyline] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
    }
    
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate) // start point ( current coordinate )
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark) // turn placemark into mapitem
        
        let directionsRequest = MKDirectionsRequest() // initialize request
        directionsRequest.source = sourceMapItem // define source
        directionsRequest.destination = destination // define destinatoin
        directionsRequest.transportType = .automobile // transportation type to driving
        
        let directions = MKDirections(request: directionsRequest) // initialize directions to direction request
    
        // can calcuate ETA
        directions.calculate { (response, _) in // calculate directions
            guard let response = response else { return } // get the response
            guard let primaryRoute = response.routes.first else { return } // use the first route
            
            
            //self.listPolyline.append(primaryPolyline)
            
            self.mapView.add(primaryRoute.polyline) // add the polyine( directions ) to the map
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


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return } // gets the users location
        currentCoordinate = currentLocation.coordinate // sets the current location
        mapView.userTrackingMode = .followWithHeading // zoom into user location and point map in direction your looking
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
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
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true) // dismiss search bar
        let localSearchRequest = MKLocalSearchRequest() // initialize
        localSearchRequest.naturalLanguageQuery = searchBar.text // what they search for is what they query for
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) // specificy region around users location
        localSearchRequest.region = region // set region of local request
        let localSearch = MKLocalSearch(request: localSearchRequest) // initialize this with request
        localSearch.start { (response, _) in
            guard let response = response else { return }
            print(response.mapItems)
            guard let firstMapItem = response.mapItems.first else { return } // use the first map item
            self.getDirections(to: firstMapItem) // get directions to first map item
        }
        
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline { // if polyine
            let renderer = MKPolylineRenderer(overlay: overlay) // set renderer to polyline
            renderer.strokeColor = .blue // set color of line to blue
            renderer.lineWidth = 10 // set width
            return renderer // return renderer
        }
        if overlay is MKCircle { // if at the geolocation
            let renderer = MKCircleRenderer(overlay: overlay) // create renderer
            renderer.strokeColor = .blue
            renderer.fillColor = .blue
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
