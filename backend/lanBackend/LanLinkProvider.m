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
    BackgroundService* _parent;
    GCDAsyncUdpSocket* _udpSocket;
    GCDAsyncSocket* _tcpSocket;
    long tag;
    uint16_t _tcpPort;
}
- (LanLinkProvider*) init:(BackgroundService *)parent
{
    if ([super init:parent])
    {
        
    }
    _tcpPort=PORT;
    __pendingConnections=[NSMutableDictionary dictionaryWithCapacity:1];
    __visibleComputers=[NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

- (void)setupSocket
{
    if (_tcpSocket==nil) {
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if (_udpSocket==nil) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    NSError* err=nil;
	[_udpSocket enableBroadcast:true error:&err];
}

- (void)onStart
{
    
    [self setupSocket];
    NSError* err;
    bool bindSucceed=[_udpSocket bindToPort:PORT error:&err];
    bool startSucceed=[_udpSocket beginReceiving:&err];
    NSLog(@"LanLinkProvider:UDP socket start:%d",startSucceed);
    while (![_tcpSocket acceptOnPort:_tcpPort error:&err]) {
        _tcpPort++;
    }
    NSLog(@"LanLinkProvider:setup tcp socket on port %d",_tcpPort);
    
    //Introduce myself , UDP broadcasting my id package
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    [[np _Body] setValue:[[NSNumber alloc ] initWithUnsignedInt:_tcpPort] forKey:@"tcpPort"];
    NSData* data=[np serialize];
    NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//	[_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:tag];
	tag++;
}

- (void)onStop
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
    NSLog(@"LanLinkProvider:id package received, creating link and a TCP connection socket");
    GCDAsyncSocket* socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    uint16_t tcpPort=[[[np _Body] valueForKey:@"tcpPort"] intValue];
    NSString* host=[[np _Body] valueForKey:@"deviceName"];
    NSError* error=nil;
    bool success=[socket connectToHost:host onPort:tcpPort error:&error];
    if (!success) {
        NSLog(@"LanLinkProvider:tcp connection error");
        return;
    }
    else
    {
        NSLog(@"connecting");
    }
    
//    [self addLink:np lanLink:link];
    
    
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
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
	// This method is executed on the socketQueue (not the main thread)
	NSLog(@"TCP server: didAcceptNewSocket");
	NSString *host = [newSocket connectedHost];
    NSMutableDictionary *connection=[NSMutableDictionary dictionaryWithObjects:[NSMutableArray arrayWithObjects:sock, nil] forKeys:[NSArray arrayWithObjects:@"socket", nil]];
    [__pendingConnections setValue:connection forKey:host];
//	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
//	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
//	
//	[newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
//
    
    [newSocket readDataWithTimeout:-1 tag:0];
    NSData* data;
    NetworkPackage* np=[[NetworkPackage alloc] init:PACKAGE_TYPE_PAIR];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"pair"];
    [[np _Body] setValue:@"qwefsdv1241234asvqwefbgwerf1345" forKey:@"publickey"];
    data=[np serialize];
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
    
    NSMutableDictionary* connection=[__pendingConnections valueForKey:host];
    if (connection) {
        NSLog(@"it's a pending connection");
        [__pendingConnections removeObjectForKey:host];
    }
    connection=[__visibleComputers objectForKey:host];
    if (connection) {
        NSLog(@"it's a visibleComputer connection");
        [__visibleComputers removeObjectForKey:host];
    }
    connection=[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sock, nil] forKeys:[NSArray arrayWithObjects:@"socket", nil]];

    [__visibleComputers setValue:connection forKey:host];
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    NSData* data=[np serialize];
    [sock writeData:data withTimeout:-1 tag:0];
    
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"tcp socket didReadData");
    NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString *host = [sock connectedHost];
	UInt16 port = [sock connectedPort];
    NetworkPackage* np=[NetworkPackage unserialize:data];
    
    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]) {
        NSLog(@"expecting an id package");
        return;
    }
    
    NSMutableDictionary* connection=[__pendingConnections valueForKey:host];
    //if it's a pendingConnection
    if ( !connection ) {
        NSLog(@"receive something from a connection not pending");
    }
    [connection setValue:np forKey:@"np"];
    [__visibleComputers setValue:connection forKey:host];
    [__pendingConnections removeObjectForKey:host];
    //clear delegate
//    [sock setDelegate:nil];
    LanLink* link=[[LanLink alloc] init:sock deviceId:[[np _Body] valueForKey:@"deviceId"] provider:self];
    [_parent onConnectionReceived:np link:link];
    
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"tcp socket didWriteData");
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"tcp socket didWritePartialData");
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
    if (elapsed>30) {
        [sock disconnect];
    }
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
    NSLog(@"writetimeout");
    return 0;
}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    
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

        NSLog(@"tcp socket disconnected,remaining %d connection",[__pendingConnections count]);
    }
}
@end



























