//
//  Ping.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Ping.h"
#import "device.h"
#import <AudioToolbox/AudioServices.h>

@interface Ping()
@property(nonatomic) UIView* _view;
@end

@implementation Ping

@synthesize _device;
@synthesize _pluginDelegate;
@synthesize _view;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        NSLog(@"ping plugin receive a package");
        
        // local notification
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = FORMAT(@"%@: Ping!",[_device _name]);
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName=UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber+=1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(sendPing:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    else{
        _view=nil;
    }
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Ping" displayName:@"Ping" description:@"Ping" enabledByDefault:true];
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
