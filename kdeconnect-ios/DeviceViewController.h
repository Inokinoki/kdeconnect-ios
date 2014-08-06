//
//  DeviceViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  
//

#import <UIKit/UIKit.h>
#import "AppSettingViewController.h"
@interface DeviceViewController : UIViewController<IASKSettingsDelegate,UITextViewDelegate>

@property(nonatomic)NSString* _deviceId;

@end
