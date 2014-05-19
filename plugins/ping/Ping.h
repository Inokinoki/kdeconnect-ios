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

@property(strong,nonatomic) Device* _device;
@property(strong,nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic,assign) id _pluginDelegate;

+ (id) sharedInstance;
- (BOOL) onCreate;
- (void) onDestroy;
- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView;

@end
