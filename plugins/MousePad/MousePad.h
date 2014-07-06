//
//  MousePad.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"

@interface MousePad : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
+ (PluginInfo*) getPluginInfo;

- (void) sendPointsWithDx:(double)x Dy:(double) y;
- (void) sendSingleClick;
- (void) sendDoubleClick;
- (void) sendMiddleClick;
- (void) sendRightClick;
- (void) sendScrollWithDx:(double)x Dy:(double)y;
@end