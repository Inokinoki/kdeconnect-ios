//
//  Contact.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/17/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Plugin.h"
#import <AddressBookUI/ABPeoplePickerNavigationController.h>

@interface Contact : Plugin <UIActionSheetDelegate,ABPeoplePickerNavigationControllerDelegate>

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
+ (PluginInfo*) getPluginInfo;

@end
