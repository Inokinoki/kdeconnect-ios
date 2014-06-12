//
//  Plugin.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@class Device;
@class NetworkPackage;

@protocol pluginDelegate <NSObject>
@optional
@end

#pragma mark PluginInfo
@interface PluginInfo : NSObject

@property(nonatomic,readonly) NSString* _pluginName;
@property(nonatomic,readonly) NSString* _displayName;
@property(nonatomic,readonly) NSString* _description;
@property(nonatomic) BOOL _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault;

@end

#pragma mark Plugin
@interface Plugin : NSObject

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (void) stop;
- (UIView*) getView:(UIViewController*)vc;

@end

