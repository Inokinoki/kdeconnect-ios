//
//  PluginFactory.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "PluginFactory.h"
#import "Ping.h"

__strong static NSMutableDictionary* _availablePlugins;
__strong static PluginFactory* _instance;

@implementation PluginFactory

+ (PluginFactory*) getInstance
{
    if (!_instance) {
        _instance=[[PluginFactory alloc] init];
        _availablePlugins=[NSMutableDictionary dictionaryWithCapacity:1];
        [_instance registerPlugins];
    }
    return _instance;
}

- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName
{
    Plugin* plugin=[_availablePlugins valueForKey:pluginName];
    if (plugin) {
        [plugin set_device:device];
    }
    return plugin;
}

- (NSArray*) getAvailablePlugins
{
    return [_availablePlugins allKeys];
}

- (void) registerPlugins
{
    Ping* pingPlugin=[Ping getInstance];[_availablePlugins setValue:pingPlugin forKey:[[pingPlugin _pluginInfo] _pluginName]];
    
}


@end
