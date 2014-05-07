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
{
    __strong NSMutableArray*_linkProviders;
    __strong NSMutableDictionary* _devices;
}

- (BackgroundService*) init
{
    
    _linkProviders=[NSMutableArray arrayWithCapacity:1];
    _devices=[NSMutableDictionary dictionaryWithCapacity:1];
    [self registerLinkProviders];
    [self loadRemenberedDevices];
    return self;
}

- (void) loadRemenberedDevices
{
    //TODO read setting to load remembered Deviceds
}
- (void) registerLinkProviders
{
    // TODO  read setting for linkProvider registeration
    LanLinkProvider* linkProvider=[[LanLinkProvider alloc] init:self];
    [_linkProviders addObject:linkProvider];
}

- (void) startDiscovery
{
    NSLog(@"start Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStart];
    }
}

- (void) stopDiscovery
{
    NSLog(@"start Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStart];
    }
}

- (void) onNetworkChange
{
    NSLog(@"Network Change");
    for (LanLinkProvider* lp in _linkProviders){
        [lp onNetworkChange];
    }
}

- (NSDictionary*) visibleDevices
{
    NSMutableDictionary* list=[[NSMutableDictionary alloc] initWithCapacity:1];
    for (Device* device in _devices) {
        if ([device isReachable]) {
            [list setObject:device forKey:[device _name]];
        }
    }
    return list;
}

- (void) onConnectionReceived:(NetworkPackage *)np link:(BaseLink *)link
{
    NSString* id=[[np _Body] valueForKey:@"deviceId"];
    NSLog(@"Device discovered: %@",id);
    if ([_devices valueForKey:id]) {
        NSLog(@"known device");
        Device* device=[_devices objectForKey:id];
        [device addLink:np baseLink:link];
    }
    else{
        NSLog(@"new device");
        Device* device=[[Device alloc] init:np baselink:link backgroundDelegate:self];
        [_devices setObject:device forKey:id];
        //TODO device added
    }
    
    //TODO refresh device list
}

- (void) onConnectionLost:(BaseLink*)link
{
    
}


@end

