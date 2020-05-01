//
//  GenerateCertificate.m
//  kdeconnect-ios
//
//  Created by Inoki on 20/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
(NSData *) signCSR:(NSData *)derCSR forDays:(double)days NIDstToKeep:(NSSet *)nidsToAllow
{
    const unsigned char * ptr;
    NSUInteger len;

    // Gather the details for the CA cert (my cert) from
    // OSX.
    //
    X509 * x509_mycert = NULL;
    SecIdentityRef identityRef = [self secIdentityRef];
    if (!identityRef)
        return nil;

    SecCertificateRef certificateRef = [self secCertificateRef];
    if (!certificateRef)
        return nil;

    CFDataRef certAsDer = SecCertificateCopyData(certificateRef);
    if (!certAsDer)
        return nil;

    // Jump over the fence to OpenSSL  - and create
    // an X509 version.
    //
    ptr = CFDataGetBytePtr(certAsDer);
    len = CFDataGetLength(certAsDer);

    if (!(d2i_X509(&x509_mycert, &ptr, len)))
        return nil;

    // And likewise for the CSR.
    //
    ptr = (const unsigned char *)[derCSR bytes];
    len = [derCSR length];

    X509_REQ *req = NULL;
    if (!(d2i_X509_REQ(&req, &ptr, len)))
        return nil;

    // Copy the CSR into a an actual x509 tenative
    // structure; i.e. the cert we'll issue signed.
    //
    X509 * x509_to_sign = X509_new();

    assert(X509_set_subject_name(x509_to_sign,req->req_info->subject));
    assert(X509_set_issuer_name(x509_to_sign, X509_get_subject_name(x509_mycert)));

    EVP_PKEY * pubkey_csr = X509_REQ_get_pubkey(req);
    X509_set_pubkey(x509_to_sign,pubkey_csr);
    EVP_PKEY_free(pubkey_csr);

    X509_gmtime_adj(X509_get_notBefore(x509_to_sign),0L);
    X509_gmtime_adj(X509_get_notAfter(x509_to_sign),(long)floor(60*60*24*days));

    if (nidsToAllow && [nidsToAllow count]) {
        // Faily blindly copy all known extensions.
        //
        for(int i = X509_get_ext_count(x509_to_sign); i > 0; i--) {
            X509_EXTENSION * ext = X509_get_ext(x509_to_sign,i-i);
            int nid = OBJ_obj2nid(ext->object);
            if ([nidsToAllow containsObject:[NSNumber numberWithInt:nid]]) {
                // NSLog(@"Keeping %s at %d", OBJ_nid2sn(nid),i-i);
                continue;
            }
            // NSLog(@"Killing %s at %d", OBJ_nid2sn(nid),i-1);
            X509_delete_ext(x509_to_sign, i-i);
        }
    } else {
        // wipe them all.
        //
        while (X509_get_ext_count(x509_to_sign) > 0) {
            X509_delete_ext(x509_to_sign, 0);
        }
    };

    // Set a random serial.
    //
    ASN1_INTEGER *bs = ASN1_INTEGER_new();
    long rnd = 0;
    if (!(RAND_bytes((unsigned char *)&rnd, sizeof(rnd))))
        return nil;

    rnd = labs(rnd);
    ASN1_INTEGER_set(bs, rnd);

    if (!((X509_set_serialNumber(x509_to_sign,bs))))
        return nil;

    ASN1_INTEGER_free(bs);

    // Force v3
    //
    X509V3_CTX ctx2;
    X509_set_version(x509_to_sign,2); /* version 3 certificate */
    /*X509V3_set_ctx(&ctx2, x509_mycert, x509_to_sign, NULL, NULL, 0);

    // Pull in additional x509v3 sections.
    //
    if (DBA) {
       assert(X509V3_set_nconf(&ctx2, conf));
       assert(X509V3_EXT_add_nconf(conf, &ctx2, section, x509_to_sign));
    }
    // Specify signature type.
    //
    x509_to_sign->cert_info->signature->algorithm = OBJ_nid2obj(NID_sha1WithRSAEncryption);

    // Construct the ASN.1 blob which contains all the information
    // we are going to sign.
    //
    const ASN1_ITEM * it = ASN1_ITEM_rptr(X509_CINF);
    unsigned char *buf_in=NULL;
    ASN1_VALUE * asn = (ASN1_VALUE *)(x509_to_sign->cert_info);
    int inl = ASN1_item_i2d(asn,&buf_in, it);

    // Small area to hold the signature on the SHA1 hash.
    //
    size_t sigLen = SecKeyGetBlockSize(privateKey);
    uint8_t * sig = (uint8_t *)malloc(sigLen * sizeof(uint8_t));
    memset((void*)sig, 0, sigLen);

#if TARGET_OS_IPHONE
    // IPhone Way of doing it - where we need to construct the
    // SHA1 of the 'to sign' area ourselves. As SecKeyRawSign
    // does not seem to handly anything beyond a SHA1.
    //
    NSData * buffToSign = [NSData dataWithBytes:buf_in length:inl];
    NSData * buffSha1ToSign = [buffToSign sha1];

    size_t sigLenUsed = sigLen;

    OSStatus status = SecKeyRawSign(privateKey, kSecPaddingPKCS1SHA1, [buffSha1ToSign bytes], [buffSha1ToSign length], sig, &sigLenUsed);
    assert(status == noErr);
    assert(sigLenUsed == sigLen);

#else
    // MacOSX offical way of doing this - which seems to do the SHA1 fun,
    // padding and games deeper down; and where we simply pass the blob.
    //
    CFErrorRef error = NULL;
    SecTransformRef signer = SecSignTransformCreate(privateKey, &error);
    if (error) { CFShow(error); assert(0); };

    NSData * blockToSign = [NSData dataWithBytes:buf_in length:inl];
    SecTransformSetAttribute(signer, kSecTransformInputAttributeName,
                             (__bridge CFTypeRef) blockToSign, &error);
    if (error) { CFShow(error); assert(0); };

    CFDataRef signature = SecTransformExecute(signer, &error);
    if (error) { CFShow(error); assert(0); };

    assert(sigLen == CFDataGetLength(signature));
    bcopy(CFDataGetBytePtr(signature), sig, sigLen);
#endif

    // Wrap up the rest of the block with the bits and bobs needed to
    // create a valid ASN1 block to share as a PEM or DER. Which most
    // crucially is about copying the just created signature into it.
    //
    x509_to_sign->sig_alg->algorithm = OBJ_nid2obj(NID_sha1WithRSAEncryption);
    x509_to_sign->signature->data = sig;
    x509_to_sign->signature->length = sigLen;
    x509_to_sign->signature->flags&= ~(ASN1_STRING_FLAG_BITS_LEFT|0x07);
    x509_to_sign->signature->flags|=ASN1_STRING_FLAG_BITS_LEFT;

    unsigned char * derbuff = NULL;
    int derlen = i2d_X509(x509_to_sign, &derbuff);

    NSData * signedDer = [NSData dataWithBytes:derbuff length:derlen];

    free(sig);
    OPENSSL_free(x509_to_sign);
    OPENSSL_free(x509_mycert);

    return signedDer;
}
*/
