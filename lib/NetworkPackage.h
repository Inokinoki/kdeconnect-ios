//
//  NetworkPackage.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Package related macro

#define UDPBROADCAST_TAG        -3
#define TCPSERVER_TAG           -2

#define PACKAGE_TAG_PAYLOAD     -1
#define PACKAGE_TAG_NORMAL      0
#define PACKAGE_TAG_IDENTITY    1
#define PACKAGE_TAG_ENCRYPTED   2
#define PACKAGE_TAG_PAIR        3
#define PACKAGE_TAG_UNPAIR      4
#define PACKAGE_TAG_PING        5
#define PACKAGE_TAG_MPRIS       6
#define PACKAGE_TAG_SHARE       7
#define PACKAGE_TAG_CLIPBOARD   8
#define PACKAGE_TAG_MOUSEPAD    9

#define PORT                    1714
#define ProtocolVersion         5

#define PACKAGE_TYPE_IDENTITY   @"kdeconnect.identity"
#define PACKAGE_TYPE_ENCRYPTED  @"kdeconnect.encrypted"
#define PACKAGE_TYPE_PAIR       @"kdeconnect.pair"
#define PACKAGE_TYPE_PING       @"kdeconnect.ping"
#define PACKAGE_TYPE_MPRIS      @"kdeconnect.mpris"
#define PACKAGE_TYPE_TELEPHONY  @"kdeconnect.telephony"
#define PACKAGE_TYPE_SHARE      @"kdeconnect.share"
#define PACKAGE_TYPE_CLIPBOARD  @"kdeconnect.clipboard"
#define PACKAGE_TYPE_MOUSEPAD   @"kdeconnect.mousepad"

#pragma mark -

@interface NetworkPackage : NSObject

@property(nonatomic) NSString* _Id;
@property(nonatomic) NSString *_Type;
@property(nonatomic) NSMutableDictionary *_Body;
@property(nonatomic) NSData *_Payload;
@property(nonatomic) NSDictionary *_PayloadTransferInfo;
@property(nonatomic)long _PayloadSize;

- (NetworkPackage*) initWithType:(NSString*)type;
+ (NetworkPackage*) createIdentityPackage;
+ (NetworkPackage*) createPublicKeyPackage;
- (NSData*) retrievePublicKeyBits;

- (BOOL) bodyHasKey:(NSString*)key;
- (void)setBool:(BOOL)value      forKey:(NSString*)key;
- (void)setFloat:(float)value    forKey:(NSString*)key;
- (void)setDouble:(double)value  forKey:(NSString*)key;
- (void)setInteger:(NSInteger)value    forKey:(NSString*)key;
- (void)setObject:(id)value      forKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (NSInteger)integerForKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

#pragma mark Serialize
- (NSData*) serialize;
+ (NetworkPackage*) unserialize:(NSData*)data;

#pragma mark Encyption
- (BOOL) isEncrypted;
- (NetworkPackage*) encryptWithPublicKeyRef:(SecKeyRef)publicKeyRef;
- (NetworkPackage*) decrypt;

@end
