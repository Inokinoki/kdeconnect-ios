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
    GCDAsyncUdpSocket *udpSocket;
    long tag;
}

+ (LanLinkProvider *) alloc
{
    return [super alloc];
}
- (LanLinkProvider*) init:(BackgroundService *)parent
{
    if ([super init:parent])
    {
        
    }
    
    return self;
}

- (void)setupSocket
{
	
	
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError* err=nil;
	[udpSocket enableBroadcast:true error:&err];
	NSError *error = nil;
}

- (void)onStart
{
    if (udpSocket==nil)
    {
        [self setupSocket];
    }
    NSError* error;
    bool bindSucceed=[udpSocket bindToPort:port error:&error];
    bool startSucceed=[udpSocket beginReceiving:&error];
    [self send];

}

- (void)onStop
{
    [udpSocket close];
}

- (void)onNetworkChange
{
    [self onStop];
    [self onStart];
}


- (void)send
{
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    NSData* data=[np serialize];
	[udpSocket sendData:data toHost:@"255.255.255.255" port:port withTimeout:-1 tag:tag];
	
	tag++;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NetworkPackage* np = [NetworkPackage unserialize:data];
    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY])
    {
        //not id package
        return;
    }
    else
    {
        //my own package
        NetworkPackage* np2=[NetworkPackage createIdentityPackage];
        NSString* myId=[[np2 _Body] valueForKey:@"deviceId"];
        if ([[[np _Body] valueForKey:@"deviceId"] isEqualToString:myId])
             return;
        NSLog(@"received my own broadcast package");
    }
    //deal with id package
    
}


@end



























