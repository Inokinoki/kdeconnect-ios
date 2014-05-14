//
//  LanLink.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "LanLink.h"

@implementation LanLink
{
    __strong GCDAsyncSocket* _socket;
}

@synthesize _deviceId;
@synthesize _linkDelegate;

- (LanLink*) init:(GCDAsyncSocket*)socket deviceId:(NSString*) deviceid setDelegate:(id)linkdelegate
{
    if ([super init:deviceid setDelegate:nil])
    {
        _socket=socket;
        _deviceId=deviceid;
        _linkDelegate=linkdelegate;
        [_socket setDelegate:self];
        NSLog(@"LanLink:lanlink device:%@ created",_deviceId);
        [_socket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
        //send my id package
        NetworkPackage* np=[NetworkPackage createIdentityPackage];
        [_socket writeData:[np serialize] withTimeout:-1 tag:PACKAGE_TAG_IDENTITY];
        
        [_socket writeData:[GCDAsyncSocket LFData] withTimeout:KEEPALIVE_TIMEOUT tag:KEEPALIVE_TAG];
    }
    return self;
}

- (BOOL) sendPackage:(NetworkPackage *)np tag:(long)tag
{
    if (![_socket isConnected]) {
        NSLog(@"LanLink: Device:%@ disconnected",_deviceId);
        return false;
    }
    
    NSData* data=[np serialize];
    
    [_socket writeData:data withTimeout:-1 tag:tag];
    return true;
}

- (BOOL) sendPackageEncypted:(NetworkPackage *)np
{
    
    return true;
}

- (void) disconnect
{
    if ([_socket isConnected]) {
        [_socket disconnect];
    }
    if (_linkDelegate) {
        [_linkDelegate onLinkDestroyed:self];
    }

    NSLog(@"LanLink: Device:%@ disconnected",_deviceId);
}

#pragma mark TCP delegate
/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //BUG even if we read with a seperator LFData , it's still possible to receive several data package together. So we split the string and retrieve the package
    [_socket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:0];
    NSString * jsonStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* packageArray=[jsonStr componentsSeparatedByString:@"\n"];
    for (NSString* dataStr in packageArray) {
        NetworkPackage* np=[NetworkPackage unserialize:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
        if (_linkDelegate && np) {
            [_linkDelegate onPackageReceived:np];
            NSLog(@"did read data:\n%@",dataStr);

        }
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag==KEEPALIVE_TAG) {
        [sock writeData:[GCDAsyncSocket LFData] withTimeout:KEEPALIVE_TIMEOUT tag:KEEPALIVE_TAG];
        return;
    }
    NSLog(@"didWriteData");
    if (_linkDelegate) {
        [_linkDelegate onSendSuccess:tag];
    }
    
    
}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    return 0;
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (tag==1) {
        NSLog(@"connection down");
        [sock disconnect];
    }
    return 0;
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (_linkDelegate) {
        [_linkDelegate onLinkDestroyed:self];    
    }
    
}

@end
