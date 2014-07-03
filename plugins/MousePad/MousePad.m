 //
//  MousePad.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MousePad.h"
#import "MousePadViewController.h"

@interface MousePad()
{
    float _x,_y;
}
@property(nonatomic) UIView* _view;
@property(nonatomic) MousePadViewController* _mousePadController;
@property(nonatomic) UIViewController* _deviceViewController;
@end

@implementation MousePad

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _view;
@synthesize _mousePadController;
@synthesize _deviceViewController;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"MousePad" displayName:@"MousePad" description:@"MousePad" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
        _mousePadController=nil;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        _x=screenSize.width/2;
        _y=screenSize.height/2;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        NSLog(@"mouse pad receive a package");
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"mouse pad plugin get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"Mouse Pad"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"open touch pad" forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(openPad:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    else{
        _view=nil;
    }
    _deviceViewController=vc;
    return _view;
}

- (void) stop
{
    
}

- (void) openPad:(id)sender
{
    if (!_mousePadController) {
        _mousePadController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MousePadViewController"];
        [_mousePadController setPlugin:self];
        [_mousePadController setTitle:@"Mouse Pad"];
    }
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:_mousePadController];
    [_deviceViewController presentViewController:aNavController animated:YES completion:nil];
}

#pragma mark mouse actions

- (void) setStartPointWithX:(double)x Y:(double)y
{
    _x=x;
    _y=y;
}

- (void) sendPointsWithX:(double)x Y:(double)y
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [[np _Body] setValue:[NSNumber numberWithDouble:x-_x] forKey:@"dx"];
    [[np _Body] setValue:[NSNumber numberWithDouble:y-_y] forKey:@"dy"];
    _x=x;
    _y=y;
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

- (void) sendSingleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [[np _Body] setValue:[NSNumber numberWithBool:YES] forKey:@"singleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

@end
