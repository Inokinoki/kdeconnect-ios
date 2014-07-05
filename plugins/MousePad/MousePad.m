 //
//  MousePad.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MousePad.h"
#import "MousePadViewController.h"
#import "device.h"

@interface MousePad()
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
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
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

- (void) sendPointsWithDx:(double)x Dy:(double)y
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setDouble:x forKey:@"dx"];
    [np setDouble:y forKey:@"dy"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

- (void) sendSingleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"singleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

- (void) sendDoubleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"doubleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendMiddleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"middleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendRightClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"rightclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendScrollWithDx:(double)x Dy:(double)y
{
    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    x/=screenSize.width;
    y/=screenSize.height;
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"scroll"];
    [np setDouble:x forKey:@"dx"];
    [np setDouble:y forKey:@"dy"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
@end
