//
//  DeviceViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSettingViewController.h"
@interface DeviceViewController : UIViewController<IASKSettingsDelegate,UITextViewDelegate>

@property(nonatomic)NSString* _deviceId;

@end
