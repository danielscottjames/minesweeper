//
//  TitleViewController.m
//  Minesweeper
//
//  Created by Daniel James on 6/19/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import "TitleViewController.h"

@interface TitleViewController () {
    NSTimer *_timer;
}

@end

@implementation TitleViewController

//- (CGSize )intrinsicContentSize {
//    return UILayoutFittingExpandedSize;
//}

- (void) resetWithBombs:(int)b {
    self.time = 0;
    self.bombs = b;
    self.smileyState = SmileyStateNormal;
}

- (void) setBombs:(int)bombs {
    _bombs = bombs;
    
    if (self.bombs < -9) {
        self.bombsLabel.text = [NSString stringWithFormat:@"-%d", -self.bombs];
    } else if (self.bombs < 0) {
        self.bombsLabel.text = [NSString stringWithFormat:@"-0%d", -self.bombs];
    } else if (self.bombs < 10) {
        self.bombsLabel.text = [NSString stringWithFormat:@"00%d", self.bombs];
    } else if (self.bombs < 100) {
        self.bombsLabel.text = [NSString stringWithFormat:@"0%d", self.bombs];
    } else {
        self.bombsLabel.text = [NSString stringWithFormat:@"%d", self.bombs];
    }
}

- (void) timeChangedWithTime:(NSInteger)time {
    [self setTime:time];
}

- (void) setTime:(NSInteger)time {
    if (time > 999) {
        time = 999;
    }
    
    if (time < 10) {
        self.timerLabel.text = [NSString stringWithFormat:@"00%ld", (long)time];
    } else if (time < 100) {
        self.timerLabel.text = [NSString stringWithFormat:@"0%ld", (long)time];
    } else if (time <= 999) {
        self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)time];
    }
}

- (void) setSmileyState:(SmileyState)smileyState {
    _smileyState = smileyState;
    
    switch (self.smileyState) {
        case SmileyStateAction:
            self.smileyButton.titleLabel.text = @"😮";
            break;
        case SmileyStateLose:
            self.smileyButton.titleLabel.text = @"😵";
            break;
        case SmileyStateWin:
            self.smileyButton.titleLabel.text = @"😎";
            break;
            
        case SmileyStateNormal:
        default:
            self.smileyButton.titleLabel.text = @"😀";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    [self.delegate smileyPressed:self];
}
@end
