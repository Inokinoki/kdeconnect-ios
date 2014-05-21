//
//  BaseLink.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BaseLink.h"

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

- (BOOL) sendPackage:(NetworkPackage *)np tag:(long)tag
{
    return true;
}

- (BOOL) sendPackageEncypted:(NetworkPackage *)np tag:(long)tag
{
    
    return true;
}

- (void) disconnect
{
    
}

@end
