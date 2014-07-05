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

@interface Share : Plugin <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (void) stop;
- (UIView*) getView:(UIViewController*)vc;
- (void) sentPercentage:(short)percentage tag:(long)tag;

@end