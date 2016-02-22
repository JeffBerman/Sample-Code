//
//  CharadesGameViewController.swift
//  Charades
//
//  Created by Jeff on 8/16/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation


struct Constants {
    static let timeToDisplayQuestionResult = 1.5
    static let timeToDisplayTimesUpMessage = 3.0
    static let questionBGColor = UIColor(red: 4.0/255, green: 0.0/255, blue: 219.0/255, alpha: 1.0)
    static let resultCorrectColor = UIColor(red: 0.0/255, green: 153.0/255, blue: 16.0/255, alpha: 1.0)
    static let resultPassColor = UIColor(red: 210.0/255, green: 0.0/255.0, blue: 14.0/255.0, alpha: 1.0)
    static let timesUpColor = Constants.questionBGColor
}

class CharadesGameViewController: UIViewController {

    @IBOutlet weak var questionDisplay: UILabel!
    @IBOutlet weak var steadyScreenLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
    }
    
    enum questionResult {
        case Correct
        case Pass
    }
   
    var game = CharadesGame()
    var selectedCategories: [String]? { // Populated by game launcher to hand off to game model
        didSet {
            game.categoryFilter = selectedCategories
        }
    }
    
    var allowAnswering = true
    var previousOrientation: UIDeviceOrientation = UIDeviceOrientation.Unknown
    let maxGameTime = NSUserDefaults.standardUserDefaults().integerForKey(SettingsConstants.gameDurationKey) // Duration of game
    var time = 0 {  // Game time remaining
        didSet {
            timerLabel.text = "\(time)"
        }
    }
    var timer = NSTimer()
    var correctGuessSound: AVAudioPlayer?
    var passSound: AVAudioPlayer?
    var gameOverSound: AVAudioPlayer?
    var timesUpSound: AVAudioPlayer?
    var countdownBeepSound: AVAudioPlayer?
    var getReadyTimer = NSTimer()
    var getReadyTime = 0
    
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let soundURL = NSBundle.mainBundle().URLForResource("correct guess", withExtension: "mp3") {
            correctGuessSound = try? AVAudioPlayer(contentsOfURL: soundURL)
        }
        if let soundURL = NSBundle.mainBundle().URLForResource("pass", withExtension: "mp3") {
            passSound = try? AVAudioPlayer(contentsOfURL: soundURL)
        }
        if let soundURL = NSBundle.mainBundle().URLForResource("applause", withExtension: "m4a") {
            gameOverSound = try? AVAudioPlayer(contentsOfURL: soundURL)
        }
        if let soundURL = NSBundle.mainBundle().URLForResource("time's up", withExtension: "mp3") {
            timesUpSound = try? AVAudioPlayer(contentsOfURL: soundURL)
        }
        if let soundURL = NSBundle.mainBundle().URLForResource("beep", withExtension: "m4a") {
            countdownBeepSound = try? AVAudioPlayer(contentsOfURL: soundURL)
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        questionDisplay.text = ""
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        questionDisplay.text = "GET READY!"
        timerLabel.hidden = true
        categoryLabel.text = ""
        steadyScreenLabel.hidden = true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startGetReady()
        startOrientationDetection()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        endOrientationDetection()
        if timer.valid { timer.invalidate() }
        if getReadyTimer.valid { getReadyTimer.invalidate() }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:
    
    // The actual start of a new game.  Called when "get ready" countdown timer reaches zero.
    func startGame() {
        time = maxGameTime
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countdown:", userInfo: nil, repeats: true)
        timerLabel.hidden = false
        categoryLabel.superview!.hidden = false
        steadyScreenLabel.hidden = true
        previousOrientation = UIDevice.currentDevice().orientation
        
        // Show first question
        displayNextQuestion()
    }
    
    
    // Entry point to a game -- does the "Get Ready" countdown and then kicks off the questions
    func startGetReady() {
        time = 5
        questionDisplay.text = "GET READY!"
        timerLabel.hidden = true
        categoryLabel.superview!.hidden = true
        allowAnswering = false
        
        let countdownLabel = UILabel()
        countdownLabel.textColor = UIColor.whiteColor()
        countdownLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 420.0)
        countdownLabel.text = "\(time)"
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(countdownLabel)
        self.view.addConstraint(NSLayoutConstraint(item: countdownLabel, attribute: .CenterX, relatedBy: .Equal, toItem: countdownLabel.superview, attribute: .CenterX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: countdownLabel, attribute: .CenterY, relatedBy: .Equal, toItem: countdownLabel.superview, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        countdownLabel.transform = CGAffineTransformMakeScale(3.0, 3.0)
        countdownLabel.alpha = 1.0
        UIView.animateWithDuration(NSTimeInterval(0.75), delay: NSTimeInterval(0), options: UIViewAnimationOptions.CurveLinear, animations: {
            countdownLabel.transform = CGAffineTransformMakeScale(0.1, 0.1)
            countdownLabel.alpha = 0.0
            }, completion: nil)
        countdownBeepSound?.play()
        getReadyTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "getReady:", userInfo: countdownLabel, repeats: true)
    }
    
    
    // Called by the Get Ready timer
    func getReady(timer: NSTimer) {
        --time
        var countdownLabel: UILabel?
        countdownLabel = timer.userInfo as? UILabel
        countdownLabel?.text = "\(time)"
        
        if time == 0 {
            if timer.valid { timer.invalidate() }
            countdownLabel?.removeFromSuperview()
            startGame()
        } else {
            countdownLabel?.transform = CGAffineTransformMakeScale(3.0, 3.0)
            countdownLabel?.alpha = 1.0
            UIView.animateWithDuration(NSTimeInterval(0.75), delay: NSTimeInterval(0), options: UIViewAnimationOptions.CurveLinear, animations: {
                countdownLabel?.transform = CGAffineTransformMakeScale(0.1, 0.1)
                countdownLabel?.alpha = 0.0
            }, completion: nil)
            countdownBeepSound?.play()
        }
    }

    
    // Displays the next question
    func displayNextQuestion() {
        allowAnswering = true
        view.backgroundColor = Constants.questionBGColor
        questionDisplay.textColor = UIColor.whiteColor()
        if let question = game.nextQuestion() {
            questionDisplay.text = question.text
            categoryLabel.text = question.category
            categoryLabel.superview!.setNeedsLayout()
            categoryLabel.superview!.layoutIfNeeded()
            categoryLabel.superview!.layer.cornerRadius = categoryLabel.superview!.bounds.height / 2.0
            let orientation = UIDevice.currentDevice().orientation
            if orientation != .LandscapeLeft && orientation != .LandscapeRight {
                steadyScreenLabel.hidden = false
            }
        } else {
            questionDisplay.text = nil
            gameOver()
        }
    }
    
    // Called whenever device orientation changes.  Determines if user is answering a question or if the phone
    // erroneously tilted.
    func orientationChanged(notification: NSNotification) {
        print("Orientation notification received")
        let orientation = UIDevice.currentDevice().orientation
        
        if orientation != .LandscapeLeft && orientation != .LandscapeRight {
            steadyScreenLabel.hidden = false
        } else {
            steadyScreenLabel.hidden = true
        }
        
        if previousOrientation == .LandscapeLeft || previousOrientation == .LandscapeRight {
            if orientation == .FaceUp {
                answeredCorrectly()
                steadyScreenLabel.hidden = true
            }
            
            if orientation == .FaceDown {
                passed()
                steadyScreenLabel.hidden = true
            }
        }
        
        previousOrientation = orientation
    }


    // Temporary code to facilitate testing
    @IBAction func answerQuestion(sender: UIButton) {
        if let answer = sender.currentTitle {
            if answer == "Pass" {
                passed()
            } else {
                answeredCorrectly()
            }
        }
    }
    
    
    // Tapping the screen hides/reveals the navigation bar
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        if let hidden = navigationController?.navigationBar.hidden {
            navigationController?.setNavigationBarHidden(!hidden, animated: true)
        }
    }
    
    
    // Player got the question right
    func answeredCorrectly() {
        if allowAnswering {
            game.updateCurrentQuestion(guessed: true)
            correctGuessSound?.play()
            displayAnswerFeedback(questionResult.Correct)
        }
    }

    
    // Player passed on the question
    func passed() {
        if allowAnswering {
            game.updateCurrentQuestion(guessed: false)
            passSound?.play()
            displayAnswerFeedback(questionResult.Pass)
        }
    }
    
    
    // Display "Pass" or "Correct"
    func displayAnswerFeedback(result: questionResult) {
        allowAnswering = false
        
        switch result {
        case .Correct:
            view.backgroundColor = Constants.resultCorrectColor
            questionDisplay.text = "CORRECT!"
        case .Pass:
            view.backgroundColor = Constants.resultPassColor
            questionDisplay.text = "PASS"
        }
        
        let delay = Constants.timeToDisplayQuestionResult * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            if self.timer.valid {
                self.displayNextQuestion()
            }
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    // Time is up!
    func timesUp() {
        allowAnswering = false
        view.backgroundColor = Constants.questionBGColor
        questionDisplay.text = "TIME'S UP!"
        let delay = Constants.timeToDisplayTimesUpMessage * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) { self.gameOver() }
        timesUpSound?.play()
        if timer.valid { timer.invalidate() }
    }
    
    
    // Called every second by main game timer
    func countdown(timer: NSTimer) {
        --time
        
        if time == 0 {
            timesUp()
        }
    }

    
    // Show whatever needs to be shown when a game (round?) has ended
    func gameOver() {
        gameOverSound?.play()
        
        // Show score and questions that were answered correctly
        if timer.valid { timer.invalidate() }
        print("Game Over")
        
        performSegueWithIdentifier("GameOverSegue", sender: self)
    }
    
    
    // Start device orientation observing
    func startOrientationDetection() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        print("Orientation notifications ON")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        print("Orientation notifications observed")
    }
    
    
    // End device orientation observing
    func endOrientationDetection() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Orientation notifications not observed")
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        print("Orientation notifications OFF")
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GameOverSegue" {
            if let gameOverVC = segue.destinationViewController as? GameOverViewController {
                gameOverVC.game = game
            }
        }
    }
    
    
    @IBAction func gameOverViewControllerDidUnwind(unwindSegue: UIStoryboardSegue) {
        if unwindSegue.sourceViewController.title == "Game Over" {
            game = CharadesGame()
            game.categoryFilter = selectedCategories
        }
    }

}
