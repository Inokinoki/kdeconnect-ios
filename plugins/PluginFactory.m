//
//  PluginFactory.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "PluginFactory.h"
#import "Ping.h"
#import "MPRIS.h"
#import "Share.h"
#import "ClipBoard.h"

@interface PluginFactory()
@property(nonatomic) NSMutableDictionary* _availablePlugins;
@end

@implementation PluginFactory

@synthesize _availablePlugins;

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
    if ((self=[super init])) {
        _availablePlugins=[NSMutableDictionary dictionaryWithCapacity:1];
        [self registerPlugins];
    }
    return self;
}

- (void) dealloc
{
    
}

- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName
{
    NSLog(@"pluginfactory instatiate plugin for device");
    Class pluginClass=[_availablePlugins valueForKey:pluginName];
    Plugin* plugin;
    if (pluginClass) {
        plugin=[[pluginClass alloc] init];
        [plugin set_device:device];
    }
    return plugin;
}

- (NSArray*) getAvailablePlugins
{
    NSLog(@"pluginfactory get available plugins");
    return [_availablePlugins allKeys];
}

- (void) registerPlugins
{
    NSLog(@"pluginfactory register plugins");
    Ping* pingPlugin=[[Ping alloc] init];
    MPRIS* mprisPlugin=[[MPRIS alloc] init];
    Share* sharePlugin=[[Share alloc] init];
    ClipBoard* clipboardPlugin=[[ClipBoard alloc] init];
    [_availablePlugins setValue:[Ping class] forKey:[[[pingPlugin _pluginInfo] _pluginName] copy]];
    [_availablePlugins setValue:[MPRIS class] forKey:[[[mprisPlugin _pluginInfo] _pluginName] copy]];
    [_availablePlugins setValue:[Share class] forKey:[[[sharePlugin _pluginInfo] _pluginName] copy]];
    [_availablePlugins setValue:[ClipBoard class] forKey:[[[clipboardPlugin _pluginInfo] _pluginName] copy]];
}

@end
