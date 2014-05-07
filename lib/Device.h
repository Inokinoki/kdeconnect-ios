//
//  Device.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/29/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLink.h"
#import "BackgroundService.h"
@class BackgroundService;
@class BaseLink;
@class NetworkPackage;

typedef NS_ENUM(NSUInteger, PairStatus)
{
    NotPaired,
    Requested,
    RequestedByPeer,
    Paired
};
typedef NS_ENUM(NSUInteger, DeviceType)
{
    Unknown,
    Desktop,
    Laptop,
    Phone,
    Tablet
};

@protocol deviceDelegate <NSObject>
@optional


@end

@interface Device : NSObject

@property(weak,readonly,nonatomic)NSString* _id;
@property(weak,readonly,nonatomic)NSString* _name;
@property(readonly,nonatomic)DeviceType* _type;
@property(readonly,nonatomic)NSInteger _protocolVersion;
@property(readonly,nonatomic)PairStatus _pairStatus;
@property(nonatomic,assign) id _deviceDelegate;

- (Device*) init:(NSString*)deviceId setDelegate:(id)deviceDelegate;
- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)link setDelegate:(id)deviceDelegate;
- (NSInteger) compareProtocolVersion;

#pragma mark Link-related Functions
- (void) addLink:(NetworkPackage*)np baseLink:(BaseLink*)link;
- (void) linkDestroyed:(BaseLink*)link;
- (void) removeLink:(BaseLink*)link;
- (void) onPackageReceived:(NetworkPackage*)np;
- (BOOL) sendPackage:(NetworkPackage*)np;
- (BOOL) isReachable;

#pragma mark Pairing-related Functions
- (BOOL) isPaired;
- (BOOL) isPaireRequested;
- (void) requestPairing;
- (void) unpair;
- (void) acceptPairing;
- (void) rejectPairing;

#pragma mark Plugin-related Functions

- (void) reloadPlugins;

@end



