//
//  GameLauncherViewController.swift
//  Charades
//
//  Created by Jeff on 9/3/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//

import UIKit
import AVFoundation

struct LauncherConstants {
    static let backgroundMusicLoops = 1
}

class GameLauncherViewController: UIViewController {
    @IBOutlet weak var flippyText: UIImageView!
    @IBOutlet weak var wordsText: UIImageView!

    var selectedCategories: [String]?
    var backgroundMusic: AVAudioPlayer?
    var wordTimer = NSTimer()
    var wordTracker = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let soundURL = NSBundle.mainBundle().URLForResource("snappy_lo", withExtension: "mp3") {
            backgroundMusic = try? AVAudioPlayer(contentsOfURL: soundURL)
            backgroundMusic?.numberOfLoops = LauncherConstants.backgroundMusicLoops
            backgroundMusic?.play()
        }
        
        // Set up game defaults
        if NSUserDefaults.standardUserDefaults().integerForKey(SettingsConstants.gameDurationKey) == 0 {
            NSUserDefaults.standardUserDefaults().setInteger(60, forKey: SettingsConstants.gameDurationKey)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        wordTimer = createFlipTimer()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if wordTimer.valid { wordTimer.invalidate() }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Create timer that controls the title text's flip animations
    func createFlipTimer() -> NSTimer {
        let t = Int(arc4random_uniform(10)) + 5
        let timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(t), target: self, selector: "flipTitleWords:", userInfo: wordTracker, repeats: false)
        return timer
    }
    
    
    // Animate the title text's flipping animation
    func flipTitleWords(timer: NSTimer) {
        print("GameLauncher.flipTitleWords called")
        let image = self.wordTracker == 0 ? self.flippyText : self.wordsText
        UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                image.transform = CGAffineTransformMakeScale(1.0, -1.0)
            },
            completion: { (completion: Bool) in
                UIView.animateWithDuration(0.35, delay: 0.15, options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: {
                        image.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    },
                    completion: { (completion: Bool) in
                        self.wordTimer = self.createFlipTimer()
                })
        })
        
        ++wordTracker
        if wordTracker > 1 { wordTracker = 0 }
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CategoryPickerSegue" {
            backgroundMusic?.stop()
            if wordTimer.valid { wordTimer.invalidate() }
        }
    }
}
