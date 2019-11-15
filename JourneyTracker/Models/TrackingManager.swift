//
//  TrackingManager.swift
//  JourneyTracker
//
//  Created by Aidan Haley on 14/11/2019.
//  Copyright © 2019 Aidan Haley. All rights reserved.
//

import Foundation

class TrackingManager {
    static let sharedInstance = TrackingManager()
    
    var trackingEnabled = Bool()
    var Locations = [Location]()
}
