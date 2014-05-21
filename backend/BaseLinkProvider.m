//
//  BaseLinkProvider.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BaseLinkProvider.h"

@implementation BaseLinkProvider

@synthesize _linkProviderDelegate;

- (BaseLinkProvider*) initWithDelegate:(id)linkProviderDelegate
{
    if ((self=[super init])) {
        _linkProviderDelegate=linkProviderDelegate;
    }
    return self;
}
- (void) onStart
{
    
}

- (void) onRefresh
{
    
}

- (void) onPause
{
    
}

- (void) onStop
{
    
}

- (void) onNetworkChange
{
    
}
- (void) onLinkDestroyed:(BaseLink*)link
{
    
}

@end
