//
//  MPRIS.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"

@class PluginInfo;
@class Plugin;

@protocol MPRISDelegate<NSObject>
@optional
- (void) onPlayerStatusUpdated;
- (void) onPlayerListUpdated;
@end

@interface MPRIS : Plugin

@property(strong,nonatomic) Device* _device;
@property(strong,nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic,assign) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
- (void) sendAction:(NSString*)action;
- (void) setVolume:(NSUInteger)volume;
- (void) seek:(NSInteger)offset;
- (NSString*) getCurrentSong;
- (NSArray*) getPlayerList;
- (NSUInteger) getVolume;
- (void) setPlayer:(NSString*)player;
- (BOOL) isPlaying;

- (void) requestPlayerList;
- (void) requestPlayerStatus;

@end

