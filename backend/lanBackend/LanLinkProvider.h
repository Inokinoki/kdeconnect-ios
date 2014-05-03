//
//  LanLinkProvider.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "NetworkPackage.h"
#import <CFNetwork/CFNetwork.h>
#import "BaseLinkProvider.h"
#import "LanLink.h"
@class GCDAsyncSocket;
@class GCDAsyncUdpSocket;
@class BackgroundService;
@class LanLink;
static int PORT=1714;

@interface LanLinkProvider : BaseLinkProvider

@property(weak,nonatomic)NSMutableDictionary* _visibleComputers;
@property(strong,nonatomic)BackgroundService* _parent;
- (LanLinkProvider*) init:(BackgroundService*)parent;
- (void) onNetworkChange;
- (void) onStart;
- (void) onStop;
- (void) connected;

- (void) newConnection;
- (void) packageRecieved;
- (void) baseLinkDestroyed;

- (void) addLink:(NetworkPackage*)np lanLink:(LanLink*)lanLink;

@end
