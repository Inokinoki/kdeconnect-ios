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
    __strong NSMutableArray* _failedPlugins;
}
@synthesize _id;
@synthesize _name;
@synthesize _pairStatus;
@synthesize _protocolVersion;
@synthesize _type;
@synthesize _deviceDelegate;
- (Device*) init:(NSString*)deviceId setDelegate:(id)deviceDelegate
{
    if ((self=[super init])) {
        //TO-DO load config from setting
        _id=deviceId;
        _deviceDelegate=deviceDelegate;
        _links=[NSMutableArray arrayWithCapacity:1];
        _plugins=[NSMutableDictionary dictionaryWithCapacity:1];
        _failedPlugins=[NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (Device*) init:(NetworkPackage*)np baselink:(BaseLink*)link setDelegate:(id)deviceDelegate
{
    if ((self=[super init])) {
        _id=[[np _Body] valueForKey:@"deviceId"];
        _name=[[np _Body] valueForKey:@"deviceName"];
        _links=[NSMutableArray arrayWithCapacity:1];
        _plugins=[NSMutableDictionary dictionaryWithCapacity:1];
        //    _failedPlugins=[NSMutableArray arrayWithCapacity:1];
        //TO-DO need a string to type? or a dictionary
        //    _type=[[[np _Body] valueForKey:@"deviceType"] ;
        _protocolVersion=[[[np _Body] valueForKey:@"protocolVersion"] integerValue];
        _deviceDelegate=deviceDelegate;
        //TO-DO creat a private Key
        [self addLink:np baseLink:link];
    }
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
    [Link set_linkDelegate:self];
    if ([_links count]==1) {
        NSLog(@"one link available");
        if (_deviceDelegate) {
            [_deviceDelegate onDeviceReachableStatusChanged:self];
        }
    }
    //TO-DO need a string to type? or a dictionary
    //    _type=[[[np _Body] valueForKey:@"deviceType"] ;
    //TO-DO set link privatekey
    //[Link set_privateKey:_privateKey];
}

- (void) onLinkDestroyed:(BaseLink *)link
{
    NSLog(@"device on link destroyed");
    [_links removeObject:link];
    NSLog(@"remove link ; %lu remaining", (unsigned long)[_links count]);
    
    if ([_links count]==0) {
        NSLog(@"no available link");
        if (_deviceDelegate) {
            [_deviceDelegate onDeviceReachableStatusChanged:self];
        }
    }
    if (_deviceDelegate) {
        [_deviceDelegate onLinkDestroyed:link];
    }
}

- (BOOL) sendPackage:(NetworkPackage *)np tag:(long)tag
{
    NSLog(@"device send package");
    for (BaseLink* link in _links) {
        if ([link sendPackage:np tag:tag]) {
            return true;
        }
    }
    return false;
}

- (void) onSendSuccess:(long)tag
{
    NSLog(@"device on send success");
    if (tag==PACKAGE_TAG_PAIR) {
        if (_pairStatus==RequestedByPeer) {
            [self setAsPaired];
        }
    }
}

- (void) onPackageReceived:(NetworkPackage*)np
{
    NSLog(@"device on package received");
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PAIR]) {
        NSLog(@"Pair package received");
        BOOL wantsPair=[[[np _Body] valueForKey:@"pair"] boolValue];
        if (wantsPair==[self isPaired]) {
            NSLog(@"already done, paired:%d",wantsPair);
            if (_pairStatus==Requested) {
                NSLog(@"canceled by other peer");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestPairingTimeout:) object:nil];
                });
                _pairStatus=NotPaired;
                if (_deviceDelegate) {
                    [_deviceDelegate onDevicePairRejected:self];
                }
                
            }
            return;
        }
        if (wantsPair) {
            //TO-DO retrieve public key
            NSLog(@"pair request");
            if ((_pairStatus)==Requested) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestPairingTimeout:) object:nil];
                });
                [self setAsPaired];
            }
            else{
                _pairStatus=RequestedByPeer;
                if (_deviceDelegate) {
                    [_deviceDelegate onDevicePairRequest:self];
                }
            }
        }
        else{
            NSLog(@"unpair request");
            PairStatus prevPairStatus=_pairStatus;
            _pairStatus=NotPaired;
            if (prevPairStatus==Requested) {
                NSLog(@"canceled by other peer");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestPairingTimeout:) object:nil];
                });
            }else if (prevPairStatus==Paired){
                //TO-DO remove configuration
                
                [self unpair];
            }
        }
    }else if ([self isPaired]){
        NSLog(@"recieved a plugin package :%@",[np _Type]);
        for (Plugin* plugin in [_plugins allValues]) {
            [plugin onDevicePackageReceived:np];
        }
        
    }else{
        NSLog(@"not paired, ignore packages, unpair the device");
        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
        [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
        [self sendPackage:np tag:PACKAGE_TAG_UNPAIR];
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
    if (_deviceDelegate) {
        [_deviceDelegate onDevicePairSuccess:self];
    }
    
}

- (void) requestPairing
{
    if (![self isReachable]) {
        NSLog(@"device failed:not reachable");
        return;
    }
    if (_pairStatus==Paired) {
        NSLog(@"device failed:already paired");
        return;
    }
    if (_pairStatus==Requested) {
        NSLog(@"device failed:already requested");
        return;
    }
    if (_pairStatus==RequestedByPeer) {
        NSLog(@"device accept pair request");
    }
    else{
        NSLog(@"device request pairing");
        _pairStatus=Requested;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(requestPairingTimeout:) withObject:nil afterDelay:PAIR_TIMMER_TIMEOUT];
        });
    }
    NetworkPackage* np=[NetworkPackage createPublicKeyPackage];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"pair"];
    //TO-DO public key
    [[np _Body] setValue:@"qwefsdv1241234asvqwefbgwerf1345" forKey:@"publickey"];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
}

- (void) requestPairingTimeout:(id)sender
{
    NSLog(@"device request pairing timeout");
    if (_pairStatus==Requested) {
        _pairStatus=NotPaired;
        NSLog(@"pairing timeout");
        if (_deviceDelegate) {
            [_deviceDelegate onDevicePairTimeout:self];
        }
        
        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
        [[np _Body] setValue:[NSNumber numberWithBool:NO] forKey:@"pair"];
        [self sendPackage:np tag:PACKAGE_TAG_UNPAIR];
    }
}

- (void) unpair
{
    NSLog(@"device unpair");
    if (![self isPaired]) return;
    
    _pairStatus=NotPaired;
    
    //delete from config file
    
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np tag:PACKAGE_TAG_UNPAIR];
}

- (void) acceptPairing
{
    NSLog(@"device accepted pair request");
    NetworkPackage* np=[NetworkPackage createPublicKeyPackage];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
}

- (void) rejectPairing
{
    NSLog(@"device rejected pair request ");
    _pairStatus=NotPaired;
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:false] forKey:@"pair"];
    [self sendPackage:np tag:PACKAGE_TAG_PAIR];
}

#pragma mark Plugins-related Functions
- (void) reloadPlugins
{
    NSLog(@"device reload plugins");
    [_failedPlugins removeAllObjects];
    PluginFactory* pluginFactory=[PluginFactory sharedInstance];
    NSArray* pluginNames=[pluginFactory getAvailablePlugins];
    for (NSString* pluginName in pluginNames) {
        //TO-DO load configure file
        if ((![[_plugins allKeys] containsObject:pluginName])||(![_plugins valueForKey:pluginName])) {
            Plugin* plugin=[pluginFactory instantiatePluginForDevice:self pluginName:pluginName];
            if (plugin)
                [_plugins setValue:plugin forKey:pluginName];
            else
                [_failedPlugins addObject:pluginName];
        }
    }
}

- (NSArray*) getPluginViews:(UIViewController*)vc
{
    NSMutableArray* views=[NSMutableArray arrayWithCapacity:1];
    for (Plugin* plugin in [_plugins allValues]) {
        UIView* view=[plugin getView:vc];
        if (view) {
            [views addObject:view];
        }
    }
    return views;
}
@end












