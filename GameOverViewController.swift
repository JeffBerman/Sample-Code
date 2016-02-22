//
//  GameOverViewController.swift
//  Charades
//
//  Created by Jeff on 8/26/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//
//
// TODO: Create yellow-rays@3x image

import UIKit

class GameOverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionListTableView: UITableView! {
        didSet {
            questionListTableView.dataSource = self
            questionListTableView.delegate = self
        }
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    
    internal var game: CharadesGame?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate game score from game object.
        // Can't put this in the game property observer because scoreLabel isn't yet hooked up when the game property is set.
        let score = game?.score ?? 0
        scoreLabel.text = "\(score)"
    }
    
    
    override func viewDidAppear(animated: Bool) {
        rotateView(backgroundImage, duration: 60.0, direction: .RotateRight, rotations: 1)
    }
    
    
    // MARK: -
    
    enum JBRotationOptions: Int { case RotateLeft = -1, RotateRight = 1 }
    
    /// Animate the slowly-spinning background image.
    /// `duration` refers to how long the animation will take per rotation, not the total time for all rotations.
    func rotateView(view: UIView, duration: Double, direction: JBRotationOptions, var rotations: Int) {
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: UIViewKeyframeAnimationOptions.CalculationModeLinear.rawValue | UIViewAnimationOptions.CurveLinear.rawValue), animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 2.0 / 3.0 * Double(direction.rawValue)))
            })
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 4.0 / 3.0 * Double(direction.rawValue)))
            })
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                view.transform = CGAffineTransformIdentity
            })
            }, completion: { (finished: Bool) in
                if finished {
                    --rotations
                    if rotations > 0 {
                        self.rotateView(view, duration: duration, direction: direction, rotations: rotations)
                    }
                }
        })
    }
    

    // MARK: - Table view
    
    // Two items per table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let index = row * 2
        let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell") as! GameOverTableViewCell
        
        if let question = game?.playedQuestionAtIndex(index) {
            cell.loadCellWithQuestion(question, position: 0)
        }
        if let question = game?.playedQuestionAtIndex(index+1) {
            cell.loadCellWithQuestion(question, position: 1)
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let playedQuestions = game!.playedQuestions()
        return playedQuestions / 2 + playedQuestions % 2 // Remember, two questions per row.
    }
    
    
    // Properly round the corners of the table view cell, depending on the cell position.  We want the first row to be rounded at the top
    // and the last row to be rounded at the bottom.
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let theCell = cell as! GameOverTableViewCell
        let row = indexPath.row
        let lastRow = self.tableView(tableView, numberOfRowsInSection: 0) - 1
        if lastRow == 0 {
            theCell.roundCorners(GameOverTableViewCell.Corner.both, radius: 5.0)
        } else if row == 0 {
            theCell.roundCorners(GameOverTableViewCell.Corner.top, radius: 5.0)
        } else if row == lastRow {
            theCell.roundCorners(GameOverTableViewCell.Corner.bottom, radius: 5.0)
        }
    }
}
