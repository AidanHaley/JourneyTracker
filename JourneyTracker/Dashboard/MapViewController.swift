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
    
    private var journey: Journey?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        //Configure map
        self.configureMap()
        
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
    
    

}


