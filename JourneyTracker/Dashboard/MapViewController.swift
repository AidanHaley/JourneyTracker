//
//  ViewController.swift
//  JourneyTracker
//
//  Created by Aidan Haley on 13/11/2019.
//  Copyright © 2019 Aidan Haley. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Vars
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
        
    private var enabled = false
    private var seconds = 0
    private var timer: Timer?
    private var checkTracking: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .fitness
        
        //Assign Delegate
        self.locationManager.delegate = self
        
        //Start timer
        checkTracking = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.tick()
        }
        
        //Configure map
        self.configureMap()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    
        //invalidate timers
        timer?.invalidate()
    }
    
    //MARK: LM Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      for newLocation in locations {
        let howRecent = newLocation.timestamp.timeIntervalSinceNow
        guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

        if let lastLocation = locationList.last {
          let delta = newLocation.distance(from: lastLocation)
          distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            
            //Only draw overlay if tracking enabled
            if TrackingManager.sharedInstance.trackingEnabled == true {
                
            let coordinates = [lastLocation.coordinate, newLocation.coordinate]
            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
            
            let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
                
            } else {
                //otherwise clear drawn routes from map
                self.mapView.removeOverlays(self.mapView.overlays)
            }
            
        }

        locationList.append(newLocation)
      }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer(overlay: overlay)
      }
        
      let renderer = MKPolylineRenderer(polyline: polyline)
      renderer.strokeColor = .blue
      renderer.lineWidth = 5
        
      return renderer
    }
    
    private func configureMap() {
        
        //update location on main thread
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
            //Zoom to user location
            if let userLocation = self.locationManager.location?.coordinate {
                let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
                self.mapView.setRegion(viewRegion, animated: false)
            }
        
        mapView.showsUserLocation = true
    }
    
    func tick() {
        //Check tracking
        if TrackingManager.sharedInstance.trackingEnabled == true {
            //Run once before Enabled set
            if enabled == false {
                self.startJourney()
            }
            
            //set tracking enabled
            self.enabled = true
        } else {
            //Run once before disabled set
            if enabled == true {
                self.stopJourney()
            }

            //Set tracking disbled
            self.enabled = false
        }
    }
    
    func increment() {
        //increment duration
        seconds += 1
    }
    
    func startJourney() {
        //Clear previous journey data
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        mapView.removeOverlays(mapView.overlays)
        
        //Set timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.increment()
        }
    }
    
    func stopJourney() {
        let alertController = UIAlertController(title: "End Journey?",
                                                message: "Do you wish to stop tracking your Journey?",
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            
            //Post Refresh notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshNotification"), object: nil)
            }

          self.saveJourney()
        })
        
        present(alertController, animated: true)
    }
    
    private func saveJourney() {
      let newJourney = Journey(context: CoreDataManager.context)
      newJourney.distance = distance.value
      newJourney.duration = Int16(seconds)
      newJourney.timestamp = Date()
              
      for location in locationList {
        let locationObject = Location(context: CoreDataManager.context)
        locationObject.timestamp = location.timestamp
        locationObject.latitude = location.coordinate.latitude
        locationObject.longitude = location.coordinate.longitude
        newJourney.addToLocations(locationObject)
      }
      
      CoreDataManager.saveContext()
    }
    
}


