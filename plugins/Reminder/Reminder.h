//
//  Calendar.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/9/14.
//  
//

#import "Plugin.h"

@interface Reminder : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
+ (PluginInfo*) getPluginInfo;

@end
