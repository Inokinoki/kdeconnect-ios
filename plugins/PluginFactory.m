//
//  PluginFactory.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  
//

#import "PluginFactory.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "Device.h"
#import "Ping.h"
#import "MPRIS.h"
#import "Share.h"
#import "ClipBoard.h"
#import "MousePad.h"
#import "Battery.h"
#import "Calendar.h"
#import "Reminder.h"
#import "Contact.h"

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
        NSMutableDictionary* appDefaults=[NSMutableDictionary dictionaryWithCapacity:1];
        for (NSString* pluginName in [_availablePlugins allKeys]) {
            [appDefaults setObject:[NSNumber numberWithBool:YES] forKey:pluginName];
        }
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    }
    return self;
}

- (void) dealloc
{
    
}

- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName
{
    IASKSettingsStoreUserDefaults* setting=[[IASKSettingsStoreUserDefaults alloc] init];
    if ([setting objectForKey:pluginName]!=nil && ![setting boolForKey:pluginName]) {
        return nil;
    }

    //NSLog(@"pluginfactory instatiate plugin for device");
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
    //NSLog(@"pluginfactory get available plugins");
    return [_availablePlugins allKeys];
}

- (void) registerPlugins
{
    //NSLog(@"pluginfactory register plugins");
    
    [_availablePlugins setValue:[Ping class] forKey:[[Ping getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[MPRIS class] forKey:[[MPRIS getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[Share class] forKey:[[Share getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[ClipBoard class] forKey:[[ClipBoard getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[MousePad class] forKey:[[MousePad getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[Battery class] forKeyPath:[[Battery getPluginInfo]_pluginName]];
    [_availablePlugins setValue:[Calendar class] forKeyPath:[[Calendar getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[Reminder class] forKey:[[Reminder getPluginInfo] _pluginName]];
    [_availablePlugins setValue:[Contact class] forKeyPath:[[Contact getPluginInfo]_pluginName]];
}

@end
