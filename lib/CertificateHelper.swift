//
//  CertificateHelper.swift
//  kdeconnect-ios
//
//  Created by Inoki on 28/04/2020.
//  Copyright © 2020 yangqiao. All rights reserved.
//

import Foundation
import Security
/*
func addIdentity(clientCertificate: Data, label: String) throws {
    log.info("Adding client certificate to keychain with label \(label)")

    guard let certificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, clientCertificate as CFData) else {
        log.error("Could not create certificate, data was not valid DER encoded X509 cert")
        throw KeychainError.invalidX509Data
    }

    // Add the client certificate to the keychain to create the identity
    let addArgs: [NSString: Any] = [
        kSecClass: kSecClassCertificate,
        kSecAttrAccessible: kSecAttrAccessibleAlwaysThisDeviceOnly,
        kSecAttrLabel: label,
        kSecValueRef: certificateRef,
        kSecReturnAttributes: true ]

    var resultRef: AnyObject?
    let addStatus = SecItemAdd(addArgs as CFDictionary, &resultRef)
    guard addStatus == errSecSuccess, let certAttrs = resultRef as? [NSString: Any] else {
        log.error("Failed to add certificate to keychain, error: \(addStatus)")
        throw KeychainError.cannotAddCertificateToKeychain(addStatus)
    }

    // Retrieve the client certificate issuer and serial number which will be used to retrieve the identity
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
}
*/
