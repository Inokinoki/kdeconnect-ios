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
@interface Device : NSObject

typedef NS_ENUM(NSUInteger, PairStatus)
{
    NotPaired,
    Requested,
    RequestedByPeer,
    Paired
};

@property(readonly,nonatomic)BackgroundService* _parent;
@property(weak,nonatomic)NSString* _deviceId;
@property(weak,nonatomic)NSString* _name;
@property(nonatomic)NSInteger _protocolVersion;
@property(nonatomic)PairStatus* _pairStatus;
@property(weak,nonatomic)NSMutableArray* _baseLinks;
@property(weak,nonatomic)NSTimer* _pairingTimer;
//@property(weak,nonatomic) id* _publicKey;
//@property(weak,nonatomic) NSMutableDictionary* _plugins;
//@property(weak,nonatomic) NSMutableDictionary* _failedPlugins;

- (Device*) init:(NSString*)deviceId parent:(id*)parent;
- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)baseLink parent:(id*)parent;
- (NSInteger) compareProtocolVersion;

#pragma mark Link-related Functions
- (void) addLink:(NetworkPackage*)np baseLink:(BaseLink*)baseLink;
- (void) removeLink:(BaseLink*)baseLink;
- (void) onPackageReceived;
- (BOOL) sendPackage:(NetworkPackage*)np;
- (BOOL) isReachable;

#pragma mark Pairing-related Functions
- (BOOL) isPaired;
- (BOOL) isPaireRequested;
- (BOOL) requestPairing;
- (void) unpaire;
- (void) pairingSuccusful;
- (void) pairingFailed;
- (void) acceptPairing;
- (void) rejectPairing;

@end
