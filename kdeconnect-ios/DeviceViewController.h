//
//  DeviceViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  
//

#import <UIKit/UIKit.h>
#import "AppSettingViewController.h"
@interface DeviceViewController : UIViewController<IASKSettingsDelegate,UITextViewDelegate,UISplitViewControllerDelegate>

@property(nonatomic)NSString* _deviceId;

- (void) updateView;
@end
