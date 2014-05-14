//
//  ViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
{
    NSMutableString *_log;
    BackgroundService* _bg;
    Device* _pairRequest_device;
}

@end


@implementation ViewController

@synthesize start;
@synthesize pause;

- (void)viewDidLoad
{
	[super viewDidLoad];
    _log = [[NSMutableString alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillShow:)
	                                             name:UIKeyboardWillShowNotification
	                                           object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillHide:)
	                                             name:UIKeyboardWillHideNotification
	                                           object:nil];
    [self logInfo:FORMAT(@"Ready")];
    NSLog(@"hello");
    
    BackgroundService* bg=[BackgroundService sharedInstance];
    NSLog(@"A:%@",bg);
    NSLog(@"B:%@",[[BackgroundService alloc] init]);
    NSLog(@"C:%@",[bg copy]);
    
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getKeyboardHeight:(float *)keyboardHeightPtr
        animationDuration:(double *)animationDurationPtr
                     from:(NSNotification *)notification
{
	float keyboardHeight;
	double animationDuration;
	
	// UIKeyboardCenterBeginUserInfoKey:
	// The key for an NSValue object containing a CGRect
	// that identifies the start frame of the keyboard in screen coordinates.
	
	CGRect beginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect endRect   = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		keyboardHeight = ABS(beginRect.origin.x - endRect.origin.x);
	}
	else
	{
		keyboardHeight = ABS(beginRect.origin.y - endRect.origin.y);
	}
	
	// UIKeyboardAnimationDurationUserInfoKey
	// The key for an NSValue object containing a double that identifies the duration of the animation in seconds.
	
	animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	if (keyboardHeightPtr) *keyboardHeightPtr = keyboardHeight;
	if (animationDurationPtr) *animationDurationPtr = animationDuration;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	float keyboardHeight = 0.0F;
	double animationDuration = 0.0;
	
	[self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
	
	CGRect webViewFrame = webView.frame;
	webViewFrame.size.height -= keyboardHeight;
	
	void (^animationBlock)(void) = ^{
		
		webView.frame = webViewFrame;
	};
	
	UIViewAnimationOptions options = 0;
	
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:options
	                 animations:animationBlock
	                 completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	float keyboardHeight = 0.0F;
	double animationDuration = 0.0;
	
	[self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
	
	CGRect webViewFrame = webView.frame;
	webViewFrame.size.height += keyboardHeight;
	
	void (^animationBlock)(void) = ^{
		
		webView.frame = webViewFrame;
	};
	
	UIViewAnimationOptions options = 0;
	
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:options
	                 animations:animationBlock
	                 completion:NULL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)sender
{
	NSString *scrollToBottom = @"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);";
	
    [sender stringByEvaluatingJavaScriptFromString:scrollToBottom];
}

- (void)logError:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#B40404\">";
	NSString *suffix = @"</font><br/>";
	
	[_log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", _log];
	[webView loadHTMLString:html baseURL:nil];
}

- (void)logInfo:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#6A0888\">";
	NSString *suffix = @"</font><br/>";
	
	[_log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", _log];
	[webView loadHTMLString:html baseURL:nil];
}

- (void)logMessage:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#000000\">";
	NSString *suffix = @"</font><br/>";
	
	[_log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>%@</body></html>", _log];
	[webView loadHTMLString:html baseURL:nil];
}

- (IBAction)start_discovery:(id)sender
{
    if(_bg==nil) _bg=[BackgroundService sharedInstance];
    [_bg set_backgroundServiceDelegate:self];
    [_bg startDiscovery];
    [self logMessage:FORMAT(@"start discovery")];
}
- (IBAction)stop_discovery:(id)sender
{
    if (_bg) {
        [_bg stopDiscovery];
        NSArray* list=[_bg _visibleDevices];
        for (Device* device in list) {
            [self logMessage:FORMAT(@"Visible device:%@",[device _name])];
        }
    }
    _pairRequest_device=nil;
}

- (IBAction)pair:(id)sender {
    NSArray* list=[_bg _visibleDevices];
    for (Device* device in list) {
        [self logMessage:FORMAT(@"pairing device:%@",[device _name])];
        [_bg pairDevice:device];
    }
}

- (IBAction)ping:(id)sender {
    NSArray* list=[_bg _visibleDevices];
    for (Device* device in list) {
        [self logMessage:FORMAT(@"ping device:%@",[device _name])];
        [_bg pingDevice:device];
    }
    
}

-(void) onPairRequest:(Device*)device
{
    [self logMessage:FORMAT(@"request pairing:%@",[device _name])];
    [self showConfirmationAlert];
    _pairRequest_device=device;
}

- (void) onPairTimeout:(Device*)device
{
    [self logMessage:FORMAT(@"pairing timeout: %@",[device _name])];
}

- (void) onPairSuccess:(Device*)device
{
    [self logMessage:FORMAT(@"pairing success:%@",[device _name])];
}

- (void) onPairRejected:(Device*)device
{
    [self logMessage:FORMAT(@"pairing rejected:%@",[device _name])];
}

- (void) showConfirmationAlert
{
    // A quick and dirty popup, displayed only once
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"HasSeenPopup"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Question"
                                                       message:@"Do you like cats?"
                                                      delegate:self
                                             cancelButtonTitle:@"No"
                                             otherButtonTitles:@"Yes",nil];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"HasSeenPopup"];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// 0 = Tapped yes
	if (buttonIndex == 0)
	{
        [_pairRequest_device acceptPairing];
	}
    else
    {
        [_pairRequest_device rejectPairing];
    }
}

@end
