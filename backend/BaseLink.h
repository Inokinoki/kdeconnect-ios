//
//  BaseLink.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  
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
- (void) onSentPercentage:(short)percentage tag:(long)tag;
- (void) onLinkDestroyed:(BaseLink*)link;
@end
