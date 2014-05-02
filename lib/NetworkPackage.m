//
//  NetworkPackage.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "NetworkPackage.h"

#pragma mark Private Methode Declaration
@interface NetworkPackage(private)
@end

#pragma mark -
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

#pragma mark Getter & Setter
@synthesize _Id;
@synthesize _Type;
@synthesize _Body;

#pragma mark create Package
+(NetworkPackage*) createIdentityPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_IDENTITY];
    //TODO get Id?
    [[np _Body] setValue:@"yangqiao-iphone-device-id" forKey:@"deviceId"];
    [[np _Body] setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [[np _Body] setValue:[NSNumber numberWithInteger:ProtocolVersion] forKey:@"protocolVersion"];
    [[np _Body] setValue:[UIDevice currentDevice].model forKey:@"deviceType"];
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
    NSData* jsonData=[NSJSONSerialization dataWithJSONObject:info options:0 error:&err];
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
- (void) hasPayload
{
    
}
- (void) hasPayloadTransferInfo
{
    
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
