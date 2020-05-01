//
//  Header.h
//  kdeconnect-ios
//
//  Created by Inoki on 30/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <Security/Security.h>

typedef struct __CFRuntimeBase {
    uintptr_t _cfisa;
    uint8_t _cfinfo[4];
#if __LP64__
    uint32_t _rc;
#endif
} CFRuntimeBase;

typedef struct
{   SSLReadFunc         read;
    SSLWriteFunc        write;
    SSLConnectionRef       ioRef;
} IOContext;

typedef enum
{
    SSL_HdskStateUninit = 0,            /* No Handshake yet */
    SSL_HdskStatePending,               /* Handshake in Progress */
    SSL_HdskStateReady,                 /* Handshake is done */
    SSL_HdskStateGracefulClose,
    SSL_HdskStateErrorClose,
    SSL_HdskStateNoNotifyClose,            /* Server disconnected with no notify msg */
    SSL_HdskStateOutOfBandError,        /* The caller encountered an error with out-of-band message processing */
} SSLHandshakeState;

struct SSLContext
{
    CFRuntimeBase        _base;
    IOContext           ioCtx;

    const struct SSLRecordFuncs *recFuncs;
    void *recCtx;

    void *hdsk;
    void *cache;
    int readCipher_ready;
    int writeCipher_ready;

    SSLHandshakeState   state;
    OSStatus outOfBandError;
};

#endif /* Header_h */
