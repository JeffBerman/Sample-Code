//
//  SettingsTableViewController.swift
//  Charades
//
//  Created by Jeff Berman on 10/6/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//

import UIKit

struct SettingsConstants {
    static let gameDurationKey = "gameDuration"
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var gameDurationControl: UISegmentedControl!
    
    var gameDuration = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        navigationController?.navigationBarHidden = false
        let background = UIImageView(image: UIImage(named: "title background"))
        self.tableView.backgroundView = background
        gameDurationControl.layer.cornerRadius = 5.0 // Remove white corners on segmented control
        
        var savedDuration = NSUserDefaults.standardUserDefaults().integerForKey(SettingsConstants.gameDurationKey)
        if savedDuration == 0 { savedDuration = 60 } // Never saved
        
        var savedStatusMatched = false
        for i in 0...gameDurationControl.numberOfSegments-1 {
            if Int(gameDurationControl.titleForSegmentAtIndex(i)!) == savedDuration {
                gameDurationControl.selectedSegmentIndex = i
                savedStatusMatched = true
                break
            }
        }
        if savedStatusMatched == false {
            gameDurationControl.selectedSegmentIndex = 1 // If saved setting doesn't match the control, make a new default
            savedDuration = Int(gameDurationControl.titleForSegmentAtIndex(gameDurationControl.selectedSegmentIndex)!)!
        }
        
        gameDuration = savedDuration
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        // Write out settings when "back" button is pressed.
        if parent == nil {
            NSUserDefaults.standardUserDefaults().setInteger(gameDuration, forKey: SettingsConstants.gameDurationKey)
        }
    }

    @IBAction func gameDurationChanged(sender: UISegmentedControl) {
        gameDuration = Int(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)!)!
    }
    
}
