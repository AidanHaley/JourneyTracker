//
//  JourneyTableViewCell.swift
//  JourneyTracker
//
//  Created by Aidan Haley on 14/11/2019.
//  Copyright © 2019 Aidan Haley. All rights reserved.
//

import UIKit

class JourneyTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!

    //Vars
    static let reuseIdentifier = "JourneyCell"

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
