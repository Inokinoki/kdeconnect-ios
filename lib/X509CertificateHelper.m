//
//  X509CertificateHelper.m
//  kdeconnect-ios
//
//  Created by Inoki on 29/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#include <openssl/x509.h>
#include <openssl/err.h>

void generateX509Certificate(const unsigned char *privateKey, unsigned long privateKeyLength){
    
    EVP_PKEY * pkey;
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

    X509_gmtime_adj(X509_get_notBefore(x509), 0);
    X509_gmtime_adj(X509_get_notAfter(x509), 31536000L);

    X509_set_pubkey(x509, pkey);

    X509_NAME * name;
    name = X509_get_subject_name(x509);

    X509_NAME_add_entry_by_txt(name, "C",  MBSTRING_ASC,
            (unsigned char *)"MyKDEConnectDevice", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O",  MBSTRING_ASC,
            (unsigned char *)"KDE", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "OU",  MBSTRING_ASC,
            (unsigned char *)"KDE CONNECT1", -1, -1, 0);

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
            (id)kSecAttrLabel:  @"kdeconnect_cert_222"
        };
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)addquery, NULL);
        if (status != errSecSuccess) {
            NSLog(@"Store not OK %d", status);
        } else {
            NSLog(@"Store OK");
        }
    }
}
