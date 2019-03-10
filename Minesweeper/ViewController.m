//
//  ViewController.m
//  Minesweeper
//
//  Created by Daniel James on 6/17/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import "ViewController.h"
#import "Grid.h"
#import <GameKit/GameKit.h>
#import "Flurry.h"
#import "SettingsManager.h"
#import "Minesweeper-Swift.h"

@interface ViewController () {
    Grid *_grid;
//    TitleViewController *_title;
    
    MinesweeperGame *_game;
    BOOL _alreadyPaused;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    _title = [[TitleViewController alloc] initWithNibName:@"TitleViewController" bundle:nil];
//    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleView.widthAnchor constraintEqualToConstant:175].active = YES;
    [self.titleView.widthAnchor constraintEqualToConstant:40].active = YES;
//    self.navigationItem.titleView = self.titleView;
//    _title.delegate = self;
    
    //Register for application states
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationWillResignActive:)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(promptNewGame)
                                                name:@"MinesweeperDifficultyChanged"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(newGame)
                                                name:@"NewGame"
                                              object:nil];
}

- (IBAction)smileButtonPressed:(id)sender {
    [SoundManager.sharedInstance playSoundEffect:SoundEffectSelect];
    [self promptNewGame];
}

- (void) dealloc {
    //Resign form NSNotifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MinesweeperDifficultyChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewGame" object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    if (!_grid) {
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(setInsets)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        [self authenticateLocalPlayer];
        [self newGame];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"View will disappear.");
    [super viewWillDisappear:animated];
    
    _game.isPaused = true;
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View will appear.");
    [super viewWillAppear:animated];
    
    _game.isPaused = false;
}

- (void) applicationDidBecomeActive: (id) sender {
    NSLog(@"Application became active.");
    if (!_alreadyPaused) {
        _game.isPaused = NO;
    }
}

- (void) applicationWillResignActive: (id) sender {
    NSLog(@"Application will resign active.");
    if (_game.isPaused) {
        _alreadyPaused = YES;
    } else {
        _alreadyPaused = NO;
        _game.isPaused = YES;
    }
}

- (void) viewDidLayoutSubviews {
    [self setInsets];
    [self.scrollView setNeedsDisplay];
    [self.scrollView setNeedsLayout];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(void)authenticateLocalPlayer{
//    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
//
//    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
//        if (viewController != nil) {
//            [self presentViewController:viewController animated:YES completion:nil];
//        } else {
//            if ([localPlayer.alias isEqualToString:@"achilli78"]) {
//                if ([GKLocalPlayer localPlayer].isAuthenticated) {
//                    GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:@"DifficultyLevelHard"];
//                    score.value = 103;
//                    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
//                        if (error) {
//                            NSLog(@"Error Reporting Custom Score %@", error);
//                            // handle error
//                        }
//                    }];
//                }
//            }
//        }
//    };
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _grid;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setInsets];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setInsets];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    scale *= [[UIScreen mainScreen] scale];
    scrollView.contentScaleFactor = scale;
    _grid.contentScaleFactor = scale;
    [self setInsets];
}

- (void) smileyPressed:(TitleViewController *)sender {
    [self promptNewGame];
}

- (void) newGame {
    if (_game != nil) {
        _game.state = GameStateFinished;
        _game = nil;
    }
    
    DifficultyLevel difficultyLevel = [[SettingsManager sharedInstance] getCurrentDifficultyLevel];
    NSInteger width = [[SettingsManager sharedInstance] getWidth];
    NSInteger height = [[SettingsManager sharedInstance] getHeight];
    NSInteger mines = [[SettingsManager sharedInstance] getMines];
    
    [Flurry logEvent:[NSString stringWithFormat:@"New_Game_%ld", (long)difficultyLevel]];
    _game = [[MinesweeperGame alloc] initWithDifficulty:difficultyLevel withWidth:width withHeight:height withMines:mines];
    
    if (_grid) {
        [_grid removeFromSuperview];
    }
    
    
    
    CGSize size = self.scrollView.frame.size;
    size.height = size.height - (self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    
    _grid = [[Grid alloc] initWithGame:_game withSize:self.traitCollection.horizontalSizeClass];
//    _grid.title = _title;
//    [_title resetWithBombs:(int)_game.mines];
//    _game.timerDelegate = _title;
    
    self.scrollView.contentSize = _grid.frame.size;
    [self setInsets];
    [self.scrollView addSubview:_grid];
}

- (void) setInsets {
    CGSize size = self.scrollView.frame.size;
    size.height = size.height - (self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    
    float paddingX, paddingY;
    if (_grid.frame.size.width > size.width) {
        paddingX = 8;
    } else {
        paddingX = (size.width - _grid.frame.size.width)/2.0;
    }
    if (_grid.frame.size.height > size.height) {
        paddingY = 8;
    } else {
        paddingY = (size.height - _grid.frame.size.height)/2.0;
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(paddingY + self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, paddingX, paddingY, paddingX);
}

- (void) promptNewGame {
    if (_game.state == GameStatePlaying) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Game?"
                                                        message:@"Would you like to start a new game and quit the current one?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
        _game.isPaused = true;
    } else {
        [self newGame];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _game.isPaused = false;
    if (buttonIndex == 1) {
        [self newGame];
    }
}

@end
