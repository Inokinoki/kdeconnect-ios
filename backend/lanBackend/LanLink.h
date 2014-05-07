//
//  LanLink.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLink.h"
#import "LanLinkProvider.h"
#import "AsyncSocket.h"
@class GCDAsyncSocket;
@class LanLinkProvider;
@class BaseLink;
@class Device;
@interface LanLink : BaseLink
@property(nonatomic,assign) id _deviceDelegate;
@property(nonatomic,assign) id _lanLinkProviderDelegate;
- (LanLink*) init:(GCDAsyncSocket*)socket deviceId:(NSString*) deviceid providerDelegate:(id)providerDelegate;
- (void) setDeviceDelegate:(id) deviceDelegate;
- (BOOL) sendPackage:(NetworkPackage *)np;
- (BOOL) sendPackageEncypted:(NetworkPackage *)np;
- (void) disconnect;
@end
