//
//  Square.h
//  Minesweeper
//
//  Created by Daniel James on 6/17/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"

typedef NS_ENUM(NSInteger, SquareState) {
    SquareStateNormal,SquareStateFlagged,SquareStateQuestion,SquareStateRevealed
};

@interface Square : UIView

@property (nonatomic, weak) UIView* parent;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) SquareState state;
@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) float animationDelay;
@property (nonatomic, retain) NSIndexPath *indexPath;
- (void) bounce;
- (void) bounceFlag;
@end
