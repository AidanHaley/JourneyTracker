//
//  JourneyViewController.swift
//  JourneyTracker
//
//  Created by Aidan Haley on 13/11/2019.
//  Copyright © 2019 Aidan Haley. All rights reserved.
//

import UIKit
import CoreData

class JourneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    //Outlets
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Vars
    private let persistentContainer = NSPersistentContainer(name: "JourneyTracker")
    
    var journeys = [Journey]() {
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

        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")

            } else {
                self.configureView()

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
            cell.timestampLabel.text = journey.timestamp?.description
            cell.durationLabel.text = journey.duration.description

           return cell
    }
    
    private func configureView() {
        updateView()
    }
    
    private func updateView() {
        var hasJourneys = false

        if let journeys = fetchedResultsController.fetchedObjects {
            hasJourneys = journeys.count > 0
        }

        tableView.isHidden = !hasJourneys
        messageLabel.isHidden = hasJourneys

        activityIndicator.stopAnimating()
    }
    
}
