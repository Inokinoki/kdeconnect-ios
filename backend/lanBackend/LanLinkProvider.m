//Copyright 27/4/14  YANG Qiao yangqiao0505@me.com
//kdeconnect is distributed under two licenses.
//
//* The Mozilla Public License (MPL) v2.0
//
//or
//
//* The General Public License (GPL) v2.1
//
//----------------------------------------------------------------------
//
//Software distributed under these licenses is distributed on an "AS
//IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
//implied. See the License for the specific language governing rights
//and limitations under the License.
//kdeconnect is distributed under both the GPL and the MPL. The MPL
//notice, reproduced below, covers the use of either of the licenses.
//
//----------------------------------------------------------------------

#import "LanLinkProvider.h"
#import "NetworkPackage.h"

#import <Security/Security.h>
#import <Security/SecItem.h>
#import <Security/SecTrust.h>
#import <Security/CipherSuite.h>
#import <Security/SecIdentity.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/pkcs12.h>

@interface LanLinkProvider()
{
    uint16_t _tcpPort;
    dispatch_queue_t socketQueue;
}
@property(nonatomic) GCDAsyncUdpSocket* _udpSocket;
@property(nonatomic) GCDAsyncSocket* _tcpSocket;
@property(nonatomic) NSMutableArray* _pendingSockets;
@property(nonatomic) NSMutableArray* _pendingNps;
@property(nonatomic) SecCertificateRef _certificate;
//@property(nonatomic) NSString * _certificateRequestPEM;
@property(nonatomic) SecIdentityRef _identity;
@end

@implementation LanLinkProvider

@synthesize _connectedLinks;
@synthesize _linkProviderDelegate;
@synthesize _pendingNps;
@synthesize _pendingSockets;
@synthesize _tcpSocket;
@synthesize _udpSocket;
@synthesize _certificate;
//@synthesize _certificateRequestPEM;
@synthesize _identity;

- (LanLinkProvider*) initWithDelegate:(id)linkProviderDelegate
{
    if ([super initWithDelegate:linkProviderDelegate])
    {
        _tcpPort=MIN_TCP_PORT;
        [_tcpSocket disconnect];
        [_udpSocket close];
        _udpSocket=nil;
        _tcpSocket=nil;
        _pendingSockets=[NSMutableArray arrayWithCapacity:1];
        _pendingNps=[NSMutableArray arrayWithCapacity:1];
        _connectedLinks=[NSMutableDictionary dictionaryWithCapacity:1];
        _linkProviderDelegate=linkProviderDelegate;
        socketQueue=dispatch_queue_create("com.kde.org.kdeconnect.socketqueue", NULL);
        
        // Load private key and certificate
        _identity = NULL;
        [self loadSecIdentity];
    }

    return self;
}

- (void) loadSecIdentity
{
    BOOL needGenerateCertificate = NO;

    NSString *resourcePath = NULL;
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (NSString *directory in documentDirectories) {
        NSLog(@"Find %@", directory);
        resourcePath = [directory stringByAppendingString:@"/rsaPrivate.p12"];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (resourcePath != NULL && [fileManager fileExistsAtPath:resourcePath]) {
        NSData *p12Data = [NSData dataWithContentsOfFile:resourcePath];

        NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
        [options setObject:@"" forKey:(id)kSecImportExportPassphrase];  // No password

        CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
        OSStatus securityError = SecPKCS12Import((CFDataRef) p12Data,
                                                 (CFDictionaryRef)options, &items);
        SecIdentityRef identityApp;
        if (securityError == noErr && CFArrayGetCount(items) > 0) {
            SecKeyRef privateKeyRef = NULL;
            CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);

            identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                               kSecImportItemIdentity);

            securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
            if (securityError != noErr) {
                // Fail to retrieve private key from the .p12 file
                needGenerateCertificate = YES;
            } else {
                _identity = identityApp;
                NSLog(@"Certificate loaded successfully from %@", resourcePath);
            }
        } else {
            // Not valid component in the .p12 file
            needGenerateCertificate = YES;
        }
    } else {
        // No .p12 file
        needGenerateCertificate = YES;
    }
    
    if (needGenerateCertificate) {
        // generate certificate
        NSLog(@"Need generate certificate");
        [self generateAndLoadSecIdentity];
    }
}

- (void) generateSecIdentity
{
    // generate private key
    EVP_PKEY * pkey;
    pkey = EVP_PKEY_new();

    RSA * rsa;
    rsa = RSA_generate_key(
            2048,   /* number of bits for the key - 2048 is a sensible value */
            RSA_F4, /* exponent - RSA_F4 is defined as 0x10001L */
            NULL,   /* callback - can be NULL if we aren't displaying progress */
            NULL    /* callback argument - not needed in this case */
    );
    EVP_PKEY_assign_RSA(pkey, rsa);

    // generate cert
    X509 *x509;
    x509 = X509_new();

    ASN1_INTEGER_set(X509_get_serialNumber(x509), 10);

    X509_gmtime_adj(X509_get_notBefore(x509), 0);
    X509_gmtime_adj(X509_get_notAfter(x509), 31536000L);

    X509_set_pubkey(x509, pkey);

    X509_NAME *name;
    name = X509_get_subject_name(x509);

    X509_NAME_add_entry_by_txt(name, "OU", MBSTRING_ASC,    // OU = organisational unit
            (unsigned char *)"Kde connect", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O",  MBSTRING_ASC,    // O = organization
            (unsigned char *)"KDE", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC,    // CN = common name, TODO: uuid
            (unsigned char *)[[NetworkPackage getUUID] UTF8String], -1, -1, 0);

    X509_set_issuer_name(x509, name);
    
    if (!X509_sign(x509, pkey, EVP_md5())) {
        @throw [[NSException alloc] initWithName:@"Fail sign cert" reason:@"Error" userInfo:nil];
    }

    if (!X509_check_private_key(x509, pkey)) {
        @throw [[NSException alloc] initWithName:@"Fail validate cert" reason:@"Error" userInfo:nil];
    }

    // load algo and encryption components
    SSLeay_add_all_algorithms();
    ERR_load_crypto_strings();

    // create p12 format data
    PKCS12 *p12 = NULL;
    p12 = PKCS12_create(/* password */ "", /* name */ "KDE Connect", pkey, x509,
                        /* ca */ NULL, /* nid_key */ 0, /* nid_cert */ 0,
                        /* iter */ 0, /* mac_iter */ PKCS12_DEFAULT_ITER, /* keytype */ 0);
    if(!p12) {
        @throw [[NSException alloc] initWithName:@"Fail getP12File" reason:@"Error creating PKCS#12 structure" userInfo:nil];
    }

    // write into `Documents/rsaPrivate.p12`
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *p12FilePath = NULL;
    for (NSString *directory in documentDirectories) {
        NSLog(@"Find %@", directory);
        p12FilePath = [directory stringByAppendingString:@"/rsaPrivate.p12"];
    }
    if (![[NSFileManager defaultManager] createFileAtPath:p12FilePath contents:nil attributes:nil])
    {
        NSLog(@"Error creating file for P12");
        @throw [[NSException alloc] initWithName:@"Fail getP12File" reason:@"Fail Error creating file for P12" userInfo:nil];
    }

    // get a FILE struct for the P12 file
    NSFileHandle *outputFileHandle = [NSFileHandle fileHandleForWritingAtPath:p12FilePath];
    FILE *p12File = fdopen([outputFileHandle fileDescriptor], "w");

    i2d_PKCS12_fp(p12File, p12);
    PKCS12_free(p12);
    fclose(p12File);
    [outputFileHandle closeFile];
}

- (void) generateAndLoadSecIdentity
{
    [self generateSecIdentity];

    // Recall the method to load private key and certificate again
    [self loadSecIdentity];
}

- (void)setupSocket
{
    //NSLog(@"lp setup socket");
    NSError* err;
    _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    if (![_udpSocket enableBroadcast:true error:&err]) {
        NSLog(@"udp listen broadcast error");
    }
    if (![_udpSocket bindToPort:UDP_PORT error:&err]) {
        NSLog(@"udp bind error");
    }
}

- (void)onStart
{
    NSLog(@"lp onstart");
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
            if (_tcpPort > MAX_TCP_PORT) {
                _tcpPort = MIN_TCP_PORT;
            }
        }
    }
    
    NSLog(@"LanLinkProvider:setup tcp socket on port %d",_tcpPort);
    
    //Introduce myself , UDP broadcasting my id package
    NetworkPackage* np=[NetworkPackage createIdentityPackage];
    [np setInteger:_tcpPort forKey:@"tcpPort"];
    NSData* data=[np serialize];
    NSLog(@"sending:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	[_udpSocket sendData:data  toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:UDPBROADCAST_TAG];
}

- (void)onStop
{
    //NSLog(@"lp onstop");
    [_udpSocket close];
    [_tcpSocket disconnect];
    for (GCDAsyncSocket* socket in _pendingSockets) {
        [socket disconnect];
    }
    for (LanLink* link in [_connectedLinks allValues]) {
        [link disconnect];
    }
    
    [_pendingNps removeAllObjects];
    [_pendingSockets removeAllObjects];
    [_connectedLinks removeAllObjects];
    _udpSocket=nil;
    _tcpSocket=nil;

}

- (void) onRefresh
{
    //NSLog(@"lp on refresh");
    if (![_tcpSocket isConnected]) {
        [self onNetworkChange];
        return;
    }
    if (![_udpSocket isClosed]) {
        NetworkPackage* np=[NetworkPackage createIdentityPackage];
        [np setInteger:_tcpPort forKey:@"tcpPort"];
        NSData* data=[np serialize];
        NSLog(@"sending:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [_udpSocket sendData:data toHost:@"255.255.255.255" port:PORT withTimeout:-1 tag:UDPBROADCAST_TAG];
    }
}

- (void)onNetworkChange
{
    NSLog(@"lp on networkchange");
    [self onStop];
    [self onStart];
}


- (void) onLinkDestroyed:(BaseLink*)link
{
    //NSLog(@"lp on linkdestroyed");
    if (link==[_connectedLinks objectForKey:[link _deviceId]]) {
        [_connectedLinks removeObjectForKey:[link _deviceId]];
    }
}

#pragma mark UDP Socket Delegate
/**
 * Called when the socket has received the requested datagram.
 **/

//a new device is introducing itself to me
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"lp receive udp package");
	NetworkPackage* np = [NetworkPackage unserialize:data];
    NSLog(@"linkprovider:received a udp package from %@",[np objectForKey:@"deviceName"]);
    //not id package
    
    if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]){
        NSLog(@"LanLinkProvider:expecting an id package");
        return;
    }
    
    //my own package
    NetworkPackage* np2=[NetworkPackage createIdentityPackage];
    NSString* myId=[[np2 _Body] valueForKey:@"deviceId"];
    if ([[np objectForKey:@"deviceId"] isEqualToString:myId]){
        NSLog(@"Ignore my own id package");
        return;
    }
    
    //deal with id package
    NSString* host;
    [GCDAsyncUdpSocket getHost:&host port:nil fromAddress:address];
    if ([host hasPrefix:@"::ffff:"]) {
        NSLog(@"Ignore packet");
        return;
    }
    
    NSLog(@"LanLinkProvider:id package received, creating link and a TCP connection socket");
    GCDAsyncSocket* socket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    uint16_t tcpPort=[np integerForKey:@"tcpPort"];
    
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
    
    NetworkPackage *inp = [NetworkPackage createIdentityPackage];
    NSData *inpData = [inp serialize];
    [socket writeData:inpData withTimeout:0 tag:PACKAGE_TAG_IDENTITY];
    
    //add to pending connection list
    @synchronized(_pendingNps)
    {
        [_pendingSockets insertObject:socket atIndex:0];
        [_pendingNps insertObject:np atIndex:0];
    }
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
    [_pendingSockets addObject:newSocket];
    long index=[_pendingSockets indexOfObject:newSocket];
    //retrieve id package
    [newSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:index];
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    // Temporally disable
    [sock setDelegate:nil];
    NSLog(@"tcp socket didConnectToHost %@", host);

    //create LanLink and inform the background
    NSUInteger index=[_pendingSockets indexOfObject:sock];
    NetworkPackage* np=[_pendingNps objectAtIndex:index];
    NSString* deviceId=[np objectForKey:@"deviceId"];

    /* Test with cert file */
    NSArray *myCipherSuite = [[NSArray alloc] initWithObjects:
        [NSNumber numberWithInt: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256],
        [NSNumber numberWithInt: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384],
        [NSNumber numberWithInt: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA],
    nil];
    NSArray *myCerts = [[NSArray alloc] initWithObjects: (__bridge id)_identity, nil];
    NSDictionary *tlsSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
         (id)[NSNumber numberWithBool:YES],        (id)kCFStreamSSLIsServer,
         (__bridge CFArrayRef) myCipherSuite,   (id)GCDAsyncSocketSSLCipherSuites,
         (__bridge CFArrayRef) myCerts,         (id)kCFStreamSSLCertificates,
    nil];
    // (id)kCFBooleanTrue,                    (id)GCDAsyncSocketManuallyEvaluateTrust,

    NSLog(@"Start Server TLS");
    [sock startTLS:tlsSettings];
    
    LanLink* oldlink;
    if ([[_connectedLinks allKeys] containsObject:deviceId]) {
        oldlink=[_connectedLinks objectForKey:deviceId];
    }
    
    LanLink* link=[[LanLink alloc] init:sock deviceId:[np objectForKey:@"deviceId"] setDelegate:nil];
    [_pendingSockets removeObject:sock];
    [_pendingNps removeObject:np];
    [_connectedLinks setObject:link forKey:[np objectForKey:@"deviceId"]];
    if (_linkProviderDelegate) {
        [_linkProviderDelegate onConnectionReceived:np link:link];
    }
    [oldlink disconnect];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"lp tcp socket didReadData");
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString * jsonStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* packageArray=[jsonStr componentsSeparatedByString:@"\n"];
    return;
    for (NSString* dataStr in packageArray) {
        if ([dataStr length] <= 0) continue;

        NetworkPackage* np=[NetworkPackage unserialize:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
        if (![[np _Type] isEqualToString:PACKAGE_TYPE_IDENTITY]) {
            NSLog(@"lp expecting an id package %@", [np _Type]);
            return;
        }
        NSString* deviceId=[np objectForKey:@"deviceId"];

        /* Test with cert file */
        NSArray *myCerts = [[NSArray alloc] initWithObjects:(__bridge id)_identity, /*(__bridge id)cert2UseRef,*/ nil];

        /*NSLog(@"%@", _certificate);*/
        NSArray *myCipherSuite = [[NSArray alloc] initWithObjects:
                                  [[NSNumber alloc] initWithInt: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256],
                                  [[NSNumber alloc] initWithInt: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384],
                                  [[NSNumber alloc] initWithInt: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA],
                                  nil];
        /* TLS */
        NSDictionary *tlsSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
             //(id)kCFStreamSocketSecurityLevelNegotiatedSSL, (id)kCFStreamSSLLevel,
             //(id)kCFBooleanFalse,       (id)kCFStreamSSLAllowsExpiredCertificates,  /* Disallowed expired certificate   */
             //(id)kCFBooleanFalse,       (id)kCFStreamSSLAllowsExpiredRoots,         /* Disallowed expired Roots CA      */
             //(id)kCFBooleanTrue,        (id)kCFStreamSSLAllowsAnyRoot,              /* Allow any root CA                */
             //(id)kCFBooleanFalse,       (id)kCFStreamSSLValidatesCertificateChain,  /* Do not validate all              */
             (id)deviceId,              (id)kCFStreamSSLPeerName,                   /* Set peer name to the one we received */
             // (id)[[SecKeyWrapper sharedWrapper] getPrivateKeyRef], (id),
             //(id)kCFBooleanTrue,        (id)GCDAsyncSocketManuallyEvaluateTrust,
             (__bridge CFArrayRef) myCerts, (id)kCFStreamSSLCertificates,
             (__bridge CFArrayRef) myCipherSuite, (id)GCDAsyncSocketSSLCipherSuites,
             (id)[NSNumber numberWithInt:0],       (id)kCFStreamSSLIsServer,
             //(id)[NSNumber numberWithInt:kAlwaysAuthenticate], (id)GCDAsyncSocketSSLClientSideAuthenticate,
             (id)[NSNumber numberWithInt:1], (id)GCDAsyncSocketManuallyEvaluateTrust,
             nil];
        
        [sock startTLS: tlsSettings];
        NSLog(@"Start Client TLS");
        
        [sock setDelegate:nil];
        [_pendingSockets removeObject:sock];
        
        LanLink* oldlink;
        if ([[_connectedLinks allKeys] containsObject:deviceId]) {
            oldlink=[_connectedLinks objectForKey:deviceId];
        }
        //create LanLink and inform the background
        LanLink* link=[[LanLink alloc] init:sock deviceId:[np objectForKey:@"deviceId"] setDelegate:nil];
        [_connectedLinks setObject:link forKey:[np objectForKey:@"deviceId"]];
        if (_linkProviderDelegate) {
            [_linkProviderDelegate onConnectionReceived:np link:link];
        }
        [oldlink disconnect];
    }
    
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
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
    //NSLog(@"tcp socket did Disconnect");
    if (sock==_tcpSocket) {
        //NSLog(@"tcp server disconnected");
        _tcpSocket=nil;
    }
    else
    {
        [_pendingSockets removeObject:sock];
    }
}

- (BOOL)socketShouldManuallyEvaluateTrust:(GCDAsyncSocket *)sock
{
    NSLog(@"Should Evaluate Certificate LanLinkProvider");
    return YES;
}

- (BOOL)socket:(GCDAsyncSocket *)sock shouldTrustPeer:(SecTrustRef)trust
{
    NSLog(@"Trust Certificate from %@ LanLinkProvider", [sock connectedHost]);
    return YES;
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"Connection is secure LanLinkProvider");
    [sock setDelegate:nil];
    [_pendingSockets removeObject:sock];
    
    /* TODO: remove the old link */
//    LanLink* oldlink;
//    if ([[_connectedLinks allKeys] containsObject:deviceId]) {
//        oldlink=[_connectedLinks objectForKey:deviceId];
//    }
    //create LanLink and inform the background
    LanLink* link=[[LanLink alloc] init:sock deviceId:@"Test Object" setDelegate:nil];
    [_connectedLinks setObject:link forKey:@"Test Object"];
//    [oldlink disconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    completionHandler(YES);

    NSLog(@"Receive Certificate, Trust it LanLinkProvider");
}


@end



























