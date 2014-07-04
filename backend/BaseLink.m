//
//  BaseLink.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BaseLink.h"
#import "BaseLinkProvider.h"

@implementation BaseLink

@synthesize _deviceId;
@synthesize _linkDelegate;

- (BaseLink*) init:(NSString*)deviceId setDelegate:(id)linkDelegate
{
    if ((self=[super init])) {
        _deviceId=deviceId;
        _linkDelegate=linkDelegate;
    }
    return self;
}

@end
