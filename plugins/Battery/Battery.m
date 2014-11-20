//Copyright 6/7/14  YANG Qiao yangqiao0505@me.com
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


#import "Battery.h"
#import "Device.h"

@interface Battery()
@property(nonatomic)NetworkPackage* _prePackage;
@end

@implementation Battery

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _prePackage;
- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _prePackage=nil;
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_BATTERY]) {
        //NSLog(@"Battery plugin receive a package");
        int batteryLevel = [UIDevice currentDevice].batteryLevel*100;
        UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
        BOOL ischarging=currentState==UIDeviceBatteryStateCharging;
        int thresholdEvent = batteryLevel<10? ThresholdBatteryLow : ThresholdNone;
        if (batteryLevel < 0) {
            // -1.0 means battery state is UIDeviceBatteryStateUnknown
            return NO;
        }
        if (_prePackage!=nil
            && ischarging== [_prePackage boolForKey:@"isCharging"]
            && batteryLevel== [_prePackage integerForKey:@"currentCharge"]
            && thresholdEvent==[_prePackage integerForKey:@"thresholdEvent"]) {
            
        }
        else{
            NetworkPackage* np2=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_BATTERY];
            [np2 setBool:ischarging forKey:@"isCharging"];
            [np2 setInteger:batteryLevel forKey:@"currentCharge"];
            [np2 setInteger:thresholdEvent forKey:@"thresholdEvent"];
            [_device sendPackage:np2 tag:PACKAGE_TAG_BATTERY];
            _prePackage=np2;
        }
        return true;
    }
    return false;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Battery" displayName:NSLocalizedString(@"Battery",nil) description:NSLocalizedString(@"Battery",nil) enabledByDefault:true];
}

@end
