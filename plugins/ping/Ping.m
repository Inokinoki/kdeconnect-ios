//
//  Ping.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Ping.h"

__strong static Ping* _instance;
@implementation Ping

@synthesize _device;
@synthesize _pluginInfo;

- (id) init
{
    if([super init]){
        
    }
    return self;
}

+ (Ping*) getInstance
{
    if (!_instance) {
        _instance=[[Ping alloc] init];
    }
    return _instance;
}

- (void) loadPluginInfo
{
    PluginInfo* pluginInfo=[[PluginInfo alloc] initWithInfos:@"PingPlugin" displayName:@"Ping" description:@"Ping" enabledByDefault:true];
    [_instance set_pluginInfo:pluginInfo];
}

- (BOOL) onCreate
{
    return true;
}

- (void) onDestroy
{
    
}

- (BOOL) onPackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        
        return true;
    }
    
    return false;
}

- (void) dealloc
{

}

@end