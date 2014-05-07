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
#import "BackgroundService.h"
@class BackgroundService;
@class BaseLink;
@class NetworkPackage;

@interface BaseLinkProvider : NSObject
- (BaseLinkProvider*) init;
- (void) onStart;
- (void) onStop;
- (void) onNetworkChange;

@end
