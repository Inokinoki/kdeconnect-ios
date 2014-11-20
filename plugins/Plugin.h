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

#import <Foundation/Foundation.h>

@class Device;
@class NetworkPackage;

#pragma mark PluginInfo
@interface PluginInfo : NSObject

@property(nonatomic,readonly) NSString* _pluginName;
@property(nonatomic,readonly) NSString* _displayName;
@property(nonatomic,readonly) NSString* _description;
@property(nonatomic) BOOL _enabledByDefault;

- (PluginInfo*) initWithInfos:(NSString*)pluginName displayName:(NSString*)displayName description:(NSString*)description enabledByDefault:(BOOL)enabledBydefault;

@end

#pragma mark Plugin
@interface Plugin : NSObject

@property(nonatomic) Device* _device;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (void) stop;
- (UIView*) getView:(UIViewController*)vc;
- (void) sentPercentage:(short)percentage tag:(long)tag;
+ (PluginInfo*) getPluginInfo;

@end
