//
//  BaseLinkProvider.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkPackage.h"
#import "BaseLink.h"

@class BackgroundService;
@class BaseLink;
@class NetworkPackage;

@protocol linkProviderDelegate <NSObject>
@optional
- (void) onConnectionReceived:(NetworkPackage*)np link:(BaseLink*)link;
@end

@interface BaseLinkProvider : NSObject

@property(nonatomic,assign)id _linkProviderDelegate;
@property(strong,nonatomic) NSMutableArray* _connectedLinks;

- (BaseLinkProvider*) initWithDelegate:(id)linkProviderDelegate;
- (void) onStart;
- (void) onStop;
- (void) onPause;
- (void) onNetworkChange;
- (void) onLinkDestroyed:(BaseLink*)link;

@end
