//
//  X509CertificateHelper.m
//  kdeconnect-ios
//
//  Created by Inoki on 29/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>

#include <openssl/x509.h>
#include <openssl/err.h>

#include "X509CertificateHelper.h"

@implementation X509CertificateHelper

- (void) deleteX509Certificate {
    OSStatus sanityCheck = noErr;
    
    NSDictionary * queryCert = @{
        (id)kSecClass:      (id)kSecClassCertificate,
        (id)kSecAttrLabel:  @CERT_TAG
    };
    
    // Delete the cert.
    sanityCheck = SecItemDelete((CFDictionaryRef)queryCert);
    
    if (sanityCheck != noErr && sanityCheck != errSecItemNotFound) {
        NSLog(@"Error removing certificate, OSStatus == %d.", sanityCheck );
    }
}

- (void) generateX509Certificate: (const unsigned char *)privateKey length: (unsigned long) privateKeyLength {
    [self deleteX509Certificate];
    
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

    X509 * x509;
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
        
        CFRelease(cert);
    }
}

@end

