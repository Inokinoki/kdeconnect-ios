//
//  MPRISViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  
//

#import <UIKit/UIKit.h>
#import "MPRIS.h"

@interface MPRISViewController : UIViewController <MPRISDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

- (void) setPlugin:(MPRIS*)mprisPlugin;

@end
