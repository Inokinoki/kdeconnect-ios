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
    _linkProviderDelegate=linkProviderDelegate;
    return self;
}
- (void) onStart
{
    
}

- (void) onStop
{
    
}

- (void) onPause
{
    
}

- (void) onNetworkChange
{
    
}
- (void) onLinkDestroyed:(BaseLink*)link
{
    
}


@end
