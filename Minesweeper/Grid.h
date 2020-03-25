//
//  Grid.h
//  Minesweeper
//
//  Created by Daniel James on 6/18/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class MinesweeperGame;

@interface Grid : UIView

@property (nonatomic, retain) ViewController* title;
@property (nonatomic, retain) UIScrollView* scrollView;

@property (nonatomic, strong) NSMutableArray *squares;

- (id) initWithGame:(MinesweeperGame *)game withSize:(UIUserInterfaceSizeClass)size;
- (void) hint;
- (void) undo;

@end
