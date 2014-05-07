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

@interface LanLinkProvider : BaseLinkProvider
{
    dispatch_queue_t socketQueue;
}
@property(strong,nonatomic) NSMutableDictionary* _visibleComputers;
@property(nonatomic,assign) id _backgroundDelegate;
- (LanLinkProvider*) init:(id)backgroundDlegate;
- (void) onStart;
- (void) onStop;
- (void) onNetworkChange;
- (void) onLinkDestroyed;

@end
