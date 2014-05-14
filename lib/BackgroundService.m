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
    NSLog(@"stop Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onPause];
    }
    [self refreshVisibleDeviceList];
}

- (NSDictionary*) getVisibleDevices
{
    NSMutableDictionary* devices=[NSMutableDictionary dictionaryWithCapacity:1];
    for (Device* device in _visibleDevices) {
        [devices setValue:[device _name] forKey:[device _id]];
    }
    return devices;
}

- (void) pairDevice:(NSString*)deviceId;
{
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device requestPairing];
    }
}

- (void) unpairDevice:(NSString*)deviceId
{
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device unpair];
    }
}

- (void) refreshVisibleDeviceList
{
    _visibleDevices=[NSMutableArray arrayWithCapacity:1];
    for (NSString* id  in [_devices keyEnumerator]) {
        if ([_devices[id] isReachable]) {
            [_visibleDevices addObject:_devices[id]];
        }
    }
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onDeviceListRefreshed];
    }
}

- (void) onDeviceReachableStatusChanged:(Device*)device
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

- (void) onDevicePairRequest:(Device *)device
{
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRequest:[device _id]];
    }
    
}

- (void) onDevicePairTimeout:(Device*)device
{
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairTimeout:[device _id]];
    }
}

- (void) onDevicePairSuccess:(Device*)device
{
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairSuccess:[device _id]];
    }
}

- (void) onDevicePairRejected:(Device*)device
{
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRejected:[device _id]];
    }
}
    

@end

