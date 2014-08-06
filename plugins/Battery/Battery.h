//
//  Battery.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/6/14.
//  
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
+ (PluginInfo*) getPluginInfo;

@end
