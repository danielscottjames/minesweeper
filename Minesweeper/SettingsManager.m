//
//  LevelManager.m
//  Reaction
//
//  Created by Daniel James on 1/20/14.
//  Copyright (c) 2014 Daniel James. All rights reserved.
//

#import "SettingsManager.h"
#import <AudioToolbox/AudioServices.h>
#import "Minesweeper-Swift.h"

@interface SettingsManager () {
    MinesweeperGame *_game;
}
@end

@implementation SettingsManager
+ (SettingsManager *) sharedInstance {
    static SettingsManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init {
	self = [super init];
	if (self != nil) {
	}
    
	return self;
}

- (void) settingsChanged {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MinesweeperSettingsChanged"
     object:nil ];
}

- (void) setupSettings {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibrate"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundEffects"];
    
    // Controls
    [[NSUserDefaults standardUserDefaults] setBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"3DTouchCapabilityAvailable"] forKey:@"3DTouchEnabled"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.66 forKey:@"3DTouchSensitivity"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.15 forKey:@"HoldDuration"];
    
    // Easy mode by default
    [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:@"width"];
    [[NSUserDefaults standardUserDefaults] setInteger:14 forKey:@"height"];
    [[NSUserDefaults standardUserDefaults] setInteger:18 forKey:@"mines"];
    
    // Stats
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"wins"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"loses"];
    
    // Advanced Settings
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"luck"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"emptyFirstTap"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"questionMarks"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"randomHints"];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self giveInstructions];
}

- (void) resetupSettings {
    // Advanced Settings
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"luck"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"emptyFirstTap"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"questionMarks"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"randomHints"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) getLuckEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"luck"];
}

- (BOOL) getEmptyFirstTapEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"emptyFirstTap"];
}

- (BOOL) getQuestionMarksEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"questionMarks"];
}

- (BOOL) getRandomHintsEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"randomHints"];
}

- (void) setLuckEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"luck"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setEmptyFirstTapEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"emptyFirstTap"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setQuestionMarksEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"questionMarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setRandomHintsEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"randomHints"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) set3DTouchEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"3DTouchEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}

- (void) set3DTouchSensitivity:(float)sensitivity {
    [[NSUserDefaults standardUserDefaults] setFloat:sensitivity forKey:@"3DTouchSensitivity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}

- (void) setHoldDuration:(float)duration {
    [[NSUserDefaults standardUserDefaults] setFloat:duration forKey:@"HoldDuration"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}

- (BOOL) get3DTouchCapabilityAvailable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"3DTouchCapabilityAvailable"];
}

- (BOOL) get3DTouchEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"3DTouchEnabled"];
}

- (float) get3DTouchSensitivity {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"3DTouchSensitivity"];
}

- (float) getHoldDuration {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"HoldDuration"];
}

- (void) gameOver:(BOOL)won {
    if (won) {
        NSInteger wins = [[NSUserDefaults standardUserDefaults] integerForKey:@"wins"];
        [[NSUserDefaults standardUserDefaults] setInteger:++wins forKey:@"wins"];
        
        if (wins == 2) {
            [self promptReview];
        }
    } else {
        NSInteger wins = [[NSUserDefaults standardUserDefaults] integerForKey:@"loses"];
        [[NSUserDefaults standardUserDefaults] setInteger:++wins forKey:@"loses"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) shouldVibrate {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"vibrate"]) {
        return true;
    }
    
    return false;
}

- (BOOL) shouldPlaySound {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"soundEffects"]) {
        return true;
    }
    
    return false;
}

- (void) setShouldVibrate:(BOOL)shouldVibrate {
    [[NSUserDefaults standardUserDefaults] setBool:shouldVibrate forKey:@"vibrate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}

- (void) setShouldPlaySound:(BOOL)shouldPlaySound {
    [[NSUserDefaults standardUserDefaults] setBool:shouldPlaySound forKey:@"soundEffects"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}


- (void) setLevelSizeToWidth:(NSInteger)width height:(NSInteger)height andMines:(NSInteger)mines {
    [[NSUserDefaults standardUserDefaults] setInteger:width forKey:@"width"];
    [[NSUserDefaults standardUserDefaults] setInteger:height forKey:@"height"];
    [[NSUserDefaults standardUserDefaults] setInteger:mines forKey:@"mines"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self settingsChanged];
}

- (NSInteger) getWidth {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"width"];
}

- (NSInteger) getHeight {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"height"];
}

- (NSInteger) getMines {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"mines"];
}

- (NSString *) getIdentifierForCurrentDifficultyLevel {
    return [self getIdentifierForDifficultyLevel:[self getCurrentDifficultyLevel]];
}

- (NSString *) getIdentifierForDifficultyLevel:(DifficultyLevel)difficultyLevel {
    NSString *identifier;
    
    switch (difficultyLevel) {
        case DifficultyLevelBeginner:
            identifier = @"DifficultyLevelBeginner";
            break;
        case DifficultyLevelEasy:
            identifier = @"DifficultyLevelEasy";
            break;
        case DifficultyLevelMedium:
            identifier = @"DifficultyLevelMedium";
            break;
        case DifficultyLevelHard:
            identifier = @"DifficultyLevelHard";
            break;
        case DifficultyLevelCustom:
            identifier = @"DifficultyLevelCustom";
            break;
    }
    
    return identifier;
}

- (DifficultyLevel) getCurrentDifficultyLevel {
    NSInteger width = [self getWidth];
    NSInteger height = [self getHeight];
    NSInteger mines = [self getMines];
    
    if (width == 9 && height == 9 && mines == 10) {
        return DifficultyLevelBeginner;
    } else if (width == 9 && height == 14 && mines == 18) {
        return DifficultyLevelEasy;
    } else if (width == 16 && height == 16 && mines == 40) {
        return DifficultyLevelMedium;
    } else if (width == 16 && height == 30 && mines == 99) {
        return DifficultyLevelHard;
    }
    
    return DifficultyLevelCustom;
}


- (void) reportHighScore:(NSInteger)highScore {
    if ([self getCurrentDifficultyLevel] == DifficultyLevelCustom) {
        // Don't report custom games
        NSLog(@"Custom Game not reporting score.");
        return;
    }
    
    NSString *identifier = [self getIdentifierForDifficultyLevel:[self getCurrentDifficultyLevel]];
    NSLog(@"Identifier: %@\tScore: %ld", identifier, (long)highScore);
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore* score = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        score.value = highScore;
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error Reporting Score %@", error);
                // handle error
            }
        }];
    }
}

- (void) giveInstructions {
    NSString *message;
    if ([self get3DTouchEnabled]) {
        message = @"Tap to reveal a square.\nPress firmly to flag.\nPress the smiley button for new game.\n\nYou may disable 3D touch in the menu.";
    } else {
        message = @"Tap to reveal a square.\nHold to flag.\nPress the smiley button for new game.";
    }
    
    // Instructions...
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (void) promptReview {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enjoy This Game?"
                                                    message:@"Would you please take a moment to rate this game? This message will not be displayed again."
                                                   delegate:self
                                          cancelButtonTitle:@"No Thanks"
                                          otherButtonTitles:@"Sure!", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasReviewed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *iOS7AppStoreURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", APP_ID];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOS7AppStoreURL] options:@{} completionHandler:nil];
    }
}

@end
