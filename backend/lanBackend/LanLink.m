//
//  LanLink.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "LanLink.h"

@implementation LanLink
@synthesize _deviceId;
@synthesize _linkProvider;
//@synthesize _socketLinkReader;

- (LanLink*) init:(NSString *)deviceId provider:(BaseLinkProvider *)provider
{
    if ([super init:deviceId provider:provider])
    {
        
    }
    return self;
}

- (BOOL) sendPackage:(NetworkPackage *)np
{
    
    return true;
}

- (BOOL) sendPackageEncypted:(NetworkPackage *)np
{
    
    return true;
}

@end
