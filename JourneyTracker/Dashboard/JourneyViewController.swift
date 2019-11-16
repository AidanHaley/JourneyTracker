//
//  JourneyViewController.swift
//  JourneyTracker
//
//  Created by Aidan Haley on 13/11/2019.
//  Copyright © 2019 Aidan Haley. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class JourneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    //Outlets
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Vars
    private let persistentContainer = NSPersistentContainer(name: "JourneyTracker")
    private let refreshControl = UIRefreshControl()
    private var selectedJourney: Journey?

    private var journeys = [Journey]() {
        didSet {
            updateView()
        }
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Journey> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Journey> = Journey.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Listen for notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(rawValue: "refreshNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetSwitch), name: Notification.Name(rawValue: "resetSwitch"), object: nil)

        // load/fetch tableView data
        self.fetchData()
        
        //Set delegate
        self.mapView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload tableView
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Clear map
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let journey = fetchedResultsController.object(at: indexPath)
        self.selectedJourney = nil
        self.selectedJourney = journey
        
        //load map
        self.mapView.isHidden = false
        self.loadMap()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let journeys = fetchedResultsController.fetchedObjects else { return 0 }

        return journeys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: JourneyTableViewCell.reuseIdentifier, for: indexPath) as? JourneyTableViewCell else {
               fatalError("Unexpected Index Path")
           }

           // Fetch Journey
           let journey = fetchedResultsController.object(at: indexPath)

           // Configure Cell
            cell.nameLabel.text = journey.name
            cell.startTimeLabel.text = journey.timestamp?.description
            cell.endTimeLabel.text = journey.timestamp?.description

           return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
      guard
        let locations = self.selectedJourney!.locations,
        locations.count > 0
      else {
        return nil
      }
        
      let latitudes = locations.map { location -> Double in
        let location = location as! Location
        return location.latitude
      }
        
      let longitudes = locations.map { location -> Double in
        let location = location as! Location
        return location.longitude
      }
        
      let maxLat = latitudes.max()!
      let minLat = latitudes.min()!
      let maxLong = longitudes.max()!
      let minLong = longitudes.min()!
        
      let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                          longitude: (minLong + maxLong) / 2)
      let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                  longitudeDelta: (maxLong - minLong) * 1.3)
      return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> MKPolyline {
        guard let locSet = self.selectedJourney!.locations else {
        return MKPolyline()
      }
        
        //Sort locations by timestamp
        let locations = locSet.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)])
     
      let coords: [CLLocationCoordinate2D] = locations.map { location in
        let location = location as! Location
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      }
      return MKPolyline(coordinates: coords, count: coords.count)
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
    
    private func loadMap() {
      guard
        let locations = self.selectedJourney!.locations,
        locations.count > 0,
        let region = mapRegion()
      else {
          let alert = UIAlertController(title: "Error",
                                        message: "Sorry, this run has no locations saved",
                                        preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .cancel))
          present(alert, animated: true)
          return
      }
        
      mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }
    
    func fetchData() {
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")

            } else {
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }

                self.updateView()
            }
        }
    }
    
    @objc func reloadData() {
        //If refresh control not active
        if refreshControl.isRefreshing == false {
            activityIndicator.startAnimating()
        }
        
        //Fetch data
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        self.refreshControl.endRefreshing()
        activityIndicator.stopAnimating()

        self.updateView()
        self.tableView.reloadData()
    }
    
    @objc func resetSwitch() {
        
        //Set switch to on
        self.trackingSwitch.isOn = true
        
    }
    
    private func updateView() {
        //Updates view when data is loaded
        var hasJourneys = false

        if let journeys = fetchedResultsController.fetchedObjects {
            hasJourneys = journeys.count > 0
        }

        tableView.isHidden = !hasJourneys
        messageLabel.isHidden = hasJourneys

        // Configure Refresh Control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        
        //Set tracking on/off
        if trackingSwitch.isOn == true {
            TrackingManager.sharedInstance.trackingEnabled = true
            
            //Reload tableView
            reloadData()
        } else {
            TrackingManager.sharedInstance.trackingEnabled = false
            
            //Reload tableView
            reloadData()
            }
        
    }
    
}
