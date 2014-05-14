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
        NSDictionary* list=[_bg getVisibleDevices];
        for (NSString* deviceName in [list allValues]) {
            [self logMessage:FORMAT(@"Visible device:%@",deviceName)];
        }
    }
}

- (IBAction)pair:(id)sender {
    NSDictionary* list=[_bg getVisibleDevices];
    for (NSString* deviceId in [list allKeys]) {
        [self logMessage:FORMAT(@"pair device:%@",[list valueForKey:deviceId])];
        [_bg pairDevice:deviceId];
    }
}

- (IBAction)ping:(id)sender {
}

-(void) onPairRequest:(NSString*)deviceID
{
    NSDictionary* list=[_bg getVisibleDevices];
    [self logMessage:FORMAT(@"request pairing:%@",[list valueForKey:deviceID])];
}

- (void) onPairTimeout:(NSString*)deviceID
{
    NSDictionary* list=[_bg getVisibleDevices];
    [self logMessage:FORMAT(@"pairing timeout: %@",[list valueForKey:deviceID])];
}

- (void) onPairSuccess:(NSString*)deviceID
{
    NSDictionary* list=[_bg getVisibleDevices];

    [self logMessage:FORMAT(@"pairing success:%@",[list valueForKey:deviceID])];
}

- (void) onPairRejected:(NSString*)deviceID
{
    NSDictionary* list=[_bg getVisibleDevices];

    [self logMessage:FORMAT(@"pairing rejected:%@",[list valueForKey:deviceID])];
}


@end
