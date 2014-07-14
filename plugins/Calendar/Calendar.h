//
//  Calendar.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/9/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"

@interface Calendar : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
+ (PluginInfo*) getPluginInfo;

@end
