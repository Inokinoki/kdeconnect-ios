//
//  Plugin.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"

#pragma mark PluginInfo
@implementation PluginInfo

@synthesize _pluginName;
@synthesize _displayName;
@synthesize _description;
@synthesize _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault
{
    _pluginName=pluginName;
    _displayName=displayName;
    _description=description;
    _enabledByDefault=enabledBydefault;
    return self;
}

@end

#pragma mark Plugin
@implementation Plugin
{
    __strong UIView* _view;
}

@synthesize _device;
@synthesize _pluginInfo;

+ (id) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [super allocWithZone:zone];
    });
}

- (id)copyWithZone:(NSZone *)zone;{
    return self;
}

- (BOOL) onCreate
{
    return true;
}

- (void) onDestroy
{
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    return false;
}

- (UIView*) getView
{
    return _view;
}

@end
