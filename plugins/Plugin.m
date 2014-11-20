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

#import "Plugin.h"
#import "Device.h"
#pragma mark PluginInfo
@implementation PluginInfo

@synthesize _pluginName;
@synthesize _displayName;
@synthesize _description;
@synthesize _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault
{
    if ((self=[super init])) {
        _pluginName=pluginName;
        _displayName=displayName;
        _description=description;
        _enabledByDefault=enabledBydefault;
    }
    return self;
}

@end

#pragma mark Plugin
@implementation Plugin
- (BOOL) onDevicePackageReceived:(NetworkPackage*)np
{
    return false;
}

- (void) stop
{
    
}

- (UIView*) getView:(UIViewController*)vc
{
    return nil;
}
@end
