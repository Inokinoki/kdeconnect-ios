//
//  Plugin.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "GCDSingleton.h"
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@class Device;
@class NetworkPackage;

@protocol pluginDelegate <NSObject>
@optional
@end

#pragma mark PluginInfo
@interface PluginInfo : NSObject

@property(strong,nonatomic,readonly) NSString* _pluginName;
@property(strong,nonatomic,readonly) NSString* _displayName;
@property(strong,nonatomic,readonly) NSString* _description;
@property(nonatomic) BOOL _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault;

@end

#pragma mark Plugin
@interface Plugin : NSObject

@property(strong,nonatomic) Device* _device;
@property(strong,nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic,assign) id _pluginDelegate;

+ (id) sharedInstance;
- (BOOL) onCreate;
- (void) onDestroy;
- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView;

@end

