//
//  ViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkPackage.h"
#import "BackgroundService.h"
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
@interface ViewController : UIViewController<backgroundServiceDelegate>
{
	IBOutlet UIWebView *webView;
}


@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property (weak, nonatomic) IBOutlet UIButton *pair;
- (IBAction)start_discovery:(id)sender;
- (IBAction)stop_discovery:(id)sender;
- (IBAction)pair:(id)sender;
- (IBAction)ping:(id)sender;
- (void)logMessage:(NSString *)msg;
@end