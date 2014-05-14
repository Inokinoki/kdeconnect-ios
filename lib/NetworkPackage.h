//
//  NetworkPackage.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UDPBROADCAST_TAG -1
#define TCPSERVER_TAG -2
#define KEEPALIVE_TAG -3

#define PACKAGE_TAG_NORMAL 0
#define PACKAGE_TAG_IDENTITY 1
#define PACKAGE_TAG_PAIR 2
#define PACKAGE_TAG_UNPAIR 3
#define PACKAGE_TAG_PING 4

#define KEEPALIVE_TIMEOUT 3

#define PORT 1714

#pragma mark static constant define
#define ProtocolVersion 5
#define PACKAGE_TYPE_IDENTITY @"kdeconnect.identity"
#define PACKAGE_TYPE_PAIR @"kdeconnect.pair"
#define PACKAGE_TYPE_PING @"kdeconnect.ping"

#pragma mark -

@interface NetworkPackage : NSObject

@property(strong,nonatomic) NSString* _Id;
@property(strong,nonatomic) NSString *_Type;
@property(strong,nonatomic) NSMutableDictionary *_Body;
//@property(weak,nonatomic) NSInputStream *_Payload;
//@property(weak,nonatomic) NSDictionay *_PayloadTransferInfo;
//@property(nonatomic)int _PayloadSize;

- (NetworkPackage*)init:(NSString*)type;
+ (NetworkPackage*) createIdentityPackage;
+ (NetworkPackage*) createPublicKeyPackage;
- (BOOL) bodyHas:(NSString*)key;

#pragma mark Serialize
- (NSData*) serialize;
+ (NetworkPackage*) unserialize:(NSData*)data;

//TODO
#pragma mark Encyption
- (BOOL) isEncrypted;
- (NetworkPackage*) encrypt;
- (NetworkPackage*) decrypt;

//TODO
#pragma mark Payload
- (void) setPayload:(NSData*)data;
- (void) setPayload:(NSInputStream*)inputStream size:(NSInteger*)size;
- (void) setPayloadTransferInfo;
- (BOOL) hasPayload;
- (BOOL) hasPayloadTransferInfo;
- (void) getPayload;
- (void) getPayloadSize;
- (void) getPayloadTransferInfo;

@end
