//
//  X509CertificateHelper.h
//  kdeconnect-ios
//
//  Created by Inoki on 29/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#ifndef X509CertificateHelper_h
#define X509CertificateHelper_h

#define CERT_TAG    "kdeconnect_cert"

@interface X509CertificateHelper : NSObject

- (void) generateX509Certificate: (const unsigned char *)privateKey length: (unsigned long) privateKeyLength;
- (void) deleteX509Certificate;

@end

#endif /* X509CertificateHelper_h */
