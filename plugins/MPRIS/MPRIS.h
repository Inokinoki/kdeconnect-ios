//Copyright 22/5/14  YANG Qiao yangqiao0505@me.com
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

@protocol MPRISDelegate<NSObject>
@optional
- (void) onPlayerStatusUpdated;
- (void) onPlayerListUpdated;
@end

@interface MPRIS : Plugin

@property(nonatomic) Device* _device;
@property(nonatomic) PluginInfo* _pluginInfo;
@property(nonatomic) id _pluginDelegate;

- (BOOL) onDevicePackageReceived:(NetworkPackage*)np;
- (UIView*) getView:(UIViewController*)vc;
+ (PluginInfo*) getPluginInfo;

- (void) sendAction:(NSString*)action;
- (void) setVolume:(NSUInteger)volume;
- (void) seek:(NSInteger)offset;
- (NSString*) getCurrentSong;
- (NSArray*) getPlayerList;
- (NSUInteger) getVolume;
- (void) setPlayer:(NSString*)player;
- (BOOL) isPlaying;

- (void) requestPlayerList;
- (void) requestPlayerStatus;

@end

