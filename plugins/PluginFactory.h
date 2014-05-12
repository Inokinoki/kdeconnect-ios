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

@class Device;
@class NetworkPackage;
@class Plugin;

@protocol pluginFactoryDelegate <NSObject>
@optional
@end

@interface PluginFactory : NSObject

@property(strong,nonatomic,readonly)NSMutableDictionary* _availablePlugins;

- (Plugin*) instantiatePluginForDevice:(Device*)device pluginName:(NSString*)pluginName;

@end











