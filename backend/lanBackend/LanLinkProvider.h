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
#import "BaseLinkProvider.h"
#import "LanLink.h"

@class GCDAsyncSocket;
@class GCDAsyncUdpSocket;
@class BackgroundService;
@class LanLink;

@interface LanLinkProvider : BaseLinkProvider <linkDelegate>

- (LanLinkProvider*) initWithDelegate:(id)linkProviderDelegate;
- (void) onStart;
- (void) onRefresh;
- (void) onStop;
- (void) onPause;
- (void) onNetworkChange;
- (void) onLinkDestroyed:(BaseLink*)link;

@end
