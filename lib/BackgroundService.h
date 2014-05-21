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
#import "PluginFactory.h"
#import "GCDSingleton.h"

@class PluginFactory;
@class BaseLink;
@class Device;

@protocol backgroundServiceDelegate <NSObject>
@optional
-(void) onPairRequest:(NSString*)deviceId;
- (void) onPairTimeout:(NSString*)deviceId;
- (void) onPairSuccess:(NSString*)deviceId;
- (void) onPairRejected:(NSString*)deviceId;
- (void) onDeviceListRefreshed;
@end

@interface BackgroundService : NSObject<linkProviderDelegate,deviceDelegate>

@property(nonatomic,assign) id _backgroundServiceDelegate;

+ (id) sharedInstance;

- (void) startDiscovery;
- (void) refreshDiscovery;
- (void) pauseDiscovery;
- (void) stopDiscovery;
- (void) pairDevice:(NSString*)deviceId;
- (void) unpairDevice:(NSString*)deviceId;
- (NSArray*) getDevicePluginViews:(NSString*)deviceId;
- (NSDictionary*) getDevicesLists;


- (void) onNetworkChange;
@end
