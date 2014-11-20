//Copyright 5/6/14  YANG Qiao yangqiao0505@me.com
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

#import "ClipBoard.h"
#import "device.h"
#import <AudioToolbox/AudioServices.h>
@interface ClipBoard()
{
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
        //NSLog(@"ClipBoard plugin receive a package");
        NSString *str = [np objectForKey:@"content"];
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        //NSLog(@"str %@ copied to pasteboard ",str);
        if (![str isEqualToString:pastboardContents]) {
            pastboardContents=str;
        }
        [pb setString:pastboardContents];
        return true;
    }
    return false;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"ClipBoard" displayName:NSLocalizedString(@"ClipBoard",nil) description:NSLocalizedString(@"ClipBoard",nil) enabledByDefault:true];

}

- (void) grabClipboard
{
    // Do the task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        while(1)
        {
            if (![pastboardContents isEqualToString:[UIPasteboard generalPasteboard].string])
            {
                pastboardContents = [UIPasteboard generalPasteboard].string;
                if (!pastboardContents) continue;
                //NSLog(@"Pasteboard Contents: %@", pastboardContents);
                NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CLIPBOARD];
                [np setObject:pastboardContents forKey:@"content"];
                [_device sendPackage:np tag:PACKAGE_TAG_CLIPBOARD];
            }
            
            // Wait some time before going to the beginning of the loop
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void) stop
{
}

- (void) dealloc
{
    [self stop];
}
@end
