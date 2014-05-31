//
//  Ping.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Ping.h"

@implementation Ping
{
    __strong UIView* _view;
}

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"PingPlugin" displayName:@"Ping" description:@"Ping" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    NSLog(@"ping plugin receive a package");
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle:@"Ping"
              message:FORMAT(@"Ping from device: %@ ",[_device _name])
              delegate:nil
              cancelButtonTitle:@"ok"
              otherButtonTitles:nil,nil] show];
        });
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"ping plugin get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"Ping"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Send Ping to Device" forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(sendPing:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    else{
        _view=nil;
    }
    return _view;
}

- (void) sendPing:(id)sender
{
    if (!_device) {
        NSLog(@"no registered device");
        return;
    }
    NSLog(@"send ping to %@",[_device _id]);
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PING];
    [_device sendPackage:np tag:PACKAGE_TAG_PING];
}

@end
