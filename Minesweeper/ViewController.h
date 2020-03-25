//
//  ViewController.h
//  Minesweeper
//
//  Created by Daniel James on 6/17/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Minesweeper-Swift.h"

typedef NS_ENUM(NSInteger, SmileyState) {
    SmileyStateNormal,SmileyStateAction,SmileyStateLose,SmileyStateWin
};

@interface ViewController : UIViewController <UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, MinesweeperTimerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *bombsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *bombsLabelBackground;
@property (weak, nonatomic) IBOutlet UILabel *timerLabelBackground;
@property (weak, nonatomic) IBOutlet UIButton *smileyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hintButton;

@property (nonatomic, assign) SmileyState smileyState;
@property (nonatomic, assign) int bombs;

- (void) resetWithBombs:(int)b;

- (void) promptNewGame;

@end
