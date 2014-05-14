//
//  GCDSingleton.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/14/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#ifndef kdeconnect_ios_GCDSingleton_h
#define kdeconnect_ios_GCDSingleton_h

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \

#endif
