//
//  BaseLink.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLinkProvider.h"
#import "NetworkPackage.h"
@class BaseLinkProvider;
@class NetworkPackage;
@class Device;

@protocol linkDelegate <NSObject>
@optional
- (void) onPackageReceived:(NetworkPackage*)np;
- (void) onSendSuccess;
- (void) onDisconnected;

@end


@interface BaseLink : NSObject

@property(strong,nonatomic) NSString* _deviceId;
@property(nonatomic,assign)id _linkDelegate;
//@property(strong,nonatomic) _privatekey;
- (BaseLink*) init:(NSString*)deviceId setDelegate:(id)linkDelegate;
- (BOOL) sendPackage:(NetworkPackage*)np;
- (BOOL) sendPackageEncypted:(NetworkPackage*)np;
- (void) disconnect;


@end;
