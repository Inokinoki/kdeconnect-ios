//
//  BackgroundService.m
//  kdeconnect_test1
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BackgroundService.h"
#import "LanLinkProvider.h"
@implementation BackgroundService
{
    __strong NSMutableArray* _linkProviders;
    __strong NSMutableDictionary* _devices;
}

@synthesize _backgroundServiceDelegate;
@synthesize _visibleDevices;

- (BackgroundService*) initWithDelegate:(id)backgroundServiceDelegate
{
    
    _linkProviders=[NSMutableArray arrayWithCapacity:1];
    _devices=[NSMutableDictionary dictionaryWithCapacity:1];
    _visibleDevices=[NSMutableArray arrayWithCapacity:1];
    [self registerLinkProviders];
    [self loadRemenberedDevices];
    _backgroundServiceDelegate=backgroundServiceDelegate;
    return self;
}

- (void) loadRemenberedDevices
{
    //TODO read setting to load remembered Deviceds
}
- (void) registerLinkProviders
{
    // TODO  read setting for linkProvider registeration
    LanLinkProvider* linkProvider=[[LanLinkProvider alloc] initWithDelegate:self];
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
        [lp onPause];
    }
    [self refreshVisibleDeviceList];
}

- (void) pairDevice:(Device *)device
{
    [device requestPairing];
}

- (void) pingDevice:(Device *)device
{
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PING];
    [device sendPackage:np tag:PACKAGE_TAG_PING];
}

- (void) refreshVisibleDeviceList
{
    _visibleDevices=[NSMutableArray arrayWithCapacity:1];
    for (NSString* id  in [_devices keyEnumerator]) {
        if ([_devices[id] isReachable]) {
            [_visibleDevices addObject:_devices[id]];
        }
    }
}

- (void) onReachableStatusChanged:(Device*)device
{
    if (![device isReachable]) {
        [_visibleDevices removeObject:device];
    }
}

- (void) onNetworkChange
{
    NSLog(@"Network Change");
    for (LanLinkProvider* lp in _linkProviders){
        [lp onNetworkChange];
    }
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
        Device* device=[[Device alloc] init:np baselink:link setDelegate:self];
        [_devices setObject:device forKey:id];
        [_visibleDevices addObject:device];
    }
    [self refreshVisibleDeviceList];
}

- (void) onLinkDestroyed:(BaseLink *)link
{
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onLinkDestroyed:link];
    }
}

- (void) onPairRequest:(Device *)device
{
    [_backgroundServiceDelegate onPairRequest:device];
}



@end

