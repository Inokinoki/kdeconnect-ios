//
//  PluginFactory.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "PluginFactory.h"
#import "Ping.h"

@implementation PluginFactory
{
    __strong NSMutableDictionary* _availablePlugins;
}

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

- (id) init
{
    _availablePlugins=[NSMutableDictionary dictionaryWithCapacity:1];
    [self registerPlugins];
    return self;
}

- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName
{
    NSLog(@"pluginfactory instatiate plugin for device");
    Plugin* plugin=[_availablePlugins valueForKey:pluginName];
    if (plugin) {
        [plugin set_device:device];
    }
    return plugin;
}

- (void) deletePlugins
{
    NSLog(@"pluginfactory delete all plugins");
    for (Plugin* plugin in [_availablePlugins allValues]) {
        [plugin set_device:nil];
        [plugin set_pluginDelegate:nil];
    }
}

- (NSArray*) getAvailablePlugins
{
    NSLog(@"pluginfactory get available plugins");
    return [_availablePlugins allKeys];
}

- (Plugin*) getPlugin:(NSString*)pluginName
{
    return [_availablePlugins valueForKey:pluginName];
}

- (void) registerPlugins
{
    NSLog(@"pluginfactory register plugins");
    Ping* pingPlugin=[Ping sharedInstance];[_availablePlugins setValue:pingPlugin forKey:[[pingPlugin _pluginInfo] _pluginName]];
    
}

@end
