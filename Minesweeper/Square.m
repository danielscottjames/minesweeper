//
//  Square.m
//  Minesweeper
//
//  Created by Daniel James on 6/17/14.
//  Copyright (c) 2014 developersBliss. All rights reserved.
//

#import "Square.h"

@interface Square () {
    UIImageView *_image;
    UILabel *_label;
    
    int _width;
    int _height;
}
@end

@implementation Square

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _width, _width)];
        [self addSubview:_image];
        
        self.state = SquareStateNormal;
        
        if (@available(iOS 13.4, *)) {
            [self addInteraction: [[UIPointerInteraction alloc] init]];
        }
        
        [self addGestureRecognizer:[[UIHoverGestureRecognizer alloc] initWithTarget:self action:@selector(viewHoverChanged:)]];
    }
    return self;
}

- (void) viewHoverChanged: (UIHoverGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.parent bringSubviewToFront: self];
        [UIView animateWithDuration: 0.1 animations:^{
            self.layer.borderWidth = 1.0;
            
            self.layer.masksToBounds = NO;
            self.layer.shadowOffset = CGSizeMake(0, 0);
            self.layer.shadowRadius = 2;
            self.layer.shadowOpacity = 0.5;
        }];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration: 0.1 animations:^{
            self.layer.borderWidth = 0.5;
            self.layer.shadowOpacity = 0;
        }];
    }
}

- (void) setNumber:(int)number {
    _number = number;
}

- (void) setHighlight:(BOOL)highlight {
    _highlight = highlight;
    
    // Update the image
    if (_state == SquareStateFlagged) {
        [self setState:SquareStateFlagged];
    }
}

- (void) setState:(SquareState)state {
    _state = state;
    [self renderCurrentState:YES];
}

- (void) renderCurrentState:(BOOL)withAnimation {
    self.layer.shadowOpacity = 0;

    _image.hidden = YES;
    _label.hidden = YES;

    switch (_state) {
        case SquareStateFlagged:
            [self renderFilledSquare];
            [self renderImage:@"Flag" withColor:[UIColor colorNamed:@"Marker Color"]];
            break;
        case SquareStateQuestion:
            [self renderFilledSquare];
            [self renderImage:@"QuestionMark" withColor:[UIColor colorNamed:@"Marker Color"]];
            break;
        case SquareStateRevealed:
            [self prepareLabel];
            if (self.number < 0) {
                [self renderImage:@"Mine" withColor:[UIColor colorNamed:@"Mine Color"]];
                if (withAnimation) {
                    [self bounceWithDelay:self.animationDelay*.75];
                }
            }
            {
                UIColor *newBorderColor;
                float newBorderWidth;
                if (self.number > 0) {
                    newBorderColor = [UIColor colorNamed:@"Grid Color"];
                    newBorderWidth = 0.5;
                } else {
                    newBorderColor = [UIColor clearColor];
                    newBorderWidth = 0;
                }

                CABasicAnimation *backgroundColor = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
                backgroundColor.fromValue = (id)(self.layer.backgroundColor);
                backgroundColor.toValue = (id)[self backgroundColorForNumber:self.number].CGColor;
                // ... and change the model value
                self.layer.backgroundColor = [self backgroundColorForNumber:self.number].CGColor;

                CABasicAnimation *borderColor = [CABasicAnimation animationWithKeyPath:@"borderColor"];
                borderColor.fromValue = (id)(self.layer.borderColor);
                borderColor.toValue   = (id)newBorderColor.CGColor;
                // ... and change the model value
                self.layer.borderColor = [[self colorForNumber:self.number] colorWithAlphaComponent:.15].CGColor;

                // CABasicAnimation *borderWidth = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
                // borderWidth.fromValue = [NSNumber numberWithFloat:self.layer.borderWidth];
                // borderWidth.toValue   = [NSNumber numberWithFloat:newBorderWidth];
                // ... and change the model value
                self.layer.borderWidth = newBorderWidth;

                CAAnimationGroup *group = [CAAnimationGroup animation];
                group.duration   = 0.075 + self.animationDelay;
                group.animations = @[backgroundColor, borderColor];
                // group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

                [self.layer addAnimation:group forKey:@"revealAnimation"];
            }
            break;
        case SquareStateNormal:
        default:
            [self renderFilledSquare];
    }
}

- (void) prepareLabel {
    if (self.number > 0 && !_label) {
        _label = [[UILabel alloc] init];
        
        _label.font = [UIFont boldSystemFontOfSize:(26.f*((_width*1.0)/(SQUARE_SIZE_COMPACT*1.0)))];
        _label.textColor = [self colorForNumber:self.number];
        _label.text = [NSString stringWithFormat:@"%d", self.number];
        
        [_label sizeToFit];
        [_label setCenter:CGPointMake(_width/2, _height/2)];
        
        [self addSubview:_label];
        
        _label.contentScaleFactor = self.contentScaleFactor;
        self.contentScaleFactor = _label.contentScaleFactor;
    }
    _label.hidden = NO;
}

- (void) bounce {
    self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:.7],
                              [NSNumber numberWithFloat:1.85],
                              [NSNumber numberWithFloat:.8],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.3;
    bounceAnimation.removedOnCompletion = YES;
    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    self.layer.transform = CATransform3DIdentity;
}

- (void) bounceFlag {
    SquareState oldState = _state;
    [self setState:SquareStateFlagged];
    [self bounce];
    [NSTimer scheduledTimerWithTimeInterval:0.31 repeats:NO block:^(NSTimer *timer) {
        [self setState:oldState];
    }];
}

- (void) bounceWithDelay:(float)delay {
    [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(bounce) userInfo:nil repeats:NO];
}

- (void) renderFilledSquare {
    self.layer.backgroundColor = UIColor.systemGray5Color.CGColor;
    self.layer.borderColor = [UIColor colorNamed:@"Grid Color"].CGColor;
    self.layer.borderWidth = .5;
}

- (void) renderImage:(NSString *) image withColor:(UIColor*) color {
    _image.image = [UIImage imageNamed:image];
    if (_highlight) {
        _image.tintColor = UIColor.systemRedColor;
    } else {
        _image.tintColor = color;
    }
    _image.hidden = NO;
}

- (UIColor *) colorForNumber:(int)number {
    if (number >= 1 || number <= 8) {
        return [UIColor colorNamed:[NSString stringWithFormat:@"Square %@", @(number)]];
    }
    return [UIColor clearColor];
}

- (UIColor *) backgroundColorForNumber:(int)number {
    if (number >= 1 || number <= 8) {
        return [UIColor colorNamed:[NSString stringWithFormat:@"Square Background %@", @(number)]];
    }
    return [UIColor clearColor];
}


@end
