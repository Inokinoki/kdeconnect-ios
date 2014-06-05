//
//  ClipBoard.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/5/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"
@class PluginInfo;
@class Plugin;

@protocol ClipBoardDelegate<NSObject>
@optional
@end

@interface ClipBoard : Plugin

@property(strong,nonatomic) Device* _device;
@property(strong,nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic,assign) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;

@end