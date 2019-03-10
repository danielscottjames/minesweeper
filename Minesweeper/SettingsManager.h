//
//  LevelManager.h
//  Reaction
//
//  Created by Daniel James on 1/20/14.
//  Copyright (c) 2014 Daniel James. All rights reserved.
//

#import <GameKit/GameKit.h>


typedef NS_ENUM(NSInteger, DifficultyLevel) {
    DifficultyLevelBeginner,DifficultyLevelEasy,DifficultyLevelMedium,DifficultyLevelHard,DifficultyLevelCustom
};

@interface SettingsManager : NSObject {
}

+ (SettingsManager *)sharedInstance;

- (void) setupSettings;
- (void) gameOver:(BOOL)won;


- (void) reportHighScore:(NSInteger)highScore;
- (NSString *) getIdentifierForCurrentDifficultyLevel;
- (DifficultyLevel) getCurrentDifficultyLevel;

- (void) setLevelSizeToWidth:(NSInteger)width height:(NSInteger)height andMines:(NSInteger)mines;

- (BOOL) shouldVibrate;
- (BOOL) shouldPlaySound;
- (void) setShouldVibrate:(BOOL)shouldVibrate;
- (void) setShouldPlaySound:(BOOL)shouldPlaySound;
- (void) set3DTouchEnabled:(BOOL)enabled;
- (void) set3DTouchSensitivity:(float)sensitivity;
- (void) setHoldDuration:(float)duration;
- (NSInteger) getWidth;
- (NSInteger) getHeight;
- (NSInteger) getMines;
- (BOOL) get3DTouchCapabilityAvailable;
- (BOOL) get3DTouchEnabled;
- (float) get3DTouchSensitivity;
- (float) getHoldDuration;

@end