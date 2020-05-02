//Copyright 2/5/14  YANG Qiao yangqiao0505@me.com
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
//---------------------------------------------------------------------

#import "BackgroundService.h"
#import "LanLinkProvider.h"
#import "SettingsStore.h"
#import "PluginFactory.h"
#import "SecKeyWrapper.h"
#import "KeychainItemWrapper.h"

@interface BackgroundService()
@property(nonatomic)NSMutableArray* _linkProviders;
@property(nonatomic)NSMutableDictionary* _devices;
@property(nonatomic)NSMutableArray* _visibleDevices;
@property(nonatomic)SettingsStore* _settings;
@end

@implementation BackgroundService

@synthesize _backgroundServiceDelegate;
@synthesize _devices;
@synthesize _linkProviders;
@synthesize _visibleDevices;
@synthesize _settings;

+ (id) sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [super allocWithZone:zone];
    });
}

- (id)copyWithZone:(NSZone *)zone;{
    return self;
}

- (id) init
{
    if ((self=[super init])) {
        
        /*if (![[SecKeyWrapper sharedWrapper] getPublicKeyBits]) {
            NSLog(@"Generating keys\n");
            [[SecKeyWrapper sharedWrapper] generateKeyPair:2048];
            [[SecKeyWrapper sharedWrapper] generateCertificate];
        }*/
        
        /*NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                                      (__bridge id)kSecMatchLimitAll, (__bridge id)kSecMatchLimit,
                                      nil];
        NSArray *secItemClasses = [NSArray arrayWithObjects:
                                   (__bridge id)kSecClassGenericPassword,
                                   (__bridge id)kSecClassInternetPassword,
                                   (__bridge id)kSecClassCertificate,
                                   (__bridge id)kSecClassKey,
                                   (__bridge id)kSecClassIdentity,
                                   nil];
        for (id secItemClass in secItemClasses) {
            [query setObject:secItemClass forKey:(__bridge id)kSecClass];
            
            CFTypeRef result = NULL;
            SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            if (result != NULL) CFRelease(result);
            
            NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
            SecItemDelete((__bridge CFDictionaryRef)spec);
        }
        //if (![[SecKeyWrapper sharedWrapper] getCertificate]) {
        //    NSLog(@"Generating certificates\n");
        //    [[SecKeyWrapper sharedWrapper] generateCertificate];
        //}
         */
        
        //NSLog(@"Pub Key: %@\n", [[SecKeyWrapper sharedWrapper] getPublicKeyBits]);
        //NSLog(@"Priv Key: %@\n", [[SecKeyWrapper sharedWrapper] getPrivateKeyRef]);
        //[[SecKeyWrapper sharedWrapper] generateCertificate];
        //NSLog(@"Certificate: %@", [[SecKeyWrapper sharedWrapper] getCertificate]);
        
        _linkProviders=[NSMutableArray arrayWithCapacity:1];
        _devices=[NSMutableDictionary dictionaryWithCapacity:1];
        _visibleDevices=[NSMutableArray arrayWithCapacity:1];
        _settings=[[SettingsStore alloc] initWithPath:KDECONNECT_REMEMBERED_DEV_FILE_PATH];
        [self registerLinkProviders];
        [self loadRemenberedDevices];
        [PluginFactory sharedInstance];
    }
    return self;
}

- (void) loadRemenberedDevices
{
    for (NSString* deviceId in [_settings getAllKeys]) {
        Device* device=[[Device alloc] init:deviceId setDelegate:self];
        [_devices setObject:device forKey:deviceId];
    }
}
- (void) registerLinkProviders
{
    //NSLog(@"bg register linkproviders");
    // TO-DO  read setting for linkProvider registeration
    LanLinkProvider* linkProvider=[[LanLinkProvider alloc] initWithDelegate:self];
    [_linkProviders addObject:linkProvider];
}

- (void) startDiscovery
{
    NSLog(@"bg start Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStart];
    }
}

- (void) refreshDiscovery
{
    //NSLog(@"bg refresh Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onRefresh];
    }
}

- (void) stopDiscovery
{
    //NSLog(@"bg stop Discovery");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onStop];
    }
}

- (NSDictionary*) getDevicesLists
{
    //NSLog(@"bg get devices lists");
    NSMutableDictionary* _visibleDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary* _connectedDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary* _rememberedDevicesList=[NSMutableDictionary dictionaryWithCapacity:1];
    for (Device* device in [_devices allValues]) {
        if (![device isReachable]) {
            [_rememberedDevicesList setValue:[device _name] forKey:[device _id]];
        }
        else if([device isPaired]){
            [_connectedDevicesList setValue:[device _name] forKey:[device _id]];
            //TO-DO move this to a different thread maybe
            [device reloadPlugins];
        }
        else{
            [_visibleDevicesList setValue:[device _name] forKey:[device _id]];
        }
    }
    NSDictionary* list=[NSDictionary dictionaryWithObjectsAndKeys:
                        _connectedDevicesList,  @"connected",
                        _visibleDevicesList,    @"visible",
                        _rememberedDevicesList, @"remembered",nil];
    return list;
}

- (void) pairDevice:(NSString*)deviceId;
{
    NSLog(@"bg pair device");
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device requestPairing];
    }
}

- (void) unpairDevice:(NSString*)deviceId
{
    NSLog(@"bg unpair device");
    Device* device=[_devices valueForKey:deviceId];
    if ([device isReachable]) {
        [device unpair];
    }
    [_devices removeObjectForKey:deviceId];
    [_settings setObject:nil forKey:deviceId];
    [_settings synchronize];
}

- (NSArray*) getDevicePluginViews:(NSString*)deviceId viewController:(UIViewController*)vc
{
    //NSLog(@"bg get device plugin view");
    Device* device=[_devices valueForKey:deviceId];
    if (device) {
        return [device getPluginViews:vc];
    }
    return nil;
}

- (void) refreshVisibleDeviceList
{
    //NSLog(@"bg on device refresh visible device list");
    BOOL updated=false;
    for (Device* device  in [_devices allValues]) {
        if ([device isReachable]) {
            if (![_visibleDevices containsObject:device]) {
                updated=true;
                [_visibleDevices addObject:device];
            }
        }
        else{
            if ([_visibleDevices containsObject:device]) {
                updated=true;
                [_visibleDevices removeObject:device];
            }
        }
    }
    if (_backgroundServiceDelegate && updated) {
        [_backgroundServiceDelegate onDeviceListRefreshed];
    }
}

#pragma mark reactions
- (void) onDeviceReachableStatusChanged:(Device*)device
{
    //NSLog(@"bg on device reachable status changed");
    if (![device isReachable]) {
        //NSLog(@"bg device not reachable");
    }
    if (![device isPaired]) {
        [_devices removeObjectForKey:[device _id]];
        //NSLog(@"bg destroy device");
    }
    [self refreshVisibleDeviceList];
}

- (void) onNetworkChange
{
    //NSLog(@"bg on network change");
    for (LanLinkProvider* lp in _linkProviders){
        [lp onNetworkChange];
    }
    [self refreshVisibleDeviceList];
}

- (void) onConnectionReceived:(NetworkPackage *)np link:(BaseLink *)link
{
    NSLog(@"bg on connection received");
    NSString* deviceId=[np objectForKey:@"deviceId"];
    NSLog(@"Device discovered: %@",deviceId);
    if ([_devices valueForKey:deviceId]) {
        //NSLog(@"known device");
        Device* device=[_devices objectForKey:deviceId];
        [device addLink:np baseLink:link];
    }
    else{
        NSLog(@"new device");
        Device* device=[[Device alloc] init:np baselink:link setDelegate:self];
        [_devices setObject:device forKey:deviceId];
        [self refreshVisibleDeviceList];
    }
}

- (void) onLinkDestroyed:(BaseLink *)link
{
    NSLog(@"bg on link destroyed");
    for (BaseLinkProvider* lp in _linkProviders) {
        [lp onLinkDestroyed:link];
    }
}

- (void) onDevicePairRequest:(Device *)device
{
    NSLog(@"bg on device pair request");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRequest:[device _id]];
    }
}

- (void) onDevicePairTimeout:(Device*)device
{
    NSLog(@"bg on device pair timeout");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairTimeout:[device _id]];
    }
    [_settings setObject:nil forKey:[device _id]];
    [_settings synchronize];
}

- (void) onDevicePairSuccess:(Device*)device
{
    NSLog(@"bg on device pair success");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairSuccess:[device _id]];
    }
    [_settings setObject:[device _name] forKey:[device _id]];
    [_settings synchronize];
}

- (void) onDevicePairRejected:(Device*)device
{
    NSLog(@"bg on device pair rejected");
    if (_backgroundServiceDelegate) {
        [_backgroundServiceDelegate onPairRejected:[device _id]];
    }
    [_settings setObject:nil forKey:[device _id]];
    [_settings synchronize];
}

- (void) reloadAllPlugins
{
    for (Device* dev in _visibleDevices) {
        [dev reloadPlugins];
    }
}

@end

