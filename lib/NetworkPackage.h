//
//  NetworkPackage.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark static constant define
static NSInteger ProtocolVersion=5;
static NSString* PACKAGE_TYPE_IDENTITY = @"kdeconnect.identity";
static NSString* PACKAGE_TYPE_PAIR = @"kdeconnect.pair";
#pragma mark -
@interface NetworkPackage : NSObject
{
}

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
