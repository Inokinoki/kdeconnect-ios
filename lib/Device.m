//
//  Device.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/29/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Device.h"
#define PAIR_TIMMER_TIMEOUT  10.0

@implementation Device
{
    __strong NSMutableArray* _links;
//    id* _publicKey;
    __strong NSMutableDictionary* _plugins;
    __strong NSMutableDictionary* _failedPlugins;

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
    _plugins=[NSMutableDictionary dictionaryWithCapacity:1];
    _failedPlugins=[NSMutableDictionary dictionaryWithCapacity:1];
    [self reloadPlugins];
    return self;
}

- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)link setDelegate:(id)deviceDelegate
{
    _id=[[np _Body] valueForKey:@"deviceId"];
    _name=[[np _Body] valueForKey:@"deviceName"];
    _links=[NSMutableArray arrayWithCapacity:1];
    _plugins=[NSMutableDictionary dictionaryWithCapacity:1];
    _failedPlugins=[NSMutableDictionary dictionaryWithCapacity:1];
    //TODO need a string to type? or a dictionary
//    _type=[[[np _Body] valueForKey:@"deviceType"] ;
    _protocolVersion=[[[np _Body] valueForKey:@"protocolVersion"] integerValue];
    _deviceDelegate=deviceDelegate;
    [link set_linkDelegate:self];
    [self reloadPlugins];
    //TODO creat a private Key
    
    [self addLink:np baseLink:link];
    return self;
}

- (NSInteger) compareProtocolVersion
{
    return 0;
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
        if (_deviceDelegate) {
            [_deviceDelegate onReachableStatusChanged:self];
        }
        
    }
    if (_deviceDelegate) {
        [_deviceDelegate onLinkDestroyed:link];
    }
    

}

- (BOOL) sendPackage:(NetworkPackage *)np tag:(long)tag
{
    for (BaseLink* link in _links) {
        if ([link sendPackage:np tag:tag]) {
            return true;
        }
    }
    return false;
}

- (void) onSendSuccess:(long)tag
{
    if (tag==PACKAGE_TAG_PAIR) {
        if (_pairStatus==RequestedByPeer) {
            [self setAsPaired];
        }
    }
}

- (void) onPackageReceived:(NetworkPackage*)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PAIR]) {
        NSLog(@"Pair package received");
        BOOL wantsPair=[[[np _Body] valueForKey:@"pair"] boolValue];
        if (wantsPair==[self isPaired]) {
            NSLog(@"already done, paired:%d",wantsPair);
            if (_pairStatus==Requested) {
                NSLog(@"canceled by other peer");
                _pairStatus=NotPaired;
                [_deviceDelegate onPairRejected:self];
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
                [_deviceDelegate onPairRequest:self];
            }
        }
        else{
            NSLog(@"unpair request");
            PairStatus prevPairStatus=_pairStatus;
            _pairStatus=NotPaired;
            if (prevPairStatus==Requested) {
                NSLog(@"canceled by other peer");
            }else if (prevPairStatus==Paired){
                //TODO remove configuration
                
                //reload Plugins
                [self reloadPlugins];
                [self unpair];
            }
            
        }
        
    }else if ([self isPaired]){
        NSLog(@"recieved a plugin package :%@",[np _Type]);
        for (Plugin* plugin in [_plugins allValues]) {
            [plugin onPackageReceived:np];
        }
        
    }else{
        NSLog(@"not paired, ignore packages ");
    }
}

- (BOOL) isReachable
{
    return [_links count]!=0;
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
    NSLog(@"paired with %@",_name);
    // save trusted device configuration
    [self reloadPlugins];
    [_deviceDelegate onPairSuccess:self];
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
    _pairStatus=Requested;
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"pair"];
    [[np _Body] setValue:@"qwefsdv1241234asvqwefbgwerf1345" forKey:@"publickey"];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
    [self performSelector:@selector(requestPairingTimeout) withObject:self afterDelay:PAIR_TIMMER_TIMEOUT];
}

- (void) requestPairingTimeout
{
    if (_pairStatus!=Paired) {
        _pairStatus=NotPaired;
        NSLog(@"pairing timeout");
        [_deviceDelegate onPairTimeout:self];
        NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
        [[np _Body] setValue:[NSNumber numberWithBool:NO] forKey:@"pair"];
        [self sendPackage:np tag:PACKAGE_TAG_UNPAIR];
    }
}


- (void) unpair
{
    if (![self isPaired]) return;
    
    _pairStatus=NotPaired;
    
    //delete from config file
    
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np tag:PACKAGE_TAG_UNPAIR];
    [self reloadPlugins];
}

- (void) acceptPairing
{
    NSLog(@"accepted pair request");
    NetworkPackage* np=[NetworkPackage createPublicKeyPackage];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
}

- (void) rejectPairing
{
    NSLog(@"rejected pair request ");
    _pairStatus=NotPaired;
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
}

#pragma mark Plugins-related Functions

- (void) reloadPlugins
{
    [_failedPlugins removeAllObjects];
    PluginFactory* pluginFactory=[PluginFactory getInstance];
    NSArray* pluginNames=[pluginFactory getAvailablePlugins];
    for (NSString* pluginName in pluginNames) {
        Plugin* plugin=[pluginFactory instantiatePluginForDevice:self pluginName:pluginName];
        if (plugin) {
            [_plugins setValue:plugin forKey:pluginName];
        }
    }
    
}

- (Plugin*) getPlugin:(NSString*)pluginName
{
    return [_plugins valueForKey:pluginName];
}

@end












