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
    if ((self=[super init])) {
        _linkProviders=[NSMutableArray arrayWithCapacity:1];
        _devices=[NSMutableDictionary dictionaryWithCapacity:1];
        _visibleDevices=[NSMutableArray arrayWithCapacity:1];
        [self registerLinkProviders];
        [self loadRemenberedDevices];
    }
    return self;
}

- (void) loadRemenberedDevices
{
    //TO-DO read setting to load remembered Deviceds

    //get app document path
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];

    //get local configue file
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"rememberedDevices.plist"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
    if (!fileExists) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"rememberedDevices" ofType:@"plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        [[data valueForKey:@"rememberedDevices"] writeToFile:filename atomically:YES];
    }
    
    NSMutableDictionary *devicesDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    for (NSString* deviceId in [devicesDict allKeys]) {
        Device* device=[[Device alloc] init:deviceId setDelegate:self];
        [_devices setObject:device forKey:deviceId];
    }
    NSLog(@"%@", devicesDict);
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

- (NSDictionary*) getDevicesLists
{
    NSLog(@"bg get devices lists");
    NSMutableDictionary* _visibleDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary* _connectedDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary* _rememberedDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    for (Device* device in [_devices allValues]) {
        if (![device isReachable]) {
            [_rememberedDevicesList setValue:[device _name] forKey:[device _id]];
        }
        else if([device isPaired]){
            [_connectedDevicesList setValue:[device _name] forKey:[device _id]];
            //TO-DO move this to a different thread maybe
            [device reloadPlugins];
        }
        else{
            [_visibleDevicesList setValue:[device _name] forKey:[device _id]];
        }
    }
    NSDictionary* list=[NSDictionary dictionaryWithObjectsAndKeys:
                        _connectedDevicesList,  @"connected",
                        _visibleDevicesList,    @"visible",
                        _rememberedDevicesList, @"remembered",nil];
    return list;
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

- (NSArray*) getDevicePluginViews:(NSString*)deviceId viewController:(UIViewController*)vc
{
    NSLog(@"bg get device plugin view");
    Device* device=[_devices valueForKey:deviceId];
    if (device) {
        return [device getPluginViews:vc];
    }
    return nil;
}

- (void) refreshVisibleDeviceList
{
    NSLog(@"bg on device refresh visible device list");
    BOOL updated=false;
    for (Device* device  in [_devices allValues]) {
        if ([device isReachable]) {
            if (![_visibleDevices containsObject:device]) {
                updated=true;
                [_visibleDevices addObject:device];
            }
        }
        else{
            if ([_visibleDevices containsObject:device]) {
                updated=true;
                [_visibleDevices removeObject:device];
            }
        }
    }
    if (_backgroundServiceDelegate && updated) {
        [_backgroundServiceDelegate onDeviceListRefreshed];
    }
}

- (void) onDeviceReachableStatusChanged:(Device*)device
{
    NSLog(@"bg on device reachable status changed");
    if (![device isReachable]) {
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

