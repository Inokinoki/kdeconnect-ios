//
//  Plugin.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"
#import "Device.h"
#pragma mark PluginInfo
@implementation PluginInfo

@synthesize _pluginName;
@synthesize _displayName;
@synthesize _description;
@synthesize _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault
{
    if ((self=[super init])) {
        _pluginName=pluginName;
        _displayName=displayName;
        _description=description;
        _enabledByDefault=enabledBydefault;
    }
    return self;
}

@end

#pragma mark Plugin
@implementation Plugin
- (BOOL) onDevicePackageReceived:(NetworkPackage*)np
{
    return false;
}

- (void) stop
{
    
}

- (UIView*) getView:(UIViewController*)vc
{
    return nil;
}
@end
