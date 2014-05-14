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
@synthesize _pluginDelegate;

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

- (Plugin*) init
{
    PluginInfo* pluginInfo=[[PluginInfo alloc] initWithInfos:@"PingPlugin" displayName:@"Ping" description:@"Ping" enabledByDefault:true];
    _pluginInfo=pluginInfo;
    _pluginDelegate=nil;
    
    return self;
}

- (BOOL) onPackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        
        return true;
    }
    
    return false;
}

@end
