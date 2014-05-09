//
//  Device.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/29/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLink.h"
#import "NetworkPackage.h"
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
-(void) onReachableStatusChanged:(Device*)device;
-(void) onPairRequest:(Device*)device;
@end

@interface Device : NSObject <linkDelegate>

@property(strong,readonly,nonatomic)NSString* _id;
@property(strong,readonly,nonatomic)NSString* _name;
@property(readonly,nonatomic)DeviceType* _type;
@property(readonly,nonatomic)NSInteger _protocolVersion;
@property(readonly,nonatomic)PairStatus _pairStatus;
@property(nonatomic,assign) id _deviceDelegate;

- (Device*) init:(NSString*)deviceId setDelegate:(id)deviceDelegate;
- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)link setDelegate:(id)deviceDelegate;
- (NSInteger) compareProtocolVersion;

#pragma mark Link-related Functions
- (void) addLink:(NetworkPackage*)np baseLink:(BaseLink*)link;
- (void) onPackageReceived:(NetworkPackage*)np;
- (void) onLinkDestroyed:(BaseLink *)link;
- (void) onSendSuccess:(long)tag;
- (BOOL) sendPackage:(NetworkPackage*)np tag:(long)tag;
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



