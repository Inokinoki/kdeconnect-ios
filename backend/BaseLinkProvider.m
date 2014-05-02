//
//  BaseLinkProvider.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BaseLinkProvider.h"

@implementation BaseLinkProvider
@synthesize _priority;
@dynamic _name;
- (BaseLinkProvider*) init:(BackgroundService*)parent
{
    self._parent=parent;
    return self;
}
- (void) onStart
{
    
}

- (void) onStop
{
    
}

- (void) onNetworkChange
{
    
}

- (void) onConnectionReceived:(NetworkPackage *)idp baselink:(BaseLink *)baselink
{
    
}

@end
