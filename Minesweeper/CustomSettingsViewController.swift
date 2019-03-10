//
//  CustomSettingsViewController.swift
//  Minesweeper
//
//  Created by Daniel James on 5/31/15.
//  Copyright (c) 2015 developersBliss. All rights reserved.
//

import UIKit

class CustomSettingsViewController: UITableViewController {
    
    let minMines = 10
    var maxMines: Int = 226
    
    var boardWidth = 14
    var boardHeight = 16
    var mines: Float = 0.14
    
    var minesCount: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardWidth = SettingsManager.sharedInstance().getWidth()
        boardHeight = SettingsManager.sharedInstance().getHeight()
        minesCount = SettingsManager.sharedInstance().getMines()
        
        mines = Float(minesCount)/Float(boardWidth*boardHeight)
        
        widthSlider.setValue(Float(boardWidth), animated: false)
        heightSlider.setValue(Float(boardHeight), animated: false)
        minesSlider.setValue(mines, animated: false)

        updateLabels()
    }

    deinit {        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MinesweeperDifficultyChanged"), object:nil)
    }
    
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var minesLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var minesSlider: UISlider!
    
    @IBAction func widthSliderChanged(_ sender: UISlider) {
        boardWidth = Int(sender.value);
        updateLabels();
    }
    
    
    @IBAction func heightSliderChanged(_ sender: UISlider) {
        boardHeight = Int(sender.value);
        updateLabels();
    }
    
    
    @IBAction func minesSliderChanged(_ sender: UISlider) {
        mines = sender.value;
        updateLabels();
    }
    
    func updateLabels() {
        widthLabel.text = "\(boardWidth)"
        heightLabel.text = "\(boardHeight)"
        
        minesCount = Int(Float(boardWidth*boardHeight)*mines)
        
        minesLabel.text = "\(minesCount)"
        
        
        if (mines < 0.105) {
            difficultyLabel.text = "Very Easy"
        } else if (mines < 0.133) {
            difficultyLabel.text = "Similar to Beginner"
        } else if (mines < 0.149) {
            difficultyLabel.text = "Similar to Easy"
        } else if (mines < 0.178) {
            difficultyLabel.text = "Similar to Medium"
        } else if (mines < 0.246) {
            difficultyLabel.text = "Similar to Hard"
        } else {
            difficultyLabel.text = "Very Hard"
        }
        
        // Update current level:
        SettingsManager.sharedInstance().setLevelSizeToWidth(boardWidth, height: boardHeight, andMines: minesCount);
    }

}
