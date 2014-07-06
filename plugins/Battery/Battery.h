//
//  Battery.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/6/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"

typedef  NS_ENUM(NSInteger,ThresholdBatteryEvent)
{
    ThresholdNone       = 0,
    ThresholdBatteryLow = 1
};

@interface Battery : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
+ (PluginInfo*) getPluginInfo;

@end
