//
//  Share.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/4/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"
@class PluginInfo;
@class Plugin;

@protocol ShareDelegate<NSObject>
@optional
@end

@interface Share : Plugin <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;

@end