/*
 
 File: SecKeyWrapper.m
 Abstract: Core cryptographic wrapper class to exercise most of the Security 
 APIs on the iPhone OS. Start here if all you are interested in are the 
 cryptographic APIs on the iPhone OS.
 
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008-2009 Apple Inc. All Rights Reserved.
 
 */

#import "SecKeyWrapper.h"
#import <Security/Security.h>

#include <openssl/x509.h>
#include <openssl/err.h>

#import "kdeconnectconfig.h"

@implementation SecKeyWrapper

@synthesize publicTag, privateTag;

#if DEBUG
	#define LOGGING_FACILITY(X, Y)	\
					NSAssert(X, Y);	

	#define LOGGING_FACILITY1(X, Y, Z)	\
					NSAssert1(X, Y, Z);	
#else
	#define LOGGING_FACILITY(X, Y)	\
				if (!(X)) {			\
					NSLog(Y);		\
				}

	#define LOGGING_FACILITY1(X, Y, Z)	\
				if (!(X)) {				\
					NSLog(Y, Z);		\
				}						
#endif



#if TARGET_IPHONE_SIMULATOR
+ (SecKeyWrapper *)sharedWrapper { return nil; }
#else

// (See cssmtype.h and cssmapple.h on the Mac OS X SDK.)

enum {
	CSSM_ALGID_NONE =					0x00000000L,
	CSSM_ALGID_VENDOR_DEFINED =			CSSM_ALGID_NONE + 0x80000000L,
	CSSM_ALGID_AES
};

// identifiers used to find certificate, private key.
static const uint8_t certificateIdentifier[]	= kCertificateTag;
static const uint8_t privateKeyIdentifier[]		= kPrivateKeyTag;

static SecKeyWrapper * __sharedKeyWrapper = nil;

/* Begin method definitions */

+ (SecKeyWrapper *)sharedWrapper {
    @synchronized(self) {
        if (__sharedKeyWrapper == nil) {
            [[self alloc] init];
        }
    }
    return __sharedKeyWrapper;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (__sharedKeyWrapper == nil) {
            __sharedKeyWrapper = [super allocWithZone:zone];
            return __sharedKeyWrapper;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)release {
}

- (id)retain {
    return self;
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

-(id)init {
    if (self = [super init])
    {
     // Tag data to search for keys.
     privateTag = [[NSData alloc] initWithBytes:privateKeyIdentifier length:sizeof(privateKeyIdentifier)];
     // certificateTag = [[NSData alloc] initWithBytes:certificateIdentifier length:sizeof(certificateIdentifier)];
    }

	return self;
}

- (void)deleteAsymmetricKeys {
	OSStatus sanityCheck = noErr;
	NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
	
	// Set the public key query dictionary.
	[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	
	// Set the private key query dictionary.
	[queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
	[queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	
	// Delete the private key.
	sanityCheck = SecItemDelete((CFDictionaryRef)queryPrivateKey);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %d.", sanityCheck );
	
	// Delete the public key.
	sanityCheck = SecItemDelete((CFDictionaryRef)queryPublicKey);
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %d.", sanityCheck );
	
	[queryPrivateKey release];
	[queryPublicKey release];
	if (publicKeyRef) CFRelease(publicKeyRef);
	if (privateKeyRef) CFRelease(privateKeyRef);
}

- (void)generateKeyPair:(NSUInteger)keySize {
	OSStatus sanityCheck = noErr;
	publicKeyRef = NULL;
	privateKeyRef = NULL;
	
//	LOGGING_FACILITY1( keySize == 512 || keySize == 1024 || keySize == 2048, @"%d is an invalid and unsupported key size.", keySize );
	
	// First delete current keys.
	[self deleteAsymmetricKeys];
	
	// Container dictionaries.
	NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
	NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
	
	// Set top level dictionary for the keypair.
	[keyPairAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keySize] forKey:(id)kSecAttrKeySizeInBits];
	
	// Set the private key dictionary.
	[privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
	[privateKeyAttr setObject:privateTag forKey:(id)kSecAttrApplicationTag];
	// See SecKey.h to set other flag values.
	
	// Set the public key dictionary.
	[publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecAttrIsPermanent];
	[publicKeyAttr setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	// See SecKey.h to set other flag values.
	
	// Set attributes to top level dictionary.
	[keyPairAttr setObject:privateKeyAttr forKey:(id)kSecPrivateKeyAttrs];
	[keyPairAttr setObject:publicKeyAttr forKey:(id)kSecPublicKeyAttrs];
	
	// SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
	sanityCheck = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &publicKeyRef, &privateKeyRef);
	LOGGING_FACILITY( sanityCheck == noErr && publicKeyRef != NULL && privateKeyRef != NULL, @"Something really bad went wrong with generating the key pair." );
	
	[privateKeyAttr release];
	[publicKeyAttr release];
	[keyPairAttr release];
}

- (SecCertificateRef)addPeerCertificate:(NSString *)peerName keyBits:(NSData *)certificate {
	OSStatus sanityCheck = noErr;
	SecCertificateRef peerCertificateRef = NULL;
	CFTypeRef persistPeer = NULL;
	
	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	LOGGING_FACILITY( certificate != nil, @"Certificate parameter is nil." );
	
	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerCertificateAttr = [[NSMutableDictionary alloc] init];
	
	[peerCertificateAttr setObject:(id)kSecClassCertificate forKey:(id)kSecClass];
	[peerCertificateAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[peerCertificateAttr setObject:peerTag forKey:(id)kSecAttrApplicationTag];
	[peerCertificateAttr setObject:certificate forKey:(id)kSecValueData];
	[peerCertificateAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];
	
	sanityCheck = SecItemAdd((CFDictionaryRef) peerCertificateAttr, (CFTypeRef *)&persistPeer);
	
	// The nice thing about persistent references is that you can write their value out to disk and
	// then use them later. I don't do that here but it certainly can make sense for other situations
	// where you don't want to have to keep building up dictionaries of attributes to get a reference.
	// 
	// Also take a look at SecKeyWrapper's methods (CFTypeRef)getPersistentKeyRefWithKeyRef:(SecKeyRef)key
	// & (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef.
	
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecDuplicateItem, @"Problem adding the peer Certificate to the keychain, OSStatus == %d.", sanityCheck );
	
	if (persistPeer) {
		peerCertificateRef = [self getKeyRefWithPersistentKeyRef:persistPeer];
	} else {
		[peerCertificateAttr removeObjectForKey:(id)kSecValueData];
		[peerCertificateAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		// Let's retry a different way.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef) peerCertificateAttr, (CFTypeRef *)&peerCertificateRef);
	}
	
	LOGGING_FACILITY1( sanityCheck == noErr && peerCertificateRef != NULL, @"Problem acquiring reference to the Certificate, OSStatus == %d.", sanityCheck );
	
	[peerTag release];
	[peerCertificateAttr release];
	if (persistPeer) CFRelease(persistPeer);
	return peerCertificateRef;
}

- (SecKeyRef)addPeerRSAPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey {
    NSRange range;
    range.length=[publicKey length]-24*sizeof(uint8_t);
    range.location=24*sizeof(uint8_t);
    NSData* keybits=[publicKey subdataWithRange:range];
    return [self addPeerPublicKey:peerName keyBits:keybits];
}


- (void)removePeerCertificate:(NSString *)peerName {
	OSStatus sanityCheck = noErr;
	
	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	
	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerCertificateAttr = [[NSMutableDictionary alloc] init];
	
	[peerCertificateAttr setObject:(id)kSecClassCertificate forKey:(id)kSecClass];
	[peerCertificateAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[peerCertificateAttr setObject:peerTag forKey:(id)kSecAttrApplicationTag];
	
	sanityCheck = SecItemDelete((CFDictionaryRef) peerCertificateAttr);
	
	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Problem deleting the peer Certificate to the keychain, OSStatus == %d.", sanityCheck );
	
	[peerTag release];
	[peerCertificateAttr release];
}

- (NSData *)getHashBytes:(NSData *)plainText {
	CC_SHA1_CTX ctx;
	uint8_t * hashBytes = NULL;
	NSData * hash = nil;
	
	// Malloc a buffer to hold hash.
	hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
	memset((void *)hashBytes, 0x0, kChosenDigestLength);
	
	// Initialize the context.
	CC_SHA1_Init(&ctx);
	// Perform the hash.
	CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
	// Finalize the output.
	CC_SHA1_Final(hashBytes, &ctx);
	
	// Build up the SHA1 blob.
	hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
	
	if (hashBytes) free(hashBytes);
	
	return hash;
}

- (NSData *)getSignatureBytes:(NSData *)plainText {
	OSStatus sanityCheck = noErr;
	NSData * signedHash = nil;
	
	uint8_t * signedHashBytes = NULL;
	size_t signedHashBytesSize = 0;
	
	SecKeyRef privateKey = NULL;
	
	privateKey = [self getPrivateKeyRef];
	signedHashBytesSize = SecKeyGetBlockSize(privateKey);
	
	// Malloc a buffer to hold signature.
	signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
	memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
	
	// Sign the SHA1 hash.
	sanityCheck = SecKeyRawSign(	privateKey, 
									kTypeOfSigPadding, 
									(const uint8_t *)[[self getHashBytes:plainText] bytes], 
									kChosenDigestLength, 
									(uint8_t *)signedHashBytes, 
									&signedHashBytesSize
								);
	
	LOGGING_FACILITY1( sanityCheck == noErr, @"Problem signing the SHA1 hash, OSStatus == %d.", sanityCheck );
	
	// Build up signed SHA1 blob.
	signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
	
	if (signedHashBytes) free(signedHashBytes);
	
	return signedHash;
}

- (BOOL)verifySignature:(NSData *)plainText secKeyRef:(SecKeyRef)publicKey signature:(NSData *)sig {
	size_t signedHashBytesSize = 0;
	OSStatus sanityCheck = noErr;
	
	// Get the size of the assymetric block.
	signedHashBytesSize = SecKeyGetBlockSize(publicKey);
	
	sanityCheck = SecKeyRawVerify(	publicKey, 
									kTypeOfSigPadding, 
									(const uint8_t *)[[self getHashBytes:plainText] bytes],
									kChosenDigestLength, 
									(const uint8_t *)[sig bytes],
									signedHashBytesSize
								  );
	
	return (sanityCheck == noErr) ? YES : NO;
}

- (NSData *)doCipher:(NSData *)plainText key:(NSData *)symmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7 {
	CCCryptorStatus ccStatus = kCCSuccess;
	// Symmetric crypto reference.
	CCCryptorRef thisEncipher = NULL;
	// Cipher Text container.
	NSData * cipherOrPlainText = nil;
	// Pointer to output buffer.
	uint8_t * bufferPtr = NULL;
	// Total size of the buffer.
	size_t bufferPtrSize = 0;
	// Remaining bytes to be performed on.
	size_t remainingBytes = 0;
	// Number of bytes moved to buffer.
	size_t movedBytes = 0;
	// Length of plainText buffer.
	size_t plainTextBufferSize = 0;
	// Placeholder for total written.
	size_t totalBytesWritten = 0;
	// A friendly helper pointer.
	uint8_t * ptr;
	
	// Initialization vector; dummy in this case 0's.
	uint8_t iv[kChosenCipherBlockSize];
	memset((void *) iv, 0x0, (size_t) sizeof(iv));
	
	LOGGING_FACILITY(plainText != nil, @"PlainText object cannot be nil." );
	LOGGING_FACILITY(symmetricKey != nil, @"Symmetric key object cannot be nil." );
	LOGGING_FACILITY(pkcs7 != NULL, @"CCOptions * pkcs7 cannot be NULL." );
	LOGGING_FACILITY([symmetricKey length] == kChosenCipherKeySize, @"Disjoint choices for key size." );
			 
	plainTextBufferSize = [plainText length];
	
	LOGGING_FACILITY(plainTextBufferSize > 0, @"Empty plaintext passed in." );
	
	// We don't want to toss padding on if we don't need to
	if (encryptOrDecrypt == kCCEncrypt) {
		if (*pkcs7 != kCCOptionECBMode) {
			if ((plainTextBufferSize % kChosenCipherBlockSize) == 0) {
				*pkcs7 = 0x0000;
			} else {
				*pkcs7 = kCCOptionPKCS7Padding;
			}
		}
	} else if (encryptOrDecrypt != kCCDecrypt) {
		LOGGING_FACILITY1( 0, @"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7 );
	} 
	
	// Create and Initialize the crypto reference.
	ccStatus = CCCryptorCreate(	encryptOrDecrypt, 
								kCCAlgorithmAES128, 
								*pkcs7, 
								(const void *)[symmetricKey bytes], 
								kChosenCipherKeySize, 
								(const void *)iv, 
								&thisEncipher
							);
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem creating the context, ccStatus == %d.", ccStatus );
	
	// Calculate byte block alignment for all calls through to and including final.
	bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
	
	// Allocate buffer.
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
	
	// Zero out buffer.
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
	// Initialize some necessary book keeping.
	
	ptr = bufferPtr;
	
	// Set up initial size.
	remainingBytes = bufferPtrSize;
	
	// Actually perform the encryption or decryption.
	ccStatus = CCCryptorUpdate( thisEncipher,
								(const void *) [plainText bytes],
								plainTextBufferSize,
								ptr,
								remainingBytes,
								&movedBytes
							);
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus );
	
	// Handle book keeping.
	ptr += movedBytes;
	remainingBytes -= movedBytes;
	totalBytesWritten += movedBytes;
	
	// Finalize everything to the output buffer.
	ccStatus = CCCryptorFinal(	thisEncipher,
								ptr,
								remainingBytes,
								&movedBytes
							);
	
	totalBytesWritten += movedBytes;
	
	if (thisEncipher) {
		(void) CCCryptorRelease(thisEncipher);
		thisEncipher = NULL;
	}
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
	
	cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];

	if (bufferPtr) free(bufferPtr);
	
	return cipherOrPlainText;
	
	/*
	 Or the corresponding one-shot call:
	 
	 ccStatus = CCCrypt(	encryptOrDecrypt,
							kCCAlgorithmAES128,
							typeOfSymmetricOpts,
							(const void *)[self getSymmetricKeyBytes],
							kChosenCipherKeySize,
							iv,
							(const void *) [plainText bytes],
							plainTextBufferSize,
							(void *)bufferPtr,
							bufferPtrSize,
							&movedBytes
						);
	 */
}

- (NSData*)encryptDataToData:(NSData*)data withPublicKeyRef:(SecKeyRef)publickey
{
    NSArray* encryptedArray=[self encryptDataToArray:data withPublicKeyRef:publickey];
    NSMutableData* encryptedData=[NSMutableData data];
    for (NSData* d in encryptedArray) {
        [encryptedData appendData:d];
    }
    return encryptedData;
}

- (NSArray*)encryptDataToArray:(NSData *)data withPublicKeyRef:(SecKeyRef)publickey
{
    NSRange range;
    range.length=SecKeyGetBlockSize(publickey)-11;
    range.location=0;
    NSUInteger length=[data length];
    NSMutableArray* encryptedArray=[NSMutableArray arrayWithCapacity:1];
    while (length>0) {
        if (length<range.length) {
            range.length=length;
            length=0;
        }
        else{
            length-=range.length;
        }
        NSData* chunk=[data subdataWithRange:range];
        range.location+=range.length;
        chunk=[self wrapSymmetricKey:chunk keyRef:publickey];
        [encryptedArray addObject:[chunk base64EncodedStringWithOptions:0]];
    }
    return encryptedArray;
}

- (NSData*)decryptData:(NSData*)data
{
    NSMutableArray* encryptedArray=[NSMutableArray array];
    NSRange range;
    range.length=SecKeyGetBlockSize([self getPrivateKeyRef]);
    range.location=0;
    NSUInteger length=[data length];
    while (length>0) {
        if (length<range.length) {
            range.length=length;
            length=0;
        }
        else{
            length-=range.length;
        }
        NSData* chunk=[data subdataWithRange:range];
        range.location+=range.length;
        [encryptedArray addObject:[chunk base64EncodedStringWithOptions:0]];
    }
    return [self decryptDataArray:encryptedArray];
}

- (NSData*)decryptDataArray:(NSArray *)dataArray
{
    NSMutableData* decrypted=[NSMutableData data];
    for (NSString* dataStr in dataArray) {
        NSData* encryptedData=[[NSData alloc] initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData* decryptedData=[[SecKeyWrapper sharedWrapper] unwrapSymmetricKey:encryptedData];
        [decrypted appendData:decryptedData];
    }
    return decrypted;
}

- (SecKeyRef)getPublicKeyRef {
	OSStatus sanityCheck = noErr;
	SecKeyRef publicKeyReference = NULL;
	
	if (publicKeyRef == NULL) {
		NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
		
		// Set the public key query dictionary.
		[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
		[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
		[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
		[queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
		// Get the key.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyReference);
		
		if (sanityCheck != noErr)
		{
			publicKeyReference = NULL;
		}
		
		[queryPublicKey release];
	} else {
		publicKeyReference = publicKeyRef;
	}
	
	return publicKeyReference;
}

- (SecKeyRef)getPeerPublicKeyRef:(NSString*)peerName {
    OSStatus sanityCheck = noErr;
	SecKeyRef peerKeyRef = NULL;
	
	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	
	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];
	
	[peerPublicKeyAttr setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[peerPublicKeyAttr setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[peerPublicKeyAttr setObject:peerTag forKey:(id)kSecAttrApplicationTag];
	[peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];
    [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];

    sanityCheck = SecItemCopyMatching((CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);

//	LOGGING_FACILITY1( sanityCheck == noErr , @"Problem acquiring reference to the public key, OSStatus == %d.", (int)sanityCheck );
	
	[peerTag release];
	[peerPublicKeyAttr release];
	return peerKeyRef;
}

- (NSData *)getPublicKeyBits {
	OSStatus sanityCheck = noErr;
	NSData * publicKeyBits = nil;
	
	NSMutableDictionary * queryPublicKey = [[NSMutableDictionary alloc] init];
		
	// Set the public key query dictionary.
	[queryPublicKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
	[queryPublicKey setObject:publicTag forKey:(id)kSecAttrApplicationTag];
	[queryPublicKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
	[queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
		
	// Get the key bits.
	sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyBits);
		
	if (sanityCheck != noErr)
	{
		publicKeyBits = nil;
	}
		
	[queryPublicKey release];
	
	return publicKeyBits;
}

- (SecKeyRef)getPrivateKeyRef {
	OSStatus sanityCheck = noErr;
	SecKeyRef privateKeyReference = NULL;
	
	if (privateKeyRef == NULL) {
		NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
		
		// Set the private key query dictionary.
		[queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
		[queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
		[queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
		[queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
		
		// Get the key.
		sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyReference);
		
		if (sanityCheck != noErr)
		{
			privateKeyReference = NULL;
		}
		
		[queryPrivateKey release];
	} else {
		privateKeyReference = privateKeyRef;
	}
	
	return privateKeyReference;
}

- (NSData *)getPrivateKeyBits {
    OSStatus sanityCheck = noErr;
    NSData * privateKeyBits = nil;
    
    NSMutableDictionary * queryPrivateKey = [[NSMutableDictionary alloc] init];
        
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(id)kSecClassKey forKey:(id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(id)kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnData];
        
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKeyBits);
        
    if (sanityCheck != noErr)
    {
        privateKeyBits = nil;
    }
        
    [queryPrivateKey release];
    
    return privateKeyBits;
}

- (CFTypeRef)getPersistentKeyRefWithKeyRef:(SecKeyRef)keyRef {
	OSStatus sanityCheck = noErr;
	CFTypeRef persistentRef = NULL;
	
	LOGGING_FACILITY(keyRef != NULL, @"keyRef object cannot be NULL." );
	
	NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
	
	// Set the PersistentKeyRef key query dictionary.
	[queryKey setObject:(id)keyRef forKey:(id)kSecValueRef];
	[queryKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnPersistentRef];
	
	// Get the persistent key reference.
	sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryKey, (CFTypeRef *)&persistentRef);
	[queryKey release];
	
	return persistentRef;
}

- (SecCertificateRef)getCertificateRefWithPersistentCertificateRef:(CFTypeRef)persistentRef {
	OSStatus sanityCheck = noErr;
	SecCertificateRef certificateRef = NULL;
	
	LOGGING_FACILITY(persistentRef != NULL, @"persistentRef object cannot be NULL." );
	
	NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];
	
	// Set the SecCertificateRef query dictionary.
	[queryKey setObject:(id)persistentRef forKey:(id)kSecValuePersistentRef];
	[queryKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef];
	
	// Get the persistent key reference.public
	sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryKey, (CFTypeRef *)&certificateRef);
	[queryKey release];
	
	return certificateRef;
}


size_t encodeLength(unsigned char * buf, size_t length) {
    
    // encode length in ASN.1 DER format
    if (length < 128) {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length / 256) + 1;
    buf[0] = i + 0x80;
    for (size_t j = 0 ; j < i; ++j) {         buf[i - j] = length & 0xFF;         length = length >> 8;
    }
    
    return i + 1;
}

- (NSString *) getRSAPublicKeyAsBase64 {
    
    static const unsigned char _encodedRSAEncryptionOID[15] = {
        
        /* Sequence of length 0xd made up of OID followed by NULL */
        0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00
        
    };
    
    NSData * publicKeyBits=[self getPublicKeyBits];
    
    // OK - that gives us the "BITSTRING component of a full DER
    // encoded RSA public key - we now need to build the rest
    
    unsigned char builder[15];
    NSMutableData * encKey = [[NSMutableData alloc] init];
    int bitstringEncLength;
    
    // When we get to the bitstring - how will we encode it?
    if  ([publicKeyBits length ] + 1  < 128 )
        bitstringEncLength = 1 ;
    else
        bitstringEncLength = (([publicKeyBits length ] +1 ) / 256 ) + 2 ;
    
    // Overall we have a sequence of a certain length
    builder[0] = 0x30;    // ASN.1 encoding representing a SEQUENCE
    // Build up overall size made up of -
    // size of OID + size of bitstring encoding + size of actual key
    size_t i = sizeof(_encodedRSAEncryptionOID) + 2 + bitstringEncLength +
    [publicKeyBits length];
    size_t j = encodeLength(&builder[1], i);
    [encKey appendBytes:builder length:j +1];
    
    // First part of the sequence is the OID
    [encKey appendBytes:_encodedRSAEncryptionOID
                 length:sizeof(_encodedRSAEncryptionOID)];
    
    // Now add the bitstring
    builder[0] = 0x03;
    j = encodeLength(&builder[1], [publicKeyBits length] + 1);
    builder[j+1] = 0x00;
    [encKey appendBytes:builder length:j + 2];
    
    // Now the actual key
    [encKey appendData:publicKeyBits];
    
    // Now translate the result to a Base64 string
    
    NSString * ret =[encKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [encKey release];
    return ret;
}

- (void)dealloc {
    [privateTag release];
    [publicTag release];
	if (publicKeyRef) CFRelease(publicKeyRef);
	if (privateKeyRef) CFRelease(privateKeyRef);
    [super dealloc];
}

- (SecCertificateRef)getCertificate {
    OSStatus sanityCheck = noErr;
    SecCertificateRef certificateReference = NULL;
    
    if (privateKeyRef == NULL) {
        NSDictionary * queryCert = @{
            (id)kSecClass:                  (id)kSecClassCertificate,
//            (id)kSecAttrLabel:              @CERT_TAG,
            (id)kSecReturnRef:              [NSNumber numberWithBool:YES],
            (id)kSecReturnPersistentRef:    [NSNumber numberWithBool:YES]
        };

        // Get the key.
        sanityCheck = SecItemCopyMatching((CFDictionaryRef)queryCert, (CFTypeRef *)&certificateReference);
        
        if (sanityCheck != noErr)
        {
            certificateReference = NULL;
        }
        
        [queryCert release];
    } else {
        certificateReference = certificateRef;
    }
    
    return certificateReference;
}

- (void)generateCertificate {
/*    [self deleteX509Certificate];
        
    EVP_PKEY *pkey;
    pkey = d2i_PrivateKey(EVP_PKEY_RSA, NULL, &privateKey, privateKeyLength);
    
    if (pkey == NULL) {
        unsigned long err = ERR_get_error();
        NSLog(@"private key load failed %lu %s", err, ERR_error_string(err, NULL));
    } else {
        NSLog(@"private key load ok");
    }
    /*
    EVP_PKEY * pkey;
    pkey = EVP_PKEY_new();

    RSA * rsa;
    rsa = RSA_generate_key(
            2048,   /* number of bits for the key - 2048 is a sensible value */
    /*        RSA_F4, /* exponent - RSA_F4 is defined as 0x10001L */
    /*        NULL,   /* callback - can be NULL if we aren't displaying progress */
    /*        NULL    /* callback argument - not needed in this case */
    /*);

    EVP_PKEY_assign_RSA(pkey, rsa);
    */

/*    X509 * x509;
    x509 = X509_new();

    ASN1_INTEGER_set(X509_get_serialNumber(x509), 1);

    X509_gmtime_adj(X509_get_notBefore(x509), -60*60*24*365);
    X509_gmtime_adj(X509_get_notAfter(x509), 60*60*24*365*10);

    X509_set_pubkey(x509, pkey);

    X509_NAME * name;
    name = X509_get_subject_name(x509);

    X509_NAME_add_entry_by_txt(name, "C",  MBSTRING_ASC,
            (unsigned char *)"MyKDEConnectDevice", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O",  MBSTRING_ASC,
            (unsigned char *)"KDE", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "OU",  MBSTRING_ASC,
            (unsigned char *)"Kde connect iOS", -1, -1, 0);

    X509_set_issuer_name(x509, name);
    
    X509_sign(x509, pkey, EVP_sha1());

    unsigned char *certBytes = NULL;
    int length = -1;
    length = i2d_X509(x509, &certBytes);
    
    if (length < 0) {
        NSLog(@"Error export X509");
    } else {
        NSLog(@"export X509 %d", length);
        NSData *certData = [[NSData alloc] initWithBytes:certBytes length:length];
        SecCertificateRef cert = SecCertificateCreateWithData(nil, (__bridge CFDataRef) certData);
        if( cert != NULL ) {
            CFStringRef certSummary = SecCertificateCopySubjectSummary(cert);
            NSString* summaryString = [[NSString alloc] initWithString:(__bridge NSString*)certSummary];
            NSLog(@"CERT SUMMARY: %@", summaryString);
            CFRelease(certSummary);
        } else {
            NSLog(@"2222 *** ERROR *** trying to create the SSL certificate from data, but failed");
        }
        
        NSDictionary *addquery = @{
            (id)kSecValueRef:   (__bridge id)cert,
            (id)kSecClass:      (id)kSecClassCertificate,
            (id)kSecAttrLabel:  @CERT_TAG,
            (id)kSecReturnAttributes: (id)kCFBooleanTrue
        };
        
        CFDictionaryRef attrs = NULL;
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)addquery, (CFTypeRef *) &attrs);
        if (status != errSecSuccess) {
            NSLog(@"Store not OK %d", status);
        } else {
            NSLog(@"Store OK");
            
            NSDictionary * certAttrs = (__bridge NSDictionary *)attrs;
            NSData *issuer = [certAttrs objectForKey: (id)kSecAttrSerialNumber];
            NSData *serialNumber = [certAttrs objectForKey: (id)kSecAttrSerialNumber];

            NSLog(@"Identity finder: %@ - returned attributes were %@", issuer, serialNumber);
            
            NSDictionary *identityQuery = @{
                (id)kSecClass:      (id)kSecClassIdentity,
                //(id)kSecAttrIssuer: (id)issuer,
                //(id)kSecAttrSerialNumber: (id)serialNumber,
                (id)kSecReturnPersistentRef: (id)kCFBooleanTrue
            };
            
            CFDataRef identity = NULL;
            OSStatus copyStatus = SecItemCopyMatching((__bridge CFDictionaryRef)identityQuery, (CFTypeRef *) &identity);
            
            if (copyStatus != errSecSuccess) {
                NSLog(@"Identity not found, error: %d - returned attributes were %@", copyStatus, identity);
            } else {
                NSLog(@"Identity %@", identity);
            }
        }
        
        /*
         let issuer = certAttrs[kSecAttrIssuer] as! Data
         let serialNumber = certAttrs[kSecAttrSerialNumber] as! Data

         // Retrieve a persistent reference to the identity consisting of the client certificate and the pre-existing private key
         let copyArgs: [NSString: Any] = [
             kSecClass: kSecClassIdentity,
             kSecAttrIssuer: issuer,
             kSecAttrSerialNumber: serialNumber,
             kSecReturnPersistentRef: true] // we need returnPersistentRef here or the keychain makes a temporary identity that doesn't stick around, even though we don't use the persistentRef

         let copyStatus = SecItemCopyMatching(copyArgs as CFDictionary, &resultRef);
         guard copyStatus == errSecSuccess, let _ = resultRef as? Data else {
             log.error("Identity not found, error: \(copyStatus) - returned attributes were \(certAttrs)")
             throw KeychainError.cannotCreateIdentityPersistentRef(addStatus)
         }

         // no CFRelease(identityRef) due to swift
         */
        
//        CFRelease(cert);
//    }
}

- (void) loadCertificate
{
    
}

- (SecIdentityRef) getIdentity
{
    NSDictionary *copyArgs = @{
        (id)kSecClass:      (id)kSecClassIdentity,
        (id)kSecAttrLabel:  @"kdeconnect-identity",
        (id)kSecReturnRef:  (id)kCFBooleanTrue
    };
    
    SecIdentityRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) copyArgs, (__bridge CFTypeRef *) &result);
    
    if (status != errSecSuccess) {
        NSLog(@"Identity not found, error: %d", (int)status);
        return nil;
    }
    return result;
}
/*
static func getIdentity(label: String) -> SecIdentity? {
    let copyArgs: [NSString: Any] = [
        kSecClass: kSecClassIdentity,
        kSecAttrLabel: label,
        kSecReturnRef: true ]

    var resultRef: AnyObject?
    let copyStatus = SecItemCopyMatching(copyArgs as CFDictionary, &resultRef)
    guard copyStatus == errSecSuccess else {
        log.error("Identity not found, error: \(copyStatus)")
        return nil
    }

    // back when this function was all ObjC we would __bridge_transfer into ARC, but swift can't do that
    // It wants to manage CF types on it's own which is fine, except they release when we return them out
    // back into ObjC code.
    return (resultRef as! SecIdentity)
}
 */

#endif

@end
