//
//  kdeconnectconfig.m
//  kdeconnect-ios
//
//  Created by Inoki on 02/05/2020.
//  Copyright © 2020 Weixuan XIAO. All rights reserved.
//

#include <openssl/x509.h>
#include <openssl/err.h>

#import "kdeconnectconfig.h"

#import "KeychainItemWrapper.h"

#define KEYSTORE_UUID "org.kde.kdeconnect.ios.uuid"

@implementation KDEConnectConfig

#if TARGET_IPHONE_SIMULATOR
// Cannot be used in simulator
+ (KDEConnectConfig *)sharedInstance    { return nil; }
- (SecKeyRef) getPrivateKey             { return nil; }
- (SecCertificateRef) getCertificate    { return nil; }
- (SecIdentityRef) getIdentity          { return nil; }
#else
/* On a real iOS device */

static KDEConnectConfig * __sharedInstance = nil;

+ (KDEConnectConfig *)sharedInstance
{
    @synchronized(self) {
        if (__sharedInstance == nil) {
            __sharedInstance = [[self alloc] init];
        }
    }
    return __sharedInstance;
}

-(id)init {
    if (self = [super init]) {
        /* Load private key, certificate and identity when loading */
        [self loadUUID];
        [self loadPrivateKey];
        [self loadCertificate];
        [self loadIdentity];
    }
    return self;
}

- (void) loadUUID {
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc]
                                    initWithIdentifier: KEYCHAIN_ID accessGroup: KECHAIN_GROUP];
    uuid = [wrapper objectForKey: (id)@KEYSTORE_UUID];
    if (!uuid || [uuid length] < 1) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuid = [uuid stringByReplacingOccurrencesOfString:@"_" withString:@""];
        /* TODO: Fix bug in Keychain access */
        // [wrapper setObject: uuid forKey: (id)@KEYSTORE_UUID];
        NSLog(@"UUID Generated %@", uuid);
    }

    NSLog(@"UUID: %@", uuid);
}

- (void)loadPrivateKey {
    NSDictionary *copyArgs = @{
        (id)kSecClass:      (id)kSecClassKey,
        (id)kSecAttrLabel:  (id)@kPrivateKeyTag,
        (id)kSecReturnRef:  (id)kCFBooleanTrue
    };

    SecKeyRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) copyArgs, (CFTypeRef *) &result);

    if (status != errSecSuccess) {
        NSLog(@"Private not found, error: %d", (int)status);
        privateKeyRef = nil;

        /* Generate private key */
        [self generatePrivateKey];
    } else {
        privateKeyRef = result;
    }
}

- (void) loadCertificate
{
    NSDictionary *copyArgs = @{
        (id)kSecClass:      (id)kSecClassCertificate,
        (id)kSecAttrLabel:  (id)@kCertificateTag,
        (id)kSecReturnRef:  (id)kCFBooleanTrue
    };

    SecKeyRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) copyArgs, (CFTypeRef *) &result);

    if (status != errSecSuccess) {
        NSLog(@"Certificate not found, error: %d", (int)status);
        certificateRef = nil;

        /* Generate certificate */
        [self generateCertificate];
    } else {
        privateKeyRef = result;
    }
}

- (void) loadIdentity
{
    NSDictionary *copyArgs = @{
        (id)kSecClass:      (id)kSecClassIdentity,
        (id)kSecAttrLabel:  (id)@kIdentityTag,
        (id)kSecReturnRef:  (id)kCFBooleanTrue
    };

    SecIdentityRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) copyArgs, (CFTypeRef *) &result);

    if (status != errSecSuccess) {
        NSLog(@"Identity not found, error: %d", (int)status);
        identityRef = nil;
    } else {
        identityRef = result;
    }
}

- (void)generatePrivateKey {
    /* Generates a 2048-bit RSA key. */
    NSLog(@"Generating private key");

    /* Allocate memory for the EVP_PKEY structure. */
    EVP_PKEY * pkey = EVP_PKEY_new();
    if (!pkey) {
        NSLog(@"Unable to create EVP_PKEY structure.");
        return;
    }

    /* Allocate BIGNUM structure for exponent */
    BIGNUM *bne = BN_new();
    if (!bne) {
        NSLog(@"Unable to create BIGNUM structure.");
        EVP_PKEY_free(pkey);
        return;
    }

    /* Assign exponent value */
    if (BN_set_word(bne, RSA_F4) != 1) {
        NSLog(@"Unable to assign exponent value to BIGNUM.");
        BN_free(bne);
        EVP_PKEY_free(pkey);
        return;
    }

    /* Allocate RSA structure */
    RSA *rsa = RSA_new();
    if (!rsa) {
        NSLog(@"Unable to create RSA structure.");
        BN_free(bne);
        EVP_PKEY_free(pkey);
        return;
    }

    /* Generate the RSA key. */
    if (RSA_generate_key_ex(rsa, 2048, bne, NULL) != 1) {
        NSLog(@"Failed to generate 2048-bit RSA key.");
        RSA_free(rsa);
        BN_free(bne);
        EVP_PKEY_free(pkey);
        return;
    }

    /* Assign RSA key to pkey */
    if (EVP_PKEY_assign_RSA(pkey, rsa) != 1) {
        NSLog(@"Unable to assign RSA key to pkey.");
        RSA_free(rsa);
        BN_free(bne);
        EVP_PKEY_free(pkey);
        return;
    }

    /* Retrieve bytes */
    unsigned char *buffer = NULL;
    int len = i2d_PrivateKey(pkey, &buffer);
    
    if (len < 0) {
        NSLog(@"Unable to retrieve privat key.");
        return;
    }

    /* Prepare create with data */
    NSData *privateKeyData = [NSData dataWithBytes: buffer length: len];
    NSNumber *sizeInBits = [NSNumber numberWithInt: len * sizeof(unsigned char)];
    NSDictionary *attributes = @{
        (id)kSecAttrKeyClass:       (id)kSecAttrKeyClassPrivate,
        (id)kSecAttrKeyType:        (id)kSecAttrKeyTypeRSA,
        (id)kSecAttrKeySizeInBits:  (id)sizeInBits
    };
    
    NSLog(@"Unable to generate private key ref. %@", privateKeyData);

    CFErrorRef error;
    privateKeyRef = SecKeyCreateWithData((__bridge CFDataRef)privateKeyData, (__bridge CFDictionaryRef)attributes, &error);
    
    if (error != nil) {
        NSLog(@"Unable to generate private key ref.");
        return;
    }
    
    /* Store in the */
    NSLog(@"Private key ref: %@", privateKeyRef);
    NSDictionary* addquery = @{
        (id)kSecClass:      (id)kSecClassKey,
        (id)kSecAttrLabel:  (id)@kPrivateKeyTag,
        (id)kSecValueRef:   (__bridge id)privateKeyRef
    };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)addquery, NULL);
    if (status == errSecSuccess) {
        NSLog(@"Item added");
    } else {
        NSLog(@"Add private key failed %d", (int) status);
    }
    
    /* Clean up */
    
    /* The key has been generated, return it. */
}

- (void)generateCertificate {
    NSLog(@"Generating Certificate");
    
    X509 * x509 = X509_new();
    if (!x509) {
        NSLog(@"Unable to create X509 structure.");
        return;
    }
    
    X509_set_version(x509, 2);
    
    /* Set the serial number. */
    ASN1_INTEGER_set(X509_get_serialNumber(x509), 1);
    
    /* Set certificate valid time interval */
    X509_gmtime_adj(X509_get_notBefore(x509), -365 * 24 * 60 * 60);
    X509_gmtime_adj(X509_get_notAfter(x509), 10 * 365 * 24 * 60 * 60);
    
    /* Set the public key for our certificate. */
    //X509_set_pubkey(x509, pkey);
    
    /* We want to copy the subject name to the issuer name. */
    X509_NAME * name = X509_get_subject_name(x509);
    
    /* Set the country code and common name. */
    //X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char *)commonName,       -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O",  MBSTRING_ASC, (unsigned char *)"Soduto",            -1, -1, 0);
    
    /* Now set the issuer name. */
    X509_set_issuer_name(x509, name);
    
    /* Add usage extensions */
//    add_extension(x509, NID_key_usage, "critical,digitalSignature");
//    add_extension(x509, NID_ext_key_usage, "critical,serverAuth,clientAuth");
    
    /* Actually sign the certificate with our key. */
    /*if (!X509_sign(x509, pkey, EVP_sha256())) {
        NSLog(@"Error signing certificate.");
        X509_free(x509);
        return;
    }*/
}

- (SecKeyRef) getPrivateKey {
    return privateKeyRef;
}

- (SecCertificateRef) getCertificate {
    return certificateRef;
}

- (SecIdentityRef) getIdentity {
    return identityRef;
}

- (NSString *) getUUID {
    return uuid;
}

#endif
@end
