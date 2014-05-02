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
@interface BaseLink : NSObject
@property(weak,nonatomic) NSString* _deviceId;
@property(weak,nonatomic) BaseLinkProvider* _linkProvider;
//@property(strong,nonatomic) _privatekey;
- (BaseLink*) init:(NSString*)deviceId provider:(BaseLinkProvider*)provider;
- (BOOL) sendPackage:(NetworkPackage*)np;
- (BOOL) sendPackageEncypted:(NetworkPackage*)np;
- (void) onPackageReceived:(NetworkPackage*)np;

@end;
