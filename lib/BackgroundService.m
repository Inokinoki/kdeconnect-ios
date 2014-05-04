//
//  BackgroundService.m
//  kdeconnect_test1
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BackgroundService.h"
#import "../backend/lanBackend/LanLinkProvider.h"
@implementation BackgroundService

- (BackgroundService*) init
{
    self._linkProviders=[NSMutableArray array];
    self._devices=[NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

- (void) registerLinkProviders
{
    LanLinkProvider* linkProvider=[[LanLinkProvider alloc] init:self];
    [self._linkProviders addObject:linkProvider];
}

- (void) onNetworkChange
{
    for (LanLinkProvider* link in self._linkProviders)
    {
        [link onNetworkChange];
    }
}



@end

