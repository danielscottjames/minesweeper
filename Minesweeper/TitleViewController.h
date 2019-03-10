//
//  TitleViewController.h
//  Minesweeper
//
//  Created by Daniel James on 6/19/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Minesweeper-Swift.h"

typedef NS_ENUM(NSInteger, SmileyState) {
    SmileyStateNormal,SmileyStateAction,SmileyStateLose,SmileyStateWin
};

@class TitleViewController;
@protocol TitleViewControllerDelegate <NSObject>
- (void) smileyPressed: (TitleViewController *) sender;
@end

@interface TitleViewController : UIViewController <MinesweeperTimerDelegate>
@property (nonatomic, weak) id <TitleViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *bombsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *smileyButton;
@property (nonatomic, assign) SmileyState smileyState;
- (IBAction)buttonPressed:(id)sender;

@property (nonatomic, assign) int bombs;

- (void) resetWithBombs:(int)b;

@end
