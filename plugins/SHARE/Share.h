//
//  Share.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/4/14.
//  
//

#import "Plugin.h"
@class PluginInfo;
@class Plugin;

@interface Share : Plugin <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property(nonatomic) Device* _device;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
- (void) sentPercentage:(short)percentage tag:(long)tag;
+ (PluginInfo*) getPluginInfo;
@end