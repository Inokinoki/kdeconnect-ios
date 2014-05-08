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

@protocol backgroundServiceDelegate <NSObject>
@optional

@end

@interface BackgroundService : NSObject<linkDelegate,linkProviderDelegate>

@property(nonatomic,assign) id _backgroundServiceDelegate;

- (BackgroundService*) initWithDelegate:(id)backgroundServiceDelegate;
- (void) startDiscovery;
- (void) stopDiscovery;
- (void) onNetworkChange;
- (void) onConnectionReceived:(NetworkPackage *)np link:(BaseLink *)link;
- (NSDictionary*) visibleDevices;


@end
