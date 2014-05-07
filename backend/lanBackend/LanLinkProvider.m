//
//  LanLinkProvider.m
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "LanLinkProvider.h"
static int PORT=1714;
@implementation LanLinkProvider
{
    __strong BackgroundService* _parent;
    __strong GCDAsyncUdpSocket* _udpSocket;
    __strong GCDAsyncSocket* _tcpSocket;
    __strong NSMutableDictionary* _pendingConnections;
    long _index;
    uint16_t _tcpPort;
}
- (LanLinkProvider*) init:(BackgroundService *)parent
{
    if ([super init:parent])
    {
        
    }
    _tcpPort=PORT;
    _pendingConnections=[NSMutableDictionary dictionaryWithCapacity:1];
    __visibleComputers=[NSMutableDictionary dictionaryWithCapacity:1];
    socketQueue=dispatch_queue_create("socketQueue", NULL);
    return self;
    }

- (void)setupSocket
{
    if (_tcpSocket==nil) {
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    }
    if (_udpSocket==nil) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        NSError* err;
        if (![_udpSocket bindToPort:PORT error:&err]) {
            NSLog(@"udp bind error");
        }
        
        [_udpSocket enableBroadcast:true error:&err];
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
    while (![_tcpSocket acceptOnPort:_tcpPort error:&err]) {
        _tcpPort++;
    }
    NSLog(@"LanLinkProvider:setup tcp socket on port %d",_tcpPort);
    
    //Introduce myself , UDP broadcasting my id package
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    [[np _Body] setValue:[[NSNumber alloc ] initWithUnsignedInt:_tcpPort] forKey:@"tcpPort"];
    NSData* data=[np serialize];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	[_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:0];
}

- (void)onStop
{
    [_udpSocket close];
    [_tcpSocket disconnect];
    for (NSDictionary* connection in _pendingConnections) {
        [[connection valueForKey:@"socket"] disconnect];
    }
    for (NSDictionary* connection in __visibleComputers) {
        [[connection valueForKey:@"socket"] disconnect];
    }
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
    NSLog(@"LanLinkProvider:id package received, creating link and a TCP connection socket");
    GCDAsyncSocket* socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    uint16_t tcpPort=[[[np _Body] valueForKey:@"tcpPort"] intValue];
    NSString* host;
    uint16_t udpPort;
    [GCDAsyncUdpSocket getHost:&host port:&udpPort fromAddress:address];
    NSError* error=nil;
    bool success=[socket connectToHost:host onPort:tcpPort error:&error];
    if (!success) {
        NSLog(@"LanLinkProvider:tcp connection error");
        NSLog(@"try reverse connection");
        [[np2 _Body] setValue:[[NSNumber alloc ] initWithUnsignedInt:_tcpPort] forKey:@"tcpPort"];
        NSData* data=[np serialize];
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:0];
        return;
    }
    NSLog(@"connecting");
    
    
    //add to pending connection list
    NSMutableDictionary *connection=[NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:np,nil] forKeys:[NSArray arrayWithObjects:@"np", nil]];
    [_pendingConnections setValue:connection forKey:host];
    
}

- (void) onLinkDestroyed
{
    
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
	NSString *host = [newSocket connectedHost];
    if ([host hasPrefix:@"::ffff:"]) {
        return;
    }
    NSMutableDictionary *connection=[NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:sock, nil] forKeys:[NSArray arrayWithObjects:@"socket", nil]];
    [_pendingConnections setValue:connection forKey:host];
    
    //retrieve id package
    [newSocket readDataWithTimeout:-1 tag:0];
    
    // TODO  pair request, move to other places
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PING];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"pair"];
    [[np _Body] setValue:@"qwefsdv1241234asvqwefbgwerf1345" forKey:@"publickey"];
    NSMutableData* data;
    data= [NSMutableData dataWithData:[np serialize]];
    [data appendData:[GCDAsyncSocket LFData]];
    NSLog(@"%@\n",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    [newSocket writeData:data withTimeout:-1 tag:0];
    [newSocket readDataWithTimeout:-1 tag:0];

}


/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"tcp socket didConnectToHost");
    [sock setDelegate:self];
    
    NSMutableDictionary* connection;
    
    connection=[__visibleComputers objectForKey:host];
    if (connection) {
        NSLog(@"it's a visibleComputer connection");
        [__visibleComputers removeObjectForKey:host];
    }
    NSLog(@"it's a new computer connection");
    
    connection=[_pendingConnections valueForKey:host];
    if (!connection) {
        NSLog(@"it's not a pending connection");
        return;
    }
    [_pendingConnections removeObjectForKey:host];
    
    [sock setDelegate:nil];
    
    connection=[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sock, nil] forKeys:[NSArray arrayWithObjects:@"socket", nil]];

    [__visibleComputers setValue:connection forKey:host];
    
    //create LanLink and inform the background
    NetworkPackage* np=[connection valueForKey:@"np"];
    LanLink* link=[[LanLink alloc] init:sock deviceId:[[np _Body] valueForKey:@"deviceId"] provider:self];
    [_parent onConnectionReceived:np link:link];
    
    //send my id package
    np=[NetworkPackage createIdentityPackage];
    [link sendPackage:np];
    
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"tcp socket didReadData");
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString *host = [sock connectedHost];
    NetworkPackage* np=[NetworkPackage unserialize:data];
    
    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]) {
        NSLog(@"expecting an id package");
        return;
    }
    
    NSMutableDictionary* connection=[_pendingConnections valueForKey:host];
    //if it's a pendingConnection
    if ( !connection ) {
        NSLog(@"receive something from a connection not pending");
        return;
    }
    [sock setDelegate:nil];
    [connection setValue:np forKey:@"np"];
    [__visibleComputers setValue:connection forKey:host];
    [_pendingConnections removeObjectForKey:host];
    //create LanLink and inform the background
    LanLink* link=[[LanLink alloc] init:sock deviceId:[[np _Body] valueForKey:@"deviceId"] provider:self];
    [_parent onConnectionReceived:np link:link];
    
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
    if ([sock localPort]==_tcpPort) {
        NSLog(@"tcp server disconnected");
    }
    else
    {

        NSLog(@"tcp socket disconnected,remaining %lu connection",(unsigned long)[_pendingConnections count]);
    }
}
@end



























