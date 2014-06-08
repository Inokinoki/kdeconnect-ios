//
//  DeviceViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"
@interface DeviceViewController : UIViewController<IASKSettingsDelegate,UITextViewDelegate>

@property(strong,nonatomic)NSString* _deviceId;

@end
