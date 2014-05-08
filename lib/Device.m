//
//  Device.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/29/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Device.h"

@implementation Device
{
    NSMutableArray* _links;
//    id* _publicKey;
//    NSMutableDictionary* _plugins;
//    NSMutableDictionary* _failedPlugins;

}
@synthesize _id;
@synthesize _name;
@synthesize _pairStatus;
@synthesize _protocolVersion;
@synthesize _type;
@synthesize _deviceDelegate;
- (Device*) init:(NSString*)deviceId setDelegate:(id)deviceDelegate
{
    //TODO load config from setting
    _id=deviceId;
    _deviceDelegate=deviceDelegate;
    _links=[NSMutableArray arrayWithCapacity:1];
    return self;
}

- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)link setDelegate:(id)deviceDelegate
{
    _id=[[np _Body] valueForKey:@"deviceId"];
    _name=[[np _Body] valueForKey:@"deviceName"];

    //TODO need a string to type? or a dictionary
//    _type=[[[np _Body] valueForKey:@"deviceType"] ;
    _protocolVersion=[[[np _Body] valueForKey:@"protocolVersion"] integerValue];
    _deviceDelegate=deviceDelegate;

    //TODO creat a private Key
    
    [self addLink:np baseLink:link];
    return self;
}

#pragma mark Link-related Functions

- (void) addLink:(NetworkPackage*)np baseLink:(BaseLink*)Link
{
    NSLog(@"add link to %@",_id);
    if (_protocolVersion!=[[[np _Body] valueForKey:@"protocolVersion"] integerValue]) {
        NSLog(@"using different protocol version");
    }
    [_links addObject:Link];
    _id=[[np _Body] valueForKey:@"deviceId"];
    _name=[[np _Body] valueForKey:@"deviceName"];
    //TODO need a string to type? or a dictionary
    //    _type=[[[np _Body] valueForKey:@"deviceType"] ;
    //TODO set link privatekey
    //[Link set_privateKey:_privateKey];
}

- (void) onLinkDestroyed:(BaseLink *)link
{
    [_links removeObject:link];
    NSLog(@"remove link ; %lu remaining", (unsigned long)[_links count]);
    
    if ([_links count]==0) {
        NSLog(@"no available link");
        
        //TODO reachable status changed
    }

}

- (BOOL) sendPackage:(NetworkPackage *)np
{
    for (BaseLink* link in _links) {
        if ([link sendPackage:np]) {
            return true;
        }
    }
    return false;
}

- (void) onPackageReceived:(NetworkPackage*)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PAIR]) {
        NSLog(@"Pair package received");
        BOOL wantsPair=[[[np _Body] valueForKey:@"pair"] boolValue];
        if (wantsPair==[self isPaired]) {
            NSLog(@"already done, paired:%d",wantsPair);
            if (_pairStatus==Requested) {
                _pairStatus=NotPaired;
                //TODO stop timer
                NSLog(@"canceled by other peer");
            }
            return;
        }
        if (wantsPair) {
            //TODO retrieve public key
            NSLog(@"pair request");
            if ((_pairStatus)==Requested) {
                [self setAsPaired];
            }
            else{
                //TODO ask if user want to pair
                _pairStatus=RequestedByPeer;
            }
        }
        else{
            NSLog(@"unpair request");
            PairStatus prevPairStatus=_pairStatus;
            _pairStatus=NotPaired;
            if (prevPairStatus==Requested) {
                //TODO stop pairing timmer
                NSLog(@"canceled by other peer");
            }else if (prevPairStatus==Paired){
                //TODO save configuration
                
                //reload Plugins
                [self reloadPlugins];
                [self unpair];
            }
            
        }
        
    }else if ([self isPaired]){
        //call plugins
        
    }else{
        NSLog(@"not paired, ignore packages ");
    }
}

#pragma mark Pairing-related Functions
- (BOOL) isPaired
{
    return _pairStatus==Paired;
}

- (BOOL) isPaireRequested
{
    return _pairStatus==Requested;
}


- (void) setAsPaired
{
    _pairStatus=Paired;
    //TODO stop timmer;
    // save trusted device configuration
    [self reloadPlugins];
    //inform pairsuccessful
}

- (void) requestPairing
{
    if (_pairStatus==Paired) {
        NSLog(@"failed:already paired");
        return;
    }
    if (_pairStatus==Requested) {
        NSLog(@"failed:already requested");
        return;
    }
    if (![self isReachable]) {
        NSLog(@"failed:not reachable");
        return;
    }
    NetworkPackage* np=[NetworkPackage createPublicKeyPackage];
    [self sendPackage:np];
}

- (void) unpair
{
    if (![self isPaired]) return;
    
    _pairStatus=NotPaired;
    
    //delete from config file
    
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np];
    [self reloadPlugins];
}

- (void) acceptPairing
{
    NSLog(@"accepted pair request");
    NetworkPackage* np=[NetworkPackage createPublicKeyPackage];
    [self sendPackage:np];
}

- (void) rejectPairing
{
    NSLog(@"rejected pair request ");
    _pairStatus=NotPaired;
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np];
}

@end












