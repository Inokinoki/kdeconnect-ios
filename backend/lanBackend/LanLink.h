//
//  LanLink.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLink.h"
@class BaseLink;
@class Device;
@interface LanLink : BaseLink
//@property(weak,nonatomic,readonly) _socketLinkReader
- (LanLink*) init:(NSString*) deviceId provider:(BaseLinkProvider *)provider;
- (BOOL) sendPackage:(NetworkPackage *)np;
- (BOOL) sendPackageEncypted:(NetworkPackage *)np;
- (void) onPackageReceived:(NetworkPackage*)np;
@end
