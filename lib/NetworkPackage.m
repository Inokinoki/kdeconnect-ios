//
//  NetworkPackage.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "NetworkPackage.h"
#define LFDATA [NSData dataWithBytes:"\x0D\x0A" length:2]

#pragma mark Implementation
@implementation NetworkPackage
- (NetworkPackage*) init:(NSString *)type
{
    if ([super init])
    {
        self._Id=[[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] stringValue];
        self._Type=type;
        self._Body=[NSMutableDictionary dictionary];
    }
    return self;
}

@synthesize _Id;
@synthesize _Type;
@synthesize _Body;

#pragma mark create Package
+(NetworkPackage*) createIdentityPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_IDENTITY];
    //TODO get Id?
    [[np _Body] setValue:@"yangqiao-iphone-simulator-id" forKey:@"deviceId"];
    [[np _Body] setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [[np _Body] setValue:[NSNumber numberWithInteger:ProtocolVersion] forKey:@"protocolVersion"];
    [[np _Body] setValue:@"Phone" forKey:@"deviceType"];
    [[np _Body] setValue:[NSNumber numberWithInteger:1714]  forKey:@"tcpPort"];
    
    return np;
}

+ (NetworkPackage*) createPublicKeyPackage
{
    NetworkPackage* np=nil;
    return np;
}

- (BOOL) bodyHas:(NSString*)key
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

//TODO
#pragma mark Encyption
- (BOOL) isEncrypted
{
    return true;
};
- (NetworkPackage*) encrypt
{
    NetworkPackage* np=nil;
    return np;
};
- (NetworkPackage*) decrypt
{
    NetworkPackage* np=nil;
    return np;
};

//TODO
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
