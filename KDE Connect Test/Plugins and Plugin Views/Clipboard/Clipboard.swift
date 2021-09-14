//
//  Clipboard.swift
//  KDE Connect Test
//
//  Created by Lucas Wang on 2021-09-05.
//

import UIKit

@objc class Clipboard : NSObject, Plugin {
    @objc let controlDevice: Device
    
    @objc init (controlDevice: Device) {
        self.controlDevice = controlDevice
    }
    
    @objc func onDevicePackageReceived(np: NetworkPackage) -> Bool {
        if (np._Type == PACKAGE_TYPE_CLIPBOARD || np._Type == PACKAGE_TYPE_CLIPBOARD_CONNECT) {
            if (np.object(forKey: "content") != nil) {
                if (np._Type == PACKAGE_TYPE_CLIPBOARD) {
                    UIPasteboard.general.string = np.object(forKey: "content") as? String
                    connectedDevicesViewModel.lastLocalClipboardUpdateTimestamp = Int(Date().millisecondsSince1970)
                    print("Local clipboard synced with remote packet, timestamp updated")
                } else if (np._Type == PACKAGE_TYPE_CLIPBOARD_CONNECT) {
                    let packetTimeStamp: Int = np.integer(forKey: "timestamp")
                    if (packetTimeStamp == 0 || packetTimeStamp < connectedDevicesViewModel.lastLocalClipboardUpdateTimestamp) {
                        print("Invalid timestamp from \(PACKAGE_TYPE_CLIPBOARD_CONNECT), doing nothing")
                        return false;
                    } else {
                        UIPasteboard.general.string = np.object(forKey: "content") as? String
                        connectedDevicesViewModel.lastLocalClipboardUpdateTimestamp = Int(Date().millisecondsSince1970)
                        print("Local clipboard synced with remote packet, timestamp updated")
                    }
                }
            } else {
                print("Received nil for the content of the remote device's \(String(describing: np._Type)), doing nothing")
            }
            return true
        }
        return false
    }
    
    @objc func connectClipboardContent() -> Void {
        let clipboardConent: String? = UIPasteboard.general.string
        if (clipboardConent != nil) {
            let np: NetworkPackage = NetworkPackage(type: PACKAGE_TYPE_CLIPBOARD_CONNECT)
            np.setObject(clipboardConent, forKey: "content")
            np.setInteger(connectedDevicesViewModel.lastLocalClipboardUpdateTimestamp, forKey: "timestamp")
            controlDevice.send(np, tag: Int(PACKAGE_TAG_CLIPBOARD))
        } else {
            print("Attempt to connect local clipboard content with remote device returned nil")
        }
    }
    
    @objc func sendClipboardContentOut() -> Void {
        let clipboardConent: String? = UIPasteboard.general.string
        if (clipboardConent != nil) {
            let np: NetworkPackage = NetworkPackage(type: PACKAGE_TYPE_CLIPBOARD)
            np.setObject(clipboardConent, forKey: "content")
            controlDevice.send(np, tag: Int(PACKAGE_TAG_CLIPBOARD))
        } else {
            print("Attempt to grab and update local clipboard content returned nil")
        }
    }
}