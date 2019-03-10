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
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:gridFrame];
        [[backgroundView layer] setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1].CGColor];
        backgroundView.userInteractionEnabled = NO;
        [self addSubview:backgroundView];
        
//        UIVisualEffect *blurEffect;
//        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *visualEffectView;
//        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        visualEffectView.frame = backgroundView.bounds;
//        [backgroundView addSubview:visualEffectView];
        
        UIView *frontView = [[UIView alloc] initWithFrame:gridFrame];
        [[frontView layer] setBorderWidth:1];
        [[frontView layer] setBorderColor:[UIColor blackColor].CGColor];
        frontView.userInteractionEnabled = NO;
        [self addSubview:frontView];
        
        _shadowView = [[UIView alloc] initWithFrame:gridFrame];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowView.layer.shadowOpacity = 1;
        _shadowView.layer.shadowRadius = 1;
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
    }
    return self;
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
    if ([[self traitCollection] respondsToSelector:@selector(forceTouchCapability)] &&  [[SettingsManager sharedInstance] get3DTouchEnabled] && [[self traitCollection] forceTouchCapability] == UIForceTouchCapabilityAvailable) {
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
        [self firstTap:square];
    }
    
    // Toggle between flags and questions
    if (square.state == SquareStateFlagged) {
        square.state = SquareStateQuestion;
    } else if (square.state == SquareStateQuestion) {
        square.state = SquareStateFlagged;
    } else {
        if (square.state == SquareStateNormal) {
            [SoundManager.sharedInstance playSoundEffect:SoundEffectSelect];
        }
        
        [self revealSquare:square];
        [self checkWonGame];
        [self calculateShadowPath];
    }
    
    self.contentScaleFactor = [[NSNumber numberWithFloat:self.contentScaleFactor] floatValue];
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
    
    if (square.state == SquareStateFlagged || square.state == SquareStateQuestion) {
        square.state = SquareStateNormal;
        self.title.bombs++;
    } else if (square.state == SquareStateNormal) {
        square.state = SquareStateFlagged;
        self.title.bombs--;
    }
    [SoundManager.sharedInstance playSoundEffect:SoundEffectFlag];
    
    [self calculateShadowPath];
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

-(void) revealSquare:(Square *)square {
    square.animationDelay = [self distanceBetweenPath:_delayPath andPath:square.indexPath]/12.f;
    
    if (square.state == SquareStateNormal) {
        square.state = SquareStateRevealed;
        
        [square removeFromSuperview];
        [_gridView addSubview:square];
        
        if (square.number == 0) {
            [self revealBlankNeighbors:square];
        }
        if (square.number <= -1 && _game.state == GameStatePlaying) {
            square.number = -2;
            [self gameOver:NO];
        }
    } else if (square.state == SquareStateRevealed && square.number > 0) {
        int flaggedCount = 0;
        int unrevealedCount = 0;
        NSSet* neighbors = [self getNeighborSquares:square];
        
        for (Square *s in neighbors) {
            if (s.state == SquareStateFlagged) {
                flaggedCount++;
            }
            if (s.state == SquareStateNormal) {
                unrevealedCount++;
            }
        }
        
        if (flaggedCount == square.number) {
            if (unrevealedCount > 0) {
                [SoundManager.sharedInstance playSoundEffect:SoundEffectSelect];
            }
            
            for (Square *s in neighbors) {
                if (s.state == SquareStateNormal) {
                    [self revealSquare:s];
                }
            }
        }
    }
}

- (void) firstTap:(Square *)square {
    [_game setState:GameStatePlaying];
    
    // Don't make the first tile a bomb, nor its neighbors. (Doing this for neighbors isn't valid WinXP )
    NSMutableSet *protectedSquares = [[self getNeighborSquares:square] mutableCopy];
    [protectedSquares addObject:square];
    
    
    // Setup grid
    
    // Determine which squares will be bombs
    int bombsPlaced = 0;
    while (bombsPlaced < _game.mines) {
        int i = arc4random()%_game.width;
        int j = arc4random()%_game.height;
        
        
        Square *bombSquare = [self getSquareAtSection:i andRow:j];
        
        if (![protectedSquares containsObject:bombSquare]) {
            [protectedSquares addObject:bombSquare];
            bombSquare.number = -1;
            bombsPlaced++;
            
            // increment the count for all adjacent squares
            NSSet *neighbors = [self getNeighborSquares:bombSquare];
            for (Square *s in neighbors) {
                if (s.number >= 0) {
                    s.number++;
                }
            }
        }
    }
}

- (void) revealBlankNeighbors:(Square *)square {
    NSSet* neighbors = [self getNeighborSquares:square];
    
    for (Square *s in neighbors) {
        if (s.number >= 0 && s.state == SquareStateNormal) {
            [self revealSquare:s];
        }
    }
}

- (void) checkWonGame {
    if (!(_game.state == GameStatePlaying)) {
        return;
    }
    
    for (int i = 0; i < _game.width; i++) {
        for (int j = 0; j < _game.height; j++) {
            Square *square = [self getSquareAtSection:i andRow:j];
            if (square.number >= 0 && !(square.state == SquareStateRevealed)) {
                return;
            }
        }
    }
    
    [self gameOver:true];
}

- (void) gameOver: (bool) won {
    [_game setState:GameStateFinished];
    
    // For record keeping.
    [[SettingsManager sharedInstance] gameOver:won];
    
    // Remove all gesture recognizers
    for (UIGestureRecognizer *r in self.gestureRecognizers) {
        [self removeGestureRecognizer:r];
    }
    
    // Remind player they must click the smiley to start a new game
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(remind)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    if (won) {
//        self.title.smileyState = SmileyStateWin;
        
        // Report time
        [[SettingsManager sharedInstance] reportHighScore:_game.time];
        
        // Add flags to the remaining unrevealed squares. (You win by revealing all non bombs, not by flagging them all)
        for (int i = 0; i < _game.width; i++) {
            for (int j = 0; j < _game.height; j++) {
                Square *square = [self getSquareAtSection:i andRow:j];
                if ((square.number == -1 && square.state == SquareStateNormal)) {
                    square.state = SquareStateFlagged;
                }
            }
        }
    } else {
//        self.title.smileyState = SmileyStateLose;
        [SoundManager.sharedInstance playSoundEffect:SoundEffectExplosion];
        
        // Reveal all the squares
        for (int i = 0; i < _game.width; i++) {
            for (int j = 0; j < _game.height; j++) {
                Square *square = [self getSquareAtSection:i andRow:j];
                if ((square.state == SquareStateNormal)) {
                    [self revealSquare:[self getSquareAtSection:i andRow:j]];
                }
                if ((square.state == SquareStateFlagged && square.number >= 0)) {
                    square.state = SquareStateFlaggedWrong;
                }
            }
        }
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

- (void) calculateShadowPath {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    for (Square *v in _shadowView.subviews) {
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
    
    _shadowView.layer.shadowPath = path.CGPath;
}

//- (void) setIsPaused:(BOOL)isPaused {
//    _isPaused = isPaused;
//    
//    if (self.isPlaying) {
//        if (self.isPaused) {
//            [_title stopTimer];
//        } else {
//            [_title startTimer];
//        }
//    }
//}

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
        v.contentScaleFactor = contentScaleFactor;
        for(UIView *v2 in v.subviews)
        {
            v2.contentScaleFactor = contentScaleFactor;
        }
    }
    for (UIView *v in _gridView.subviews) {
        v.contentScaleFactor = contentScaleFactor;
        for(UIView *v2 in v.subviews)
        {
            v2.contentScaleFactor = contentScaleFactor;
        }
    }
}


@end
