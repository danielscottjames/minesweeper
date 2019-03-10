//
//  SettingsTableViewController.m
//  Minesweeper
//
//  Created by Daniel James on 6/20/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ViewController.h"
#import "SettingsManager.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Organized list of cells.
    self.difficultyCells = [self.difficultyCells sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
    self.popoverPresentationController.backgroundColor = self.tableView.backgroundColor;
}

- (void) viewWillAppear:(BOOL)animated {
    DifficultyLevel difficultyLevel = [[SettingsManager sharedInstance] getCurrentDifficultyLevel];
    
    if (difficultyLevel == DifficultyLevelCustom) {
        self.customDifficultyLabel.text = [NSString stringWithFormat:@"%ldx%ld - %ld Mines",
                                           (long)[[SettingsManager sharedInstance] getWidth],
                                           (long)[[SettingsManager sharedInstance] getHeight],
                                           (long)[[SettingsManager sharedInstance] getMines]];
    } else {
        self.customDifficultyLabel.text = @"--";
    }
    
    // Reset the accessories
    for (UITableViewCell *cell in self.difficultyCells) {
        if (cell == [self.difficultyCells objectAtIndex:DifficultyLevelCustom]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    // Set selected cell to checked.
    ((UITableViewCell *)[self.difficultyCells objectAtIndex:difficultyLevel]).accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case DifficultyLevelBeginner:
                [[SettingsManager sharedInstance] setLevelSizeToWidth:9 height:9 andMines:10];
                break;
            case DifficultyLevelMedium:
                [[SettingsManager sharedInstance] setLevelSizeToWidth:16 height:16 andMines:40];
                break;
            case DifficultyLevelHard:
                [[SettingsManager sharedInstance] setLevelSizeToWidth:16 height:30 andMines:99];
                break;
            case DifficultyLevelEasy:
                [[SettingsManager sharedInstance] setLevelSizeToWidth:9 height:14 andMines:18];
        }
        
        // Reset the accessories
        for (UITableViewCell *cell in self.difficultyCells) {
            if (cell == [self.difficultyCells objectAtIndex:DifficultyLevelCustom]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        // Set selected cell to checked.
        ((UITableViewCell *)[self.difficultyCells objectAtIndex:indexPath.row]).accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (indexPath.row <= 3) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"MinesweeperDifficultyChanged"
             object:nil ];
        }
    }
    
    // Sound section
    if (indexPath.section == 1) {
        BOOL soundEffects = [[SettingsManager sharedInstance] shouldPlaySound];
        BOOL vibrate = [[SettingsManager sharedInstance] shouldVibrate];
        
        if (indexPath.row == 0) {
            soundEffects = !soundEffects;
            self.soundEffectsCell.accessoryType = soundEffects?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
            
            [[SettingsManager sharedInstance] setShouldPlaySound:soundEffects];
        }
        
        if (indexPath.row == 1) {
            vibrate = !vibrate;
            self.vibrateCell.accessoryType = vibrate?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
            
            [[SettingsManager sharedInstance] setShouldVibrate:vibrate];
        }
    }
    
    // Help
    if (indexPath.section == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.danielscottjames.com/minesweeper.html"]];
    }
    
    // Load Game Center
    if (indexPath.section == 3 && indexPath.row == 0) {
        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
        
        gcViewController.gameCenterDelegate = self;
        
        
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = [[SettingsManager sharedInstance] getIdentifierForCurrentDifficultyLevel];
        
        [self presentViewController:gcViewController animated:YES completion:nil];
    }
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) { // Difficulty cells
        DifficultyLevel difficultyLevel = [[SettingsManager sharedInstance] getCurrentDifficultyLevel];
        
        if (indexPath.row == difficultyLevel) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            if (indexPath.row == DifficultyLevelCustom) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
               cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        if (difficultyLevel == indexPath.row && difficultyLevel == DifficultyLevelCustom) {
            self.customDifficultyLabel.text = [NSString stringWithFormat:@"%ldx%ld - %ld Mines",
                                               (long)[[SettingsManager sharedInstance] getWidth],
                                               (long)[[SettingsManager sharedInstance] getHeight],
                                               (long)[[SettingsManager sharedInstance] getMines]];
        } else {
            self.customDifficultyLabel.text = @"--";
        }
    }
    
    if (indexPath.section == 1) { // Sound effects cells
        BOOL soundEffects = [[NSUserDefaults standardUserDefaults] boolForKey:@"soundEffects"];
        BOOL vibrate = [[NSUserDefaults standardUserDefaults] boolForKey:@"vibrate"];
        
        if (indexPath.row == 0) {
            self.soundEffectsCell.accessoryType = soundEffects?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row == 1) {
            self.vibrateCell.accessoryType = vibrate?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}


- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
