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
    //TO-DO regroup not paired devices and remembered devices
    __strong NSMutableDictionary* _devices;
    __strong NSMutableArray* _visibleDevices;
}

@synthesize _backgroundServiceDelegate;

+ (id) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [super allocWithZone:zone];
    });
}

- (id)copyWithZone:(NSZone *)zone;{
    return self;
}

- (id) init
{
    _linkProviders=[NSMutableArray arrayWithCapacity:1];
    _devices=[NSMutableDictionary dictionaryWithCapacity:1];
    _visibleDevices=[NSMutableArray arrayWithCapacity:1];
    [self registerLinkProviders];
    [self loadRemenberedDevices];
    return self;
}

- (void) loadRemenberedDevices
{
    //TO-DO read setting to load remembered Deviceds
}
- (void) registerLinkProviders
{
    NSLog(@"bg register linkproviders");
    // TO-DO  read setting for linkProvider registeration
    LanLinkProvider* linkProvider=[[LanLinkProvider alloc] initWithDelegate:self];
    [_linkProviders addObject:linkProvider];
}

- (void) startDiscovery
{
    NSLog(@"bg start Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStart];
    }
}

- (void) refreshDiscovery
{
    NSLog(@"bg refresh Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onRefresh];
    }
}

- (void) pauseDiscovery
{
    NSLog(@"bg pause Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onPause];
    }
}

- (void) stopDiscovery
{
    NSLog(@"bg stop Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStop];
    }
}

- (NSDictionary*) getNotPairedDevices
{
    NSLog(@"bg get not paired devices");
    NSMutableDictionary* devices=[NSMutableDictionary dictionaryWithCapacity:1];
    for (Device* device in _visibleDevices) {
        if (![device isPaired]) {
            [devices setValue:[device _name] forKey:[device _id]];
        }
    }
    return devices;
}

- (NSDictionary*) getPairedDevices
{
    NSLog(@"bg get paired devices");
    NSMutableDictionary* devices=[NSMutableDictionary dictionaryWithCapacity:1];
    for (Device* device in _visibleDevices) {
        if ([device isPaired]) {
            [devices setValue:[device _name] forKey:[device _id]];
        }
    }
    return devices;
}

- (void) pairDevice:(NSString*)deviceId;
{
    NSLog(@"bg pair device");
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device requestPairing];
    }
}

- (void) unpairDevice:(NSString*)deviceId
{
    NSLog(@"bg unpair device");
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device unpair];
    }
}

- (void) refreshVisibleDeviceList
{
    NSLog(@"bg on device refresh visible device list");
    _visibleDevices=[NSMutableArray arrayWithCapacity:1];
    for (NSString* deviceId  in [_devices allKeys]) {
        if ([_devices[deviceId] isReachable]) {
            [_visibleDevices addObject:_devices[deviceId]];
        }
    }
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onDeviceListRefreshed];
    }
}

- (void) onDeviceReachableStatusChanged:(Device*)device
{
    NSLog(@"bg on device reachable status changed");
    if (![device isReachable]) {
        [_visibleDevices removeObject:device];
        NSLog(@"bg device not reachable");
    }
    if (![device isPaired]) {
        [_devices removeObjectForKey:[device _id]];
        NSLog(@"bg destroy device");
    }
    [self refreshVisibleDeviceList];
}

- (void) onNetworkChange
{
    NSLog(@"bg on network change");
    for (LanLinkProvider* lp in _linkProviders){
        [lp onNetworkChange];
    }
    [self refreshVisibleDeviceList];
}

- (void) onConnectionReceived:(NetworkPackage *)np link:(BaseLink *)link
{
    NSLog(@"bg on connection received");
    NSString* deviceId=[[np _Body] valueForKey:@"deviceId"];
    NSLog(@"Device discovered: %@",deviceId);
    if ([_devices valueForKey:deviceId]) {
        NSLog(@"known device");
        Device* device=[_devices objectForKey:deviceId];
        [device addLink:np baseLink:link];
    }
    else{
        NSLog(@"new device");
        Device* device=[[Device alloc] init:np baselink:link setDelegate:self];
        [_devices setObject:device forKey:deviceId];
        [_visibleDevices addObject:device];
        [self refreshVisibleDeviceList];
    }
}

- (void) onLinkDestroyed:(BaseLink *)link
{
    NSLog(@"bg on link destroyed");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onLinkDestroyed:link];
    }
}

- (void) onDevicePairRequest:(Device *)device
{
    NSLog(@"bg on device pair request");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRequest:[device _id]];
    }
    
}

- (void) onDevicePairTimeout:(Device*)device
{
    NSLog(@"bg on device pair timeout");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairTimeout:[device _id]];
    }
}

- (void) onDevicePairSuccess:(Device*)device
{
    NSLog(@"bg on device pair success");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairSuccess:[device _id]];
    }
}

- (void) onDevicePairRejected:(Device*)device
{
    NSLog(@"bg on device pair rejected");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRejected:[device _id]];
    }
}
    

@end

