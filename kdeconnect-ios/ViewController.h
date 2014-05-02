//
//  ViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
	IBOutlet UIWebView *webView;
}
//- (IBAction)send:(id)sender;

- (IBAction)send:(id)sender;
- (void)logMessage:(NSString *)msg;
@end