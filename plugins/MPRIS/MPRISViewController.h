//
//  MPRISViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPRIS.h"

@interface MPRISViewController : UIViewController<mprisDelegate>
@property (strong, nonatomic) IBOutlet UISlider *_volumeSlider;

- (void) setPlugin:(MPRIS*)mprisPlugin;

@end
