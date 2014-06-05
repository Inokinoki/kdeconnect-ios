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
@synthesize _Payload;
@synthesize _PayloadSize;
@synthesize _PayloadTransferInfo;

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
    NSMutableDictionary* info=[NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    if (_Payload) {
        [info setValue:[NSNumber numberWithLong:(_PayloadSize?_PayloadSize:-1)] forKey:@"payloadSize"];
        [info setValue:_PayloadTransferInfo forKey:@"payloadTransferInfo"];
    }
    NSError* err=nil;
    NSMutableData* jsonData=[[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:info options:0 error:&err]];
    if (err) {
        NSLog(@"NP serialize error");
        return nil;
    }
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
    [np set_PayloadSize:[[info valueForKey:@"payloadSize"]longValue]];
    [np set_PayloadTransferInfo:[info valueForKey:@"payloadTransferInfo"]];
    
    //TODO should change for laptop
    if ([np _PayloadSize]==-1) {
        id temp;
        long size=(temp=[[np _Body] valueForKey:@"size"])?[temp longValue]:-1;
        [np set_PayloadSize:size];
    }
    [np set_PayloadTransferInfo:[info valueForKey:@"payloadTransferInfo"]];
    
    if (err) {
        return nil;
    }
    return np;
}

#pragma mark Encyption
- (BOOL) isEncrypted
{
    return [_Type isEqual:PACKAGE_TYPE_ENCRYPTED];
};

- (NetworkPackage*) encryptWithPublicKeyRef:(SecKeyRef)publicKeyRef
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_ENCRYPTED];
    NSData* data=[self serialize];
    NSData* encryptedData=[[SecKeyWrapper sharedWrapper] wrapSymmetricKey:data keyRef:publicKeyRef];
    NSRange range;
    range.length=256;
    range.location=0;
    NSUInteger length=[encryptedData length];
    NSMutableArray* encryptedArray=[NSMutableArray arrayWithCapacity:1];
    while (length>0) {
        if (length<range.length) {
            range.length=length;
            length=0;
        }
        else{
            length-=range.length;
        }
        NSData* chunk=[encryptedData subdataWithRange:range];
        range.location+=range.length;
        [encryptedArray addObject:[chunk base64EncodedStringWithOptions:0]];
    }

    
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

@end
