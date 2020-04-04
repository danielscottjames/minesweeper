//
//  ControlSettingsTableViewController.swift
//  Minesweeper
//
//  Created by Daniel James on 12/28/15.
//  Copyright © 2015 developersBliss. All rights reserved.
//

import UIKit

class ControlSettingsTableViewController: UITableViewController {
    @IBOutlet weak var _3DTouchSwitch: UISwitch!
    @IBOutlet weak var _3DTouchSlider: UISlider!
    @IBOutlet weak var _holdDurationSlider: UISlider!
    
    
    @IBOutlet var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        set3DTouchControlsEnabled(enabled: SettingsManager.sharedInstance().get3DTouchCapabilityAvailable())
        
        _3DTouchSwitch.setOn(SettingsManager.sharedInstance().get3DTouchEnabled(), animated: false)
        _3DTouchSlider.setValue(SettingsManager.sharedInstance().get3DTouchSensitivity(), animated: false)
        _holdDurationSlider.setValue(SettingsManager.sharedInstance().getHoldDuration(), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func set3DTouchControlsEnabled(enabled :Bool) {
        if (enabled) {
            if (SettingsManager.sharedInstance().get3DTouchEnabled()) {
                _3DTouchSlider.isEnabled = true
                _holdDurationSlider.isEnabled = false
            } else {
                _3DTouchSlider.isEnabled = false
                _holdDurationSlider.isEnabled = true
            }
            
            _3DTouchSwitch.isEnabled = true
        } else {
            _3DTouchSlider.isEnabled = false
            _3DTouchSwitch.isEnabled = false
            _holdDurationSlider.isEnabled = true

        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        _tableView.reloadData()
        set3DTouchControlsEnabled(enabled: SettingsManager.sharedInstance().get3DTouchCapabilityAvailable())
    }

    @IBAction func holdDurationSliderChanged(_ sender: AnyObject) {
        SettingsManager.sharedInstance().setHoldDuration(_holdDurationSlider.value)
    }
    @IBAction func _3DTouchSensitivitySliderChanged(_ sender: AnyObject) {
        SettingsManager.sharedInstance().set3DTouchSensitivity(_3DTouchSlider.value)
    }
    @IBAction func _3DTouchSwitchChanged(_ sender: AnyObject) {
        SettingsManager.sharedInstance().set3DTouchEnabled(_3DTouchSwitch.isOn);
        set3DTouchControlsEnabled(enabled: SettingsManager.sharedInstance().get3DTouchCapabilityAvailable())
    }
    
    
    // MARK: - Table view data sourc
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 1 && !SettingsManager.sharedInstance().get3DTouchCapabilityAvailable()) {
            return "3D Touch is not available for your device";
        } else {
            return ""
        }
    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
