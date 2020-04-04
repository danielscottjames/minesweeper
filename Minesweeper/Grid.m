//
//  Grid.m
//  Minesweeper
//
//  Created by Daniel James on 6/18/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import "Grid.h"
#import "Square.h"
#import "SettingsManager.h"
#import "Minesweeper-Swift.h"

@interface Grid () {
    MinesweeperGame *_game;
    
    UIView *_shadowView;
    UIView *_gridView;
    
    NSIndexPath *_delayPath;
    float _animationDelay;
        
    int _squareSize;
    
    UILongPressGestureRecognizer *_longTap;
    
    bool _3DTouch;
    bool _wasHardPress;
    bool _wasChubbyPress;
    Square *_touchedSqaure;
}
@end

@implementation Grid

- (id) initWithGame:(MinesweeperGame *)game withSize:(UIUserInterfaceSizeClass)s {
    if (s == UIUserInterfaceSizeClassRegular) {
        _squareSize = SQUARE_SIZE_REGULAR;
    } else {
        _squareSize = SQUARE_SIZE_COMPACT;
    }
    _game = game;
    
    self = [super initWithFrame:CGRectMake(0, 0, _game.width*_squareSize-2, _game.height*_squareSize-2)];
    if (self) {
        
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        CGRect gridFrame = CGRectMake(-1, -1, _game.width*_squareSize, _game.height*_squareSize);
        
        // Corner rounding maybe one day
//        self.layer.cornerRadius = 10;
//        self.layer.masksToBounds = true;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:gridFrame];
        [[backgroundView layer] setBackgroundColor:[UIColor colorWithWhite:1 alpha:.3].CGColor];
        backgroundView.userInteractionEnabled = NO;
        [self addSubview:backgroundView];
        
        // Add drop shadow
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 20;
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = backgroundView.bounds;
        [backgroundView addSubview:visualEffectView];
        
        UIView *frontView = [[UIView alloc] initWithFrame:gridFrame];
        [[frontView layer] setBorderWidth:1];
        [[frontView layer] setBorderColor:[UIColor blackColor].CGColor];
        frontView.userInteractionEnabled = NO;
        [self addSubview:frontView];
        
        _shadowView = [[UIView alloc] initWithFrame:gridFrame];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowView.layer.shadowOpacity = 1;
        _shadowView.layer.shadowRadius = 0.75;
        _shadowView.clipsToBounds = YES;
        
        [self calculateShadowPath];
        
        
        [self insertSubview:_shadowView belowSubview:frontView];
        
        _gridView = [[UIView alloc] initWithFrame:gridFrame];
        [self insertSubview:_gridView belowSubview:_shadowView];
        
        // Create the squares
        self.squares = [[NSMutableArray alloc] init];
        for (int i = 0; i < _game.width; i++) {
            [self.squares addObject:[[NSMutableArray alloc] init]];
            for (int j = 0; j < _game.height; j++) {
                Square *square = [[Square alloc]
                                  initWithFrame:CGRectMake(i*_squareSize, j*_squareSize, _squareSize, _squareSize)];
                square.parent = _shadowView;
                square.number = 0;
                square.indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                
                [[self.squares objectAtIndex:i] addObject:square];
                [_shadowView addSubview:square];
            }
        }
        
        [self setupInput];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(settingsChanged)
                                                    name:@"MinesweeperSettingsChanged"
                                                  object:nil];
//        [self addInteraction:[[UIContextMenuInteraction alloc] initWithDelegate:self]];
    }
    return self;
}

- (UIContextMenuConfiguration * _Nullable) contextMenuInteraction: (UIContextMenuInteraction *) interaction configurationForMenuAtLocation: (CGPoint) location {
    [self flag:location];
    return Nil;
}

- (void) traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self setupInput];
}

- (void) setupInput {
    _3DTouch = false;
    // Remove all gesture recognizers
    for (UIGestureRecognizer *r in self.gestureRecognizers) {
        [self removeGestureRecognizer:r];
    }

    //NSLog(@"Force Touch: %ld", (long)[[self traitCollection] forceTouchCapability]);
    if ([[self traitCollection] respondsToSelector:@selector(forceTouchCapability)] && [[SettingsManager sharedInstance] get3DTouchEnabled] && [[self traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
        // Use 3D Touch!
        _3DTouch = true;
        NSLog(@"Using 3D touch");
    } else {
        [self createGesureRecognizers];
    }
}

- (void) settingsChanged {
    [self setupInput];
}

- (void) createGesureRecognizers {
    // Create gesture recognizers
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    _longTap = [[UILongPressGestureRecognizer alloc] initWithTarget: self action:@selector(longTap:)];
    _longTap.minimumPressDuration = [[SettingsManager sharedInstance] getHoldDuration];
    _longTap.cancelsTouchesInView = YES;
    [self addGestureRecognizer:_longTap];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MinesweeperSettingsChanged" object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_3DTouch || _game.isPaused || (_game.state == GameStateFinished)) {
        return;
    }
    
    _wasHardPress = false;
    _wasChubbyPress = false;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_gridView];
    
    Square *square = [self getTouchedSquare:point];
    
    if ((_game.state != GameStateFirstMove) && square != nil && square.state != SquareStateRevealed) {
        _touchedSqaure = square;
        [_shadowView bringSubviewToFront:_touchedSqaure];
    } else {
        _touchedSqaure = nil;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_3DTouch ||  _game.isPaused || (_game.state == GameStateFinished) || _wasHardPress) {
        return;
    }
    
    if (self.title.smileyState == SmileyStateNormal) {
        self.title.smileyState = SmileyStateAction;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_gridView];
    
    if (_touchedSqaure != nil) {
        
        float scale;
        scale = 0.5+(touch.force/3.0)*(.66/[[SettingsManager sharedInstance] get3DTouchSensitivity]);
        if (scale <= 1) {
            scale = 1;
        }
        
        if (scale > 1) {
            _wasChubbyPress = true;
        }
        
        _touchedSqaure.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    //NSLog(@"Threshold: %f", touch.maximumPossibleForce*[[SettingsManager sharedInstance] get3DTouchSensitivity]);
    if (touch.force >= touch.maximumPossibleForce*[[SettingsManager sharedInstance] get3DTouchSensitivity]) {
        _wasHardPress = true;
        if (_game.state != GameStateFirstMove) {
            if (_touchedSqaure != nil) {
                _touchedSqaure.transform = CGAffineTransformMakeScale(1, 1);
            }
            
            [self flag:point];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_3DTouch || _game.isPaused) {
        return;
    }
    
    if (self.title.smileyState == SmileyStateAction) {
        self.title.smileyState = SmileyStateNormal;
    }
    
    CGPoint point = [[touches anyObject] locationInView:_gridView];
    
    if (_game.state == GameStateFirstMove  || _touchedSqaure == nil) {
        [self dig:point];
    } else if ((!_wasHardPress) && !_wasChubbyPress) {
        [self dig:point];
    }
    
    if (_touchedSqaure != nil) {
        _touchedSqaure.transform = CGAffineTransformMakeScale(1, 1);
        _touchedSqaure = nil;
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_3DTouch || _game.isPaused) {
        return;
    }
    if (self.title.smileyState == SmileyStateAction) {
        self.title.smileyState = SmileyStateNormal;
    }
    if (_touchedSqaure != nil) {
        _touchedSqaure.transform = CGAffineTransformMakeScale(1, 1);
        _touchedSqaure = nil;
    }
}

- (Square *) getTouchedSquare:(CGPoint) point {
    UIView *tappedView = [_gridView hitTest:point withEvent:nil];
    if (![tappedView isKindOfClass:[Square class]]) {
        tappedView = [_shadowView hitTest:point withEvent:nil];
        if (![tappedView isKindOfClass:[Square class]]) {
            return nil;
        }
    }
    
    Square *square = (Square *)tappedView;
    return square;
}

- (void) dig:(CGPoint)point {
    if (_game.isPaused) {
        return;
    }
    
    Square *square = [self getTouchedSquare:point];
    if (square == nil) {
        return;
    }
    _delayPath = square.indexPath;
    
    // Setup the game after the first tap
    if (_game.state == GameStateFirstMove) {
        [_game initModelWithX:square.indexPath.section y:square.indexPath.row];
        [_game setState:GameStatePlaying];
    }
    
    if (![[SettingsManager sharedInstance] getQuestionMarksEnabled] && square.state == SquareStateFlagged) {
        return;
    }
    
    [_game tapWithX:square.indexPath.section y:square.indexPath.row];
    [self syncBoard];
}

- (void) flag:(CGPoint)point {
    if (_game.isPaused || _game.state == GameStateFirstMove) {
        return;
    }
    
    UIView *tappedView = [_shadowView hitTest:point withEvent:nil];
    if (![tappedView isKindOfClass:[Square class]]) {
        return;
    }
    
    Square *square = (Square *)tappedView;
    [_shadowView bringSubviewToFront:square];
    [square bounce];
    
    [_game flagWithX:square.indexPath.section y:square.indexPath.row];
    
    [SoundManager.sharedInstance playSoundEffect:SoundEffectFlag];
    [self syncBoard];
}

- (void) singleTap:(UITapGestureRecognizer *)sender {
    //Determine which square was tapped
    CGPoint point = [sender locationInView:_gridView];
    [self dig:point];
}

- (void) longTap:(UILongPressGestureRecognizer *)sender {
    if (_game.isPaused) {
        return;
    }
    
    CGPoint point = [sender locationInView:_shadowView];
    
    if (_game.state == GameStateFirstMove && sender.state == UIGestureRecognizerStateEnded) {
        [self dig:point];
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.title.smileyState == SmileyStateNormal) {
            self.title.smileyState = SmileyStateAction;
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.title.smileyState == SmileyStateAction) {
            self.title.smileyState = SmileyStateNormal;
        }
    }
    
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self getTouchedSquare:point].state != SquareStateRevealed) {
            [self flag:point];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self getTouchedSquare:point].state == SquareStateRevealed) {
            [self dig:point];
        }
    }
}

- (void) hint {
    NSArray<NSDictionary *> * data = [_game hint];
    
    if (data) {
        [self syncBoard];
        
        NSDictionary * _Nonnull firstPosition = [data firstObject];
        if (firstPosition) {
            int x = (int)[[firstPosition objectForKey:@"x"] integerValue];
            int y = (int)[[firstPosition objectForKey:@"y"] integerValue];
            Square *square = [self getSquareAtSection:x andRow:y];
            
            CGRect __block frame = square.frame;
            [[self getNeighborSquares:square] enumerateObjectsUsingBlock:^(Square * obj, BOOL * _Nonnull stop) {
                frame = CGRectUnion(frame, obj.frame);
            }];
            
            float scaleFactor = self.contentScaleFactor / [[UIScreen mainScreen] scale];
            frame = CGRectMake(frame.origin.x * scaleFactor, frame.origin.y * scaleFactor, frame.size.width * scaleFactor, frame.size.height * scaleFactor);
            
            BOOL delay = CGRectIntersectsRect(self.scrollView.bounds, frame);
            
            [UIView animateWithDuration:0.1 animations:^{
                [self.scrollView scrollRectToVisible:frame animated:FALSE];
            } completion:^(BOOL finished) {
                if (delay) {
                    [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:NO block:^(NSTimer *timer) {
                        [self animateHints:data];
                    }];
                } else {
                    [self animateHints:data];
                }
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil
                                                        message:@"There is no hint available."
                                                       delegate:self
                                              cancelButtonTitle:Nil
                                              otherButtonTitles:@"Ok", nil];
        [alert show];
    }
}

- (void) animateHints: (NSArray<NSDictionary *> *) data {
    [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int x = (int)[[obj objectForKey:@"x"] integerValue];
        int y = (int)[[obj objectForKey:@"y"] integerValue];
        
        Square *square = [self getSquareAtSection:x andRow:y];
        
        [_shadowView bringSubviewToFront:square];
        [_gridView bringSubviewToFront:square];
        if (square.number < 0) {
            [square bounceFlag];
        } else {
            [square bounce];
        }
    }];
}

- (void) undo {
    if (_game.state == GameStateFinished) {
        NSDictionary *state = [_game getGameState];
        NSString *status = [[state objectForKey:@"status"] stringValue];
        if ([status isEqualToString:@"lose"]) {
            _game.isPaused = false;
            [_game undo];
            [self syncBoard];
            [self setupInput];
            self.title.smileyState = SmileyStateNormal;
            [_game setState:GameStatePlaying];
        }
    }
}

- (void) syncBoard {
    NSArray * board = [_game getBoard];
    BOOL __block playedSound = false;
    
    [board enumerateObjectsUsingBlock:^(id  _Nonnull row, NSUInteger y, BOOL * _Nonnull stop) {
        [row enumerateObjectsUsingBlock:^(NSDictionary* _Nonnull data, NSUInteger x, BOOL * _Nonnull stop) {
            Square *square = [self getSquareAtSection:(int)x andRow:(int)y];
            
            square.highlight = [[data objectForKey:@"highlight"] boolValue];
            square.number = (int)[[data objectForKey:@"value"] integerValue];
            NSInteger state = [[data objectForKey:@"state"] integerValue];
            
            // Sync state
            // This animates so we don't want to unneccessarily call it
            if (square.state != state) {
                square.animationDelay = [self distanceBetweenPath:_delayPath andPath:square.indexPath]/12.f;
                
                if (square.state == SquareStateRevealed && state != SquareStateRevealed) {
                    [square setState:SquareStateNormal];
                    [square removeFromSuperview];
                    [_shadowView addSubview:square];
                }
                
                [square setState:state];
                if (state == SquareStateRevealed) {
                    if (!playedSound) {
                        playedSound = true;
                        [SoundManager.sharedInstance playSoundEffect:SoundEffectSelect];
                    }
                    
                    [square removeFromSuperview];
                    [_gridView addSubview:square];
                }
            }
        }];
    }];
    
    NSDictionary *state = [_game getGameState];
    _title.bombs = (int)[[state objectForKey:@"mines"] integerValue];
    NSString *status = [[state objectForKey:@"status"] stringValue];
    if (![status isEqualToString:@"playing"]) {
        [self gameOver:[status isEqualToString:@"win"]];
    }
    
    self.contentScaleFactor = [[NSNumber numberWithFloat:self.contentScaleFactor] floatValue];
    [self calculateShadowPath];
}

- (void) gameOver: (bool) won {
    if (_game.state == GameStateFinished) {
        return;
    }
    [_game setState:GameStateFinished];
    
    // For record keeping.
    [[SettingsManager sharedInstance] gameOver:won];
    
    // Remove all gesture recognizers
    for (UIGestureRecognizer *r in self.gestureRecognizers) {
        [self removeGestureRecognizer:r];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer *timer) {
        if (self->_game.state == GameStateFinished) {
            // Remind player they must click the smiley to start a new game
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(remind)];
            singleTap.numberOfTapsRequired = 1;
            [self addGestureRecognizer:singleTap];
        }
    }];
    
    if (won) {
        self.title.smileyState = SmileyStateWin;
        
        // Report time
        [[SettingsManager sharedInstance] reportHighScore:_game.time];
    } else {
        self.title.smileyState = SmileyStateLose;
        [SoundManager.sharedInstance playSoundEffect:SoundEffectExplosion];
    }
}

- (void) remind {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Game?"
                                                    message:@"Would you like to start a new game? (You can also start new games by pressing the smiley button.)"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"NewGame"
         object:nil ];
    }
}

- (NSSet *) getNeighborSquares:(Square *)square {
    int row = (int)square.indexPath.row;
    int section = (int)square.indexPath.section;
    
    NSMutableSet *neighbors = [[NSMutableSet alloc] init];
    
    for (int i = section-1; i <= section+1; i++) {
        for (int j = row-1; j <= row+1; j++) {
            if ((i >= 0 && j >= 0 && i < _game.width && j < _game.height && !(i == section && j == row))) {
                [neighbors addObject:[self getSquareAtSection:i andRow:j]];
            }
        }
    }
    
    return neighbors;
}

- (void) calculateShadowPath {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    for (Square *v in _shadowView.subviews) {
        if ([v isKindOfClass:[Square class]]) {
            int i = (int)v.indexPath.section;
            int j = (int)v.indexPath.row;
            
            if ([self getSquareAtSection:i andRow:j-1].state == SquareStateRevealed) {//Top
                [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(v.frame.origin.x, v.frame.origin.y-.5, _squareSize, .5)]];
            }
            if ([self getSquareAtSection:i-1 andRow:j].state == SquareStateRevealed) {//Left
                [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(v.frame.origin.x-.5, v.frame.origin.y, .5, _squareSize)]];
            }
            if ([self getSquareAtSection:i andRow:j+1].state == SquareStateRevealed) {//Bottom
                [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(v.frame.origin.x, v.frame.origin.y+_squareSize, _squareSize, .5)]];
            }
            if ([self getSquareAtSection:i+1 andRow:j].state == SquareStateRevealed) {//Right
                [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(v.frame.origin.x+_squareSize, v.frame.origin.y, .5, _squareSize)]];
            }

        }
    }
    
    _shadowView.layer.shadowPath = path.CGPath;
}

- (Square *) getSquareAtSection:(int)i andRow:(int)j {
    if (!(i >= 0 && j >= 0 && i < _game.width && j < _game.height))  {
        return nil;
    }
    return [[self.squares objectAtIndex:i] objectAtIndex:j];
}

- (float) distanceBetweenPath:(NSIndexPath *)p1 andPath:(NSIndexPath *)p2 {
    return sqrtf((p1.section-p2.section)*(p1.section-p2.section)+(p1.row-p2.row)*(p1.row-p2.row));
}

- (void) setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:contentScaleFactor];
    
    // Set scale for all squares
    for (UIView *v in _shadowView.subviews) {
        if ([v isKindOfClass:[Square class]]) {
            v.contentScaleFactor = contentScaleFactor;
            for(UIView *v2 in v.subviews)
            {
                v2.contentScaleFactor = contentScaleFactor;
            }
        }
    }
    for (UIView *v in _gridView.subviews) {
        if ([v isKindOfClass:[Square class]]) {
            v.contentScaleFactor = contentScaleFactor;
            for(UIView *v2 in v.subviews)
            {
                v2.contentScaleFactor = contentScaleFactor;
            }
        }
    }
}


@end
