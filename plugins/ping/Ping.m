//Copyright 11/5/14  YANG Qiao yangqiao0505@me.com
//kdeconnect is distributed under two licenses.
//
//* The Mozilla Public License (MPL) v2.0
//
//or
//
//* The General Public License (GPL) v2.1
//
//----------------------------------------------------------------------
//
//Software distributed under these licenses is distributed on an "AS
//IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
//implied. See the License for the specific language governing rights
//and limitations under the License.
//kdeconnect is distributed under both the GPL and the MPL. The MPL
//notice, reproduced below, covers the use of either of the licenses.
//
//----------------------------------------------------------------------

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
        //NSLog(@"ping plugin receive a package");
        
        // local notification
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = FORMAT(NSLocalizedString(@"%@: Ping!",nil),[_device _name]);
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
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,600, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 30)];
        [label setText:NSLocalizedString(@"Ping",nil)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"Send Ping to Device",nil) forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(sendPing:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
        if (isPad) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-100-[button]-100-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        if (isPhone) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[button]-10-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        label.translatesAutoresizingMaskIntoConstraints=NO;
        button.translatesAutoresizingMaskIntoConstraints=NO;
    }
    else{
        _view=nil;
    }
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Ping" displayName:NSLocalizedString(@"Ping",nil) description:NSLocalizedString(@"Ping",nil) enabledByDefault:true];
}


- (void) sendPing:(id)sender
{
    if (!_device) {
        //NSLog(@"no registered device");
        return;
    }
    //NSLog(@"send ping to %@",[_device _id]);
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PING];
    [_device sendPackage:np tag:PACKAGE_TAG_PING];
}

@end
