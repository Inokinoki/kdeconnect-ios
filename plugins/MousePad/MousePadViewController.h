//
//  MousePadViewController.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  
//

#import <UIKit/UIKit.h>
@class MousePad;

@interface MousePadViewController : UIViewController<UIGestureRecognizerDelegate>

- (void) setPlugin:(MousePad*)mousePadPlugin;

@end
