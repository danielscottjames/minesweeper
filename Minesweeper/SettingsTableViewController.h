//
//  SettingsTableViewController.h
//  Minesweeper
//
//  Created by Daniel James on 6/20/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface SettingsTableViewController : UITableViewController <GKGameCenterControllerDelegate>
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *difficultyCells;

@property (weak, nonatomic) IBOutlet UITableViewCell *soundEffectsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *vibrateCell;
- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *customDifficultyLabel;

@end
