//
//  TrackingViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/29/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import Foundation

class TrackingViewController: UIViewController {

    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
        
        var newLatitude = CLLocationDegrees()
        var newLongitude = CLLocationDegrees()
        
        var carAddress = String()
        
        var carLatitude = CLLocationDegrees()
        var carLongitude = CLLocationDegrees()
        
        var patLatitude = CLLocationDegrees()
        var patLongitude = CLLocationDegrees()
        
        let locationManager = CLLocationManager()
        var currentCoordinate: CLLocationCoordinate2D! // stores current location
        
        let carPoint = MKPointAnnotation() // annotations for caregiver pin
        let patPoint = MKPointAnnotation() // annotation for patient pin
        
        var steps = [MKRouteStep]() // initialize array of the steps for directions
        let speechSynthesizer = AVSpeechSynthesizer() // add speech for directions
        
        var stepCounter = 0
        
        var timer = Timer()
        var timer_2 = Timer()
        var backgroundTask = BackgroundTask()
        
        var geocoder = CLGeocoder()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            
            //function to start the background tasks
            startBackgroundTask()
            //gets the main location
            getMainLocation(patPhone: "12345")
        }
        
        func startBackgroundTask() { // this function is getting called in the background so it works even if the app is not running
            backgroundTask.startBackgroundTask()
            // this timer is used to call the functions multiple times so the location keeps getting pushed to the data base
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.pushLocation), userInfo: nil, repeats: true)
            timer_2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.addAnnotation), userInfo: nil, repeats: true)
        }
        
        @objc func pushLocation() {
            sendLocation(pat_phone:"12345", pat_password:"xyz",latitude:"\(newLatitude)",longitude:"\(newLongitude)")
            print("pushing location")
        }
        
        func carAnnotations() {
            self.mapView.removeAnnotation(carPoint)
            carPoint.coordinate = CLLocationCoordinate2D(latitude: carLatitude, longitude: carLongitude)
            mapView.addAnnotation(carPoint)
        }
        
        @objc func addAnnotation() {
            carAnnotations()
            getPatLocation(carePhone: "67890") // get the patient location
            self.mapView.removeAnnotation(patPoint) // remove previous annotation
            patPoint.coordinate = CLLocationCoordinate2D(latitude: patLatitude, longitude: patLongitude) // set updated coordinates to annotation
            mapView.addAnnotation(patPoint) // display it on the map
        }
        
        func getDirections(to destination: MKMapItem) {
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
                
                self.mapView.add(primaryRoute.polyline) // add the polyine( directions ) to the map
                //loop through and remove each region so we can search again, does not double up
                self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
                
                self.steps = primaryRoute.steps // save the steps of the primary route
                for i in 0 ..< primaryRoute.steps.count { // for the amount of steps
                    let step = primaryRoute.steps[i] // assign the ith steph
                    //print(step.instructions) // print step
                    //print(step.distance) // print distance
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
        
        func sendLocation(pat_phone:String, pat_password:String, latitude:String, longitude:String) {
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache",
                "Postman-Token": "9b30f413-1c02-4775-5a30-a95241dce10e"
            ]
            let parameters = [
                "pat_phone": pat_phone,
                "password": pat_password,
                "pat_addr_lat": latitude,
                "pat_addr_lon": longitude
                ] as [String : Any]
            
            let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/pat_gps")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                }
            })
            dataTask.resume()
        }
        
        func getPatLocation(carePhone:String) {
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache",
                "Postman-Token": "824018c5-2cbe-63e8-aada-4acb16422427"
            ]
            
            let getUrl = "http://54.175.126.168:3000/pat_gps/" + carePhone
            
            let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                    guard let ret_data = data, error == nil else { return }
                    do{
                        if let jsonObject = try! JSONSerialization.jsonObject(with: Data(ret_data), options: [.allowFragments]) as? [String:Any] {
                            print("printing json Object")
                            print(jsonObject)
                            if let nestedArray = jsonObject["message"] as? NSArray {
                                print(nestedArray)
                                let newDoc = nestedArray[0] as? [String:Any]
                                let pat_addr_lat = newDoc?["pat_addr_lat"] as! String
                                let pat_addr_lon = newDoc?["pat_addr_lon"] as! String
                                self.patLatitude = Double(pat_addr_lat)!
                                self.patLongitude = Double(pat_addr_lon)!
                            }
                            
                        } else {
                            print("Could not parse JSON")
                        }
                    } catch let jsonError {
                        print(jsonError)
                    }
                }
            })
            
            dataTask.resume()
        }
        
        func getMainLocation(patPhone:String) {
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache",
                "Postman-Token": "824018c5-2cbe-63e8-aada-4acb16422427"
            ]
            
            let getUrl = "http://54.175.126.168:3000/home_gps/" + patPhone
            
            let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse!)
                    guard let data = data else { return }
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let JSON = json as? [String: Any]{
                            print(JSON)
                            if let nestedArray = JSON["message"] as? NSArray {
                                let newDoc = nestedArray[0] as? [String:Any]
                                let address = newDoc?["address"] as! String
                                DispatchQueue.main.async { [weak self] in
                                    let geoCoder = CLGeocoder()
                                    geoCoder.geocodeAddressString((address)) { (placemarks, error) in
                                        guard
                                            let placemarks = placemarks,
                                            let location = placemarks.first?.location
                                            else {
                                                // handle no location found
                                                return
                                        }
                                        self?.carLatitude = location.coordinate.latitude
                                        self?.carLongitude = location.coordinate.longitude
                                    }
                                }
                            }
                        }
                    } catch let jsonError {
                        print(jsonError)
                    }
                }
            })
            
            dataTask.resume()
        }
    }
    
    extension TrackingViewController: CLLocationManagerDelegate {
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            manager.stopUpdatingLocation()
            guard let currentLocation = locations.first else { return } // gets the users location
            currentCoordinate = currentLocation.coordinate // sets the current location
            mapView.userTrackingMode = .followWithHeading // zoom into user location and point map in direction your looking
            
            newLatitude = currentLocation.coordinate.latitude
            newLongitude = currentLocation.coordinate.longitude
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
    
    extension TrackingViewController: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true) // dismiss search bar
            let localSearchRequest = MKLocalSearchRequest() // initialize
            localSearchRequest.naturalLanguageQuery = searchBar.text // what they search for is what they query for
            print(localSearchRequest.naturalLanguageQuery)
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
    
    extension TrackingViewController: MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            //print("are we here yet---------------")
            if overlay is MKPolyline { // if polyine
                //print("what bout the polyline---------------")
                let renderer = MKPolylineRenderer(overlay: overlay) // set renderer to polyline
                renderer.strokeColor = .blue // set color of line to blue
                renderer.lineWidth = 10 // set width
                return renderer // return renderer
            }
            if overlay is MKCircle { // if at the geolocation
                //print("what bout the circle---------------")
                let renderer = MKCircleRenderer(overlay: overlay) // create renderer
                renderer.strokeColor = .blue
                renderer.fillColor = .blue
                renderer.alpha = 0.5
                return renderer
            }
            return MKOverlayRenderer()
        }
}
