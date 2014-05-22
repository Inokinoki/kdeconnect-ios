//
//  MPRIS.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MPRIS.h"
#import "MPRISViewController.h"
#import "DeviceViewController.h"

@implementation MPRIS
{
    __strong UIView* _view;
    MPRISViewController* _mprisViewController;
    DeviceViewController* _deviceViewController;
}

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"MPRISPlugin" displayName:@"MPRIS" description:@"MPRIS" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
        _mprisViewController=nil;
        _deviceViewController=nil;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    NSLog(@"mpris receive a package");
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"mpris get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,64,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"MPRIS"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Open MPRIS Panel" forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(openPanel:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    _deviceViewController=vc;
    return _view;
}

- (void) openPanel:(id)sender
{
    _mprisViewController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MPRISViewController"];
    [_mprisViewController setTitle:FORMAT(@"MPRIS Panel for %@",[_device _name])];
    
    [_deviceViewController.navigationController presentViewController:_mprisViewController animated:YES completion:^(void){}];
    
}

@end