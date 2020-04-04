//
//  AdvancedSettingsTableViewController.swift
//  Minesweeper
//
//  Created by Daniel James on 3/28/20.
//  Copyright © 2020 danieljames. All rights reserved.
//

import UIKit

class AdvancedSettingsTableViewController: UITableViewController {
    @IBOutlet weak var _luck: UISwitch!
    @IBOutlet weak var _emptyFirstTap: UISwitch!
    @IBOutlet weak var _questionMarks: UISwitch!
    @IBOutlet weak var _randomHints: UISwitch!
    
    var settingsChanged = false;
    
    @IBOutlet var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _luck.setOn(SettingsManager.sharedInstance().getLuckEnabled(), animated: false)
        _emptyFirstTap.setOn(SettingsManager.sharedInstance().getEmptyFirstTapEnabled(), animated: false)
        _questionMarks.setOn(SettingsManager.sharedInstance().getQuestionMarksEnabled(), animated: false)
        _randomHints.setOn(SettingsManager.sharedInstance().getRandomHintsEnabled(), animated: false)
    }
    
    deinit {
        if (settingsChanged == true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MinesweeperDifficultyChanged"), object:nil)
        }
    }
    
    @IBAction func _SwitchChanged(_ sender: UISwitch) {
        settingsChanged = true
        
        if (sender.isEqual(_luck)) {
            SettingsManager.sharedInstance()?.setLuckEnabled(_luck.isOn)
        }
        if (sender.isEqual(_emptyFirstTap)) {
            SettingsManager.sharedInstance()?.setEmptyFirstTapEnabled(_emptyFirstTap.isOn)
        }
        if (sender.isEqual(_questionMarks)) {
            SettingsManager.sharedInstance()?.setQuestionMarksEnabled(_questionMarks.isOn)
        }
        if (sender.isEqual(_randomHints)) {
            SettingsManager.sharedInstance()?.setRandomHintsEnabled(_randomHints.isOn)
        }
    }
}
