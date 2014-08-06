//
//  ClipBoard.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/5/14.
//  
//

#import "Plugin.h"

@interface ClipBoard : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (void) stop;
+ (PluginInfo*) getPluginInfo;

@end