//
//  GameOverTableViewCell.swift
//  Charades
//
//  Created by Jeff on 8/27/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//
//  Used at the end of the game to display the questions that were both guessed correctly and passed over.

import UIKit

class GameOverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftQuestion: UILabel! {
        didSet {
            leftQuestion.text = nil
        }
    }
    @IBOutlet weak var rightQuestion: UILabel! {
        didSet {
            rightQuestion.text = nil
        }
    }
    
    enum Corner { case top, bottom, both }
    
    // Loads and formats cell based on passed-in Question.
    // Position 0 = left part of cell
    // Position 1 = right part of cell
    func loadCellWithQuestion(question: Question, position: Int) {
        if position >= 0 && position <= 1 {
            let label = position == 0 ? leftQuestion : rightQuestion
            label.text = question.text
            label.textColor = question.guessedCorrectly ? Constants.resultCorrectColor : Constants.resultPassColor
        }
    }
    
    
    // Rounds cell corners
    func roundCorners(corner: Corner, radius: CGFloat) {
        var rectCorner: UIRectCorner
        
        switch corner {
        case .top: rectCorner = [UIRectCorner.TopLeft, UIRectCorner.TopRight]
        case .bottom: rectCorner = [UIRectCorner.BottomLeft, UIRectCorner.BottomRight]
        case .both: rectCorner = [UIRectCorner.TopLeft, UIRectCorner.TopRight, UIRectCorner.BottomLeft, UIRectCorner.BottomRight]
        }
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: radius, height: radius)).CGPath
        self.layer.mask = shape
        self.layer.masksToBounds = true
    }
}
