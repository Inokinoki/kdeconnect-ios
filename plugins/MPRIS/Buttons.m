//
//  PlayPauseButton.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 8/5/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Buttons.h"
#import "MyStyleKit.h"

@interface PlayPauseButton ()
{
    bool isplay;
}
@end

@implementation PlayPauseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isplay=true;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    if (isplay) {
        [self setImage:[MyStyleKit imageOfPlay] forState:UIControlStateNormal];
        [self setImage:[MyStyleKit imageOfPlayHighlighted] forState:UIControlStateHighlighted];
    }
    else{
        [self setImage:[MyStyleKit imageOfPause] forState:UIControlStateNormal];
        [self setImage:[MyStyleKit imageOfPauseHighlighted] forState:UIControlStateHighlighted];
    }


}

- (void) setplay
{
    isplay=true;
    [self setNeedsDisplay];
}

- (void) setpause
{
    isplay=false;
    [self setNeedsDisplay];
}

@end

@implementation ForwardButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfForward] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfForwardHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation BackButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfBack] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfBackHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation PreviousButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfPrevious] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfPreviousHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation FollowingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfFollowing] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfFollowingHighlighted] forState:UIControlStateHighlighted];
}

@end
