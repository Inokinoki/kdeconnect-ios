//
//  BackgroundService.h
//  kdeconnect_test1
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLink.h"
#import "BaseLinkProvider.h"
#import "Device.h"
#import "NetworkPackage.h"
@class BaseLink;
@class Device;

@interface BackgroundService : NSObject
@property(weak,nonatomic)NSMutableArray*_linkProviders;
@property(weak,nonatomic)NSMutableDictionary* _devices;


- (BackgroundService*) init;
- (void) loadRemenberedDevices;
- (void) registerLinkProviders;
- (void) startDiscovery;
- (void) stopDiscovery;
- (void) deviceAdded:(NSString*)id;
- (void) deviceRemoved:(NSString*)id;
- (void) initializeRsaKeys;
- (void) onNetworkChange;
- (void) onConnectionReceived:(NetworkPackage*)np link:(BaseLink*)link;
- (void) onConnectionLost:(BaseLink*)link;
- (void) onDestroy;
- (void) onDeviceListChanged;

@end
