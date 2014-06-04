//
//  NetworkPackage.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "NetworkPackage.h"
#import "SecKeyWrapper.h"
#define LFDATA [NSData dataWithBytes:"\x0D\x0A" length:2]

__strong static NSString* _publicKeyStr;

#pragma mark Implementation
@implementation NetworkPackage

- (NetworkPackage*) initWithType:(NSString *)type
{
    if ((self=[super init]))
    {
        _Id=[[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] stringValue];
        _Type=type;
        _Body=[NSMutableDictionary dictionary];
        _publicKeyStr=nil;
    }
    return self;
}

@synthesize _Id;
@synthesize _Type;
@synthesize _Body;

#pragma mark create Package
+(NetworkPackage*) createIdentityPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_IDENTITY];
    //TO-DO get Id?
    [[np _Body] setValue:[UIDevice currentDevice].name forKey:@"deviceId"];
    [[np _Body] setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [[np _Body] setValue:[NSNumber numberWithInteger:ProtocolVersion] forKey:@"protocolVersion"];
    [[np _Body] setValue:@"Phone" forKey:@"deviceType"];
    [[np _Body] setValue:[NSNumber numberWithInteger:1714]  forKey:@"tcpPort"];
    
    return np;
}


+ (NetworkPackage*) createPublicKeyPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
    if (!_publicKeyStr) {
        NSString* publicKeyStr=[[SecKeyWrapper sharedWrapper] getRSAPublicKeyAsBase64];
        _publicKeyStr=[NSString stringWithFormat:@"%@\n%@\n%@\n",
                       @"-----BEGIN PUBLIC KEY-----",
                       publicKeyStr,
                       @"-----END PUBLIC KEY-----"];
    }
    [[np _Body] setValue:_publicKeyStr forKey:@"publicKey"];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"pair"];

    return np;
}

- (NSData*) retrievePublicKeyBits
{
    NSString* publickeyStr=[_Body valueForKey:@"publicKey"];
    NSArray* strArray=[publickeyStr componentsSeparatedByString:@"\n"];
    NSRange keyRange;
    keyRange.location=1;
    keyRange.length=[strArray count]-3;
    publickeyStr=[[strArray subarrayWithRange:keyRange] componentsJoinedByString:@"\n"];
    return [[NSData alloc] initWithBase64EncodedString:publickeyStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (BOOL) bodyHasKey:(NSString*)key
{
    if ([self._Body valueForKey:key]!=nil) {
        return true;
    }
    return false;
};

#pragma mark Serialize
- (NSData*) serialize
{
    NSArray* keys=[NSArray arrayWithObjects:@"id",@"type",@"body", nil];
    NSArray* values=[NSArray arrayWithObjects:[self _Id],[self _Type],[self _Body], nil];
    NSDictionary* info=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSError* err=nil;
    NSMutableData* jsonData=[[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:info options:0 error:&err]];
    [jsonData appendData:LFDATA];
    return jsonData;
}

+ (NetworkPackage*) unserialize:(NSData*)data
{
    NetworkPackage* np=[[NetworkPackage alloc] init];
    NSError* err=nil;
    NSDictionary* info=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];

    [np set_Id:[info valueForKey:@"id"]];
    [np set_Type:[info valueForKey:@"type"]];
    [np set_Body:[info valueForKey:@"body"]];
    
    if (err) {
        return nil;
    }
    return np;
}

//TO-DO
#pragma mark Encyption
- (BOOL) isEncrypted
{
    return true;
};

- (NetworkPackage*) encryptWithPublicKeyRef:(SecKeyRef)publicKeyRef
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_ENCRYPTED];
    NSData* data=[self serialize];
    NSData* encryptedData=[[SecKeyWrapper sharedWrapper] wrapSymmetricKey:data keyRef:publicKeyRef];
    NSArray* encryptedArray=[NSArray arrayWithObject:[encryptedData base64EncodedStringWithOptions:0]];
    [[np _Body] setValue:encryptedArray forKey:@"data"];
    return np;
};

- (NetworkPackage*) decrypt
{
    if (![_Type isEqualToString:PACKAGE_TYPE_ENCRYPTED]) {
        return nil;
    }
    NSArray* encryptedDataStrArray=[_Body valueForKey:@"data"];
    NSMutableData* decryptedBits=[NSMutableData data];
    for (NSString* dataStr in encryptedDataStrArray) {
        NSData* encryptedData=[[NSData alloc] initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData* decryptedData=[[SecKeyWrapper sharedWrapper] unwrapSymmetricKey:encryptedData];
        [decryptedBits appendData:decryptedData];
    }
    
    
    return [NetworkPackage unserialize:decryptedBits];
};

//TO-DO
#pragma mark Payload
- (void) setPayload:(NSData*)data
{
    
}

- (void) setPayload:(NSInputStream*)inputStream size:(NSInteger*)size
{
    
}
- (void) setPayloadTransferInfo
{
    
}
- (BOOL) hasPayload
{
    return false;
}
- (BOOL) hasPayloadTransferInfo
{
    return false;
}
- (void) getPayload
{
    
}
- (void) getPayloadSize
{
    
}
- (void) getPayloadTransferInfo
{
    
}

@end
