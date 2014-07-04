//
//  BaseLink.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkPackage.h"

@interface BaseLink : NSObject

@property(nonatomic) NSString* _deviceId;
@property(nonatomic) id _linkDelegate;
@property(nonatomic) SecKeyRef _publicKey;

- (BaseLink*) init:(NSString*)deviceId setDelegate:(id)linkDelegate;
- (BOOL) sendPackage:(NetworkPackage*)np tag:(long)tag;
- (BOOL) sendPackageEncypted:(NetworkPackage*)np tag:(long)tag;
- (void) loadPublicKey;
- (void) removePublicKey;
- (void) disconnect;

@end;

@protocol linkDelegate <NSObject>
@optional
- (void) onPackageReceived:(NetworkPackage*)np;
- (void) onSendSuccess:(long)tag;
- (void) onLinkDestroyed:(BaseLink*)link;
@end
