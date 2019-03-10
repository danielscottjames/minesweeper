//
//  ViewController.h
//  Minesweeper
//
//  Created by Daniel James on 6/17/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleViewController.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, TitleViewControllerDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *titleView;

- (void) promptNewGame;

@end
