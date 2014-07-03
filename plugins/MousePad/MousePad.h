//
//  MousePad.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"
@class PluginInfo;
@class Plugin;

@protocol mousepadDelegate<NSObject>
@optional
@end

@interface MousePad : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (void) stop;
- (UIView*) getView:(UIViewController*)vc;
- (void) setStartPointWithX:(double)x Y:(double) y;
- (void) sendPointsWithX:(double)x Y:(double) y;
- (void) sendSingleClick;
@end