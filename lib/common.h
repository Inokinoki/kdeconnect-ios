//
//  common.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/5/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#ifndef kdeconnect_ios_common_h
#define kdeconnect_ios_common_h

// keychain related
#define KEYCHAIN_ID     @"org.kde.kdeconnect-ios"
#define KECHAIN_GROUP   @"34RXKJTKWE.org.kde.kdeconnect-ios"

// constants used to find public, private, and symmetric keys.
#define kPublicKeyTag			"org.kde.kdeconnect.publickey"
#define kPrivateKeyTag			"org.kde.kdeconnect.privatekey"
#define kSymmetricKeyTag		"org.kde.kdeconnect.symmetrickey"

// file paths
#define KDECONNECT_GLOBAL_SETTING_FILE_PATH    @"KDEConnectGlobalSettings"
#define KDECONNECT_REMEMBERED_DEV_FILE_PATH    @"KDEConnectRememberedDevices"

// GCDSingleton
#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#endif
