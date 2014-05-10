//
//  LanLinkProvider.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "LanLinkProvider.h"

@implementation LanLinkProvider
{
    __strong GCDAsyncUdpSocket* _udpSocket;
    __strong GCDAsyncSocket* _tcpSocket;
    NSMutableArray* _pendingSockets;
    NSMutableArray* _pendingNps;
    uint16_t _tcpPort;
    NSUInteger _socketIndex;
}

@synthesize _connectedLinks;
@synthesize _linkProviderDelegate;

- (LanLinkProvider*) initWithDelegate:(id)linkProviderDelegate
{
    if ([super init])
    {
        
        _tcpPort=PORT;
        _pendingSockets=[NSMutableArray arrayWithCapacity:1];
        _pendingNps=[NSMutableArray arrayWithCapacity:1];
        _connectedLinks=[NSMutableArray arrayWithCapacity:1];
        _linkProviderDelegate=linkProviderDelegate;
        _socketIndex=0;
        socketQueue=dispatch_queue_create("socketQueue", NULL);
    
    }
    return self;
}

- (void)setupSocket
{
    NSError* err;
    if (_tcpSocket==nil) {
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    }
    if (_udpSocket==nil) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        [_udpSocket enableBroadcast:true error:&err];
    }
    if (![_udpSocket bindToPort:PORT error:&err]) {
        NSLog(@"udp bind error");
    }
}

- (void)onStart
{
    
    [self setupSocket];
    NSError* err;
    if (![_udpSocket beginReceiving:&err]) {
        NSLog(@"LanLinkProvider:UDP socket start error");
        return;
    }
    NSLog(@"LanLinkProvider:UDP socket start");
    if (![_tcpSocket isConnected]) {
        while (![_tcpSocket acceptOnPort:_tcpPort error:&err]) {
            _tcpPort++;
        }
    }
    
    NSLog(@"LanLinkProvider:setup tcp socket on port %d",_tcpPort);
    
    //Introduce myself , UDP broadcasting my id package
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    [[np _Body] setValue:[[NSNumber alloc ] initWithUnsignedInt:_tcpPort] forKey:@"tcpPort"];
    NSData* data=[np serialize];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	[_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:UDPBROADCAST_TAG];
}

- (void)onStop
{
    [_udpSocket close];
    [_tcpSocket disconnect];
    for (GCDAsyncSocket* socket in _pendingSockets) {
        [socket disconnect];
    }
    for (GCDAsyncSocket* link in _connectedLinks) {
        [link disconnect];
    }
    
    [_pendingNps removeAllObjects];
    [_pendingSockets removeAllObjects];
    [_connectedLinks removeAllObjects];

}

- (void)onPause
{
    [_udpSocket close];
    [_tcpSocket disconnect];
}

- (void)onNetworkChange
{
    [self onStop];
    [self onStart];
}
#pragma mark UDP Socket Delegate

/**
 * Called when the socket has received the requested datagram.
 **/

//a new device is introducing itself to me
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NetworkPackage* np = [NetworkPackage unserialize:data];
    NSLog(@"linkprovider:received a udp package from %@",[[np _Body] valueForKey:@"deviceName"]);
    //not id package

    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]){
        NSLog(@"LanLinkProvider:expecting an id package");
        return;
    }
    
    //my own package
    NetworkPackage* np2=[NetworkPackage createIdentityPackage];
    NSString* myId=[[np2 _Body] valueForKey:@"deviceId"];
    if ([[[np _Body] valueForKey:@"deviceId"] isEqualToString:myId]){
        NSLog(@"Ignore my own id package");
        return;
    }
    
    //deal with id package
        NSString* host;
    [GCDAsyncUdpSocket getHost:&host port:nil fromAddress:address];
    if ([host hasPrefix:@"::ffff:"]) {
        return;
    }
    
    NSLog(@"LanLinkProvider:id package received, creating link and a TCP connection socket");
    GCDAsyncSocket* socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    uint16_t tcpPort=[[[np _Body] valueForKey:@"tcpPort"] intValue];
    
    NSError* error=nil;
    if (![socket connectToHost:host onPort:tcpPort error:&error]) {
        NSLog(@"LanLinkProvider:tcp connection error");
        NSLog(@"try reverse connection");
        [[np2 _Body] setValue:[[NSNumber alloc ] initWithUnsignedInt:_tcpPort] forKey:@"tcpPort"];
        NSData* data=[np serialize];
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:UDPBROADCAST_TAG];
        return;
    }
    NSLog(@"connecting");
    
    //add to pending connection list
    @synchronized(_pendingNps)
    {
        [_pendingSockets insertObject:socket atIndex:_socketIndex];
        [_pendingNps insertObject:np atIndex:_socketIndex];
        _socketIndex++;
    }
    
}

- (void) onLinkDestroyed:(BaseLink*)link
{
    [_connectedLinks removeObject:link];
}


#pragma mark TCP Socket Delegate

/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 *
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 *
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"TCP server: didAcceptNewSocket");
	@synchronized(_pendingSockets)
    {
        [_pendingSockets insertObject:newSocket atIndex:_socketIndex];
        [_pendingNps insertObject:[NSNull null] atIndex:_socketIndex];
        _socketIndex++;
    }
    long index=[_pendingSockets indexOfObject:newSocket];
    //retrieve id package
    [newSocket readDataWithTimeout:-1 tag:index];
    
    
    [newSocket writeData:[GCDAsyncSocket LFData] withTimeout:KEEPALIVE_TIMEOUT tag:KEEPALIVE_TAG];
    [newSocket readDataWithTimeout:-1 tag:index];

}


/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"tcp socket didConnectToHost");    
    
    if ([_pendingSockets indexOfObject:sock]==NSNotFound) {
        NSLog(@"it's not a pending connection");
        return;
    }
    [sock setDelegate:nil];
    
    //create LanLink and inform the background
    NSUInteger index=[_pendingSockets indexOfObject:sock];
    NetworkPackage* np=[_pendingNps objectAtIndex:index];
//    LanLink* link=[[LanLink alloc] init:sock deviceId:[[np _Body] valueForKey:@"deviceId"] setDelegate:nil];
//    LanLink* link=[[LanLink alloc] init:[[np _Body] valueForKey:@"deviceId"] setDelegate:nil];
    [_pendingSockets removeObjectAtIndex:index];
    [_pendingNps removeObjectAtIndex:index];
//    [_connectedLinks addObject:link];
//    if (_linkProviderDelegate) {
//        [_linkProviderDelegate onConnectionReceived:np link:link];
//    }

    //send my id package
    np=[NetworkPackage createIdentityPackage];
//    [link sendPackage:np tag:PACKAGE_TAG_IDENTITY];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"tcp socket didReadData");
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NetworkPackage* np=[NetworkPackage unserialize:data];
    
    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]) {
        NSLog(@"expecting an id package");
        return;
    }
    

    //if it's a pendingConnection
    if ([_pendingSockets indexOfObject:sock]==NSNotFound) {
        NSLog(@"receive something from a connection not pending");
        return;
    }
    [sock setDelegate:nil];
    [_pendingSockets removeObject:sock];
    
    //create LanLink and inform the background
    LanLink* link=[[LanLink alloc] init:sock deviceId:[[np _Body] valueForKey:@"deviceId"] setDelegate:nil];
    [_connectedLinks addObject:link];
    if (_linkProviderDelegate) {
        [_linkProviderDelegate onConnectionReceived:np link:link];
    }
    
}


/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag==KEEPALIVE_TAG) {
        [sock writeData:[GCDAsyncSocket LFData] withTimeout:KEEPALIVE_TIMEOUT tag:KEEPALIVE_TAG];
    }
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
    if (tag==KEEPALIVE_TAG) {
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
    NSLog(@"tcp socket did Disconnect");
    int localport=[sock localPort];
    //FIX-ME can't get port of tcpserver when it's disconnected
    if (localport==_tcpPort) {
        NSLog(@"tcp server disconnected");
    }
    else
    {
        [_pendingSockets removeObject:sock];
        NSLog(@"tcp socket disconnected,remaining %lu pending connection",(unsigned long)[_pendingSockets count]);
    }
}

@end



























