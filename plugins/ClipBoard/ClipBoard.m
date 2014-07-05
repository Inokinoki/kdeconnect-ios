//
//  ClipBoard.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/5/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "ClipBoard.h"
#import "device.h"
#import <AudioToolbox/AudioServices.h>
@interface ClipBoard()
{
    __block UIBackgroundTaskIdentifier task;
    NSString *pastboardContents;
}

@end

@implementation ClipBoard

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"ClipBoard" displayName:@"ClipBoard" description:@"ClipBoard" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        pastboardContents = [UIPasteboard generalPasteboard].string;
        [self grabClipboard];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_CLIPBOARD]) {
        NSLog(@"ClipBoard plugin receive a package");
        NSString *str = [[np _Body] valueForKey:@"content"];
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        NSLog(@"str %@ copied to pasteboard ",str);
        if (![str isEqualToString:pastboardContents]) {
            pastboardContents=str;
        }
        [pb setString:pastboardContents];
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"ClipBoard plugin get view");
    return nil;
}

- (void) grabClipboard
{
    UIApplication* application=[UIApplication sharedApplication];
    
    task = [application beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"System terminated background task");
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = @"System terminated background task";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [application endBackgroundTask:task];
    }];
    
    // If the system refuses to allow the task return
    if (task == UIBackgroundTaskInvalid)
    {
        NSLog(@"System refuses to allow background task");
        return;
    }
    
    // Do the task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        while(1)
        {
            if (![pastboardContents isEqualToString:[UIPasteboard generalPasteboard].string])
            {
                pastboardContents = [UIPasteboard generalPasteboard].string;
                if (!pastboardContents) continue;
                NSLog(@"Pasteboard Contents: %@", pastboardContents);
                NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CLIPBOARD];
                [[np _Body] setObject:pastboardContents forKey:@"content"];
                [_device sendPackage:np tag:PACKAGE_TAG_CLIPBOARD];
            }
            
            // Wait some time before going to the beginning of the loop
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void) stop
{
    UIApplication* application=[UIApplication sharedApplication];
    [application endBackgroundTask:task];
}

- (void) dealloc
{
    [self stop];
}
@end
