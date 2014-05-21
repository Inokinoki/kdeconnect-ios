//
//  PluginFactory.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "Plugin.h"
#import "GCDSingleton.h"

@class Device;
@class NetworkPackage;
@class Plugin;
@class Ping;

@protocol pluginFactoryDelegate <NSObject>
@optional
@end

@interface PluginFactory : NSObject

+ (id) sharedInstance;
- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName;
- (NSArray*) getAvailablePlugins;

@end











