//
//  DeviceSettingsStore.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/11/14.
//  
//

#import "IASKSettingsStore.h"
#define KDECONNECT_GLOBAL_SETTING_FILE_PATH    @"KDEConnectGlobalSettings"
#define KDECONNECT_REMEMBERED_DEV_FILE_PATH    @"KDEConnectRememberedDevices"

@interface SettingsStore : IASKAbstractSettingsStore

@property (nonatomic, copy, readonly) NSString* _filePath;

- (id)initWithPath:(NSString*)path;
- (NSArray*)getAllKeys;

@end
