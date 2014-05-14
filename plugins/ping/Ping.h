//
//  Ping.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Plugin.h"
@class PluginInfo;
@class Plugin;

@protocol pingDelegate<NSObject>
@optional
@end

@interface Ping : Plugin


+ (id) sharedInstance;
- (BOOL) onPackageReceived:(NetworkPackage*)np;

@end
