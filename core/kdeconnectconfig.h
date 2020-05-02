//
//  kdeconnectconfig.h
//  kdeconnect-ios
//
//  Created by Inoki on 02/05/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

#ifndef kdeconnectconfig_h
#define kdeconnectconfig_h

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "common.h"

#define kPrivateKeyTag      "org.kde.kdeconnect.privatekey"
#define kCertificateTag     "org.kde.kdeconnect.certificate"
#define kIdentityTag        "org.kde.kdeconnect.certificate"

@interface KDEConnectConfig : NSObject {
    SecKeyRef privateKeyRef;
    SecIdentityRef identityRef;
    SecCertificateRef certificateRef;
    NSString *uuid;
}

@property (nonatomic, retain) NSData * publicTag;
@property (nonatomic, retain) NSData * privateTag;

+ (KDEConnectConfig *) sharedInstance;
- (SecKeyRef) getPrivateKey;
- (SecCertificateRef) getCertificate;
- (SecIdentityRef) getIdentity;
- (NSString *) getUUID;

@end

#endif /* kdeconnectconfig_h */
