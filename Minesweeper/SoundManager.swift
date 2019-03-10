//
//  SoundManager.swift
//  Minesweeper
//
//  Created by Daniel James on 12/27/15.
//  Copyright © 2015 developersBliss. All rights reserved.
//

import Foundation
import AudioToolbox

@objc enum SoundEffect :Int {
    case Explosion, Flag, Select
}

@objc final public class SoundManager: NSObject {
    @objc static let sharedInstance = SoundManager()
    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var explosionEffect :SystemSoundID = 0
    var flagEffect :SystemSoundID = 0
    var selectEffect :SystemSoundID = 0
    
    private override init() {
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), "Explosion" as CFString, "caf" as CFString, nil), &explosionEffect);
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), "Flag" as CFString, "caf" as CFString, nil), &flagEffect);
        AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), "Select" as CFString as CFString, "caf" as CFString, nil), &selectEffect);
    }
    
    @objc func playSoundEffect(_ soundEffect :SoundEffect) {
        if (SettingsManager.sharedInstance().shouldPlaySound()) {
            switch soundEffect {
            case .Explosion:
                AudioServicesPlaySystemSound(explosionEffect)
            case .Flag:
                AudioServicesPlaySystemSound(flagEffect)
            case .Select:
                AudioServicesPlaySystemSound(selectEffect)
            }
        }
        if (SettingsManager.sharedInstance().shouldVibrate()) {
            switch soundEffect {
            case .Flag:
                heavyImpact.impactOccurred()
            case .Select:
                lightImpact.impactOccurred()
            case .Explosion:
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
}
