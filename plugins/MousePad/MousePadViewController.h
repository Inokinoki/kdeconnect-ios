//
//  MousePadViewController.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MousePad;

@interface MousePadViewController : UIViewController<UIGestureRecognizerDelegate>

- (void) setPlugin:(MousePad*)mousePadPlugin;

@end
