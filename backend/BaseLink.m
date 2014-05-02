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
@synthesize _linkProvider;
- (BaseLink*) init:(NSString*) deviceId provider:(BaseLinkProvider*) provider
{
    if ([super init])
    {
        [self set_deviceId:deviceId];
        [self set_linkProvider:provider];
    };
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

- (BOOL) sendPayload:(NetworkPackage *)np
{
    return true;
}

- (void) injectNetworkPackage:(NetworkPackage *)np
{
    
}

@end
