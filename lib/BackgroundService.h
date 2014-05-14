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
-(void) onPairRequest:(Device*)device;
- (void) onPairTimeout:(Device*)device;
- (void) onPairSuccess:(Device*)device;
- (void) onPairRejected:(Device*)device;
@end

@interface BackgroundService : NSObject<linkProviderDelegate,deviceDelegate>

@property(nonatomic,assign) id _backgroundServiceDelegate;
@property(strong,nonatomic) NSMutableArray* _visibleDevices;

+ (id) sharedInstance;

- (void) startDiscovery;
- (void) stopDiscovery;

- (void) pairDevice:(Device*)device;
- (void) pingDevice:(Device*)device;

- (void) onNetworkChange;
- (void) onLinkDestroyed:(BaseLink*)link;
- (void) onConnectionReceived:(NetworkPackage *)np link:(BaseLink *)link;
- (void) onReachableStatusChanged:(Device*)device;
- (void) onPairRequest:(Device*)device;
- (void) onPairTimeout:(Device*)device;
- (void) onPairSuccess:(Device*)device;
- (void) onPairRejected:(Device*)device;
@end
