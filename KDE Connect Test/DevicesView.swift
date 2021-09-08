//
//  DevicesView.swift
//  KDE Connect Test
//
//  Created by Lucas Wang on 2021-06-17.
//

import SwiftUI
import AVFoundation

struct DevicesView: View {
    @State private var connectedDevicesIds: [String] = []
    @State private var visibleDevicesIds: [String] = []
    @State private var savedDevicesIds: [String] = []
    
    @State var currPairingDeviceId: String?
    @State private var showingOnPairRequestAlert: Bool = false
    @State private var showingOnPairTimeoutAlert: Bool = false
    @State private var showingOnPairSuccessAlert: Bool = false
    @State private var showingOnPairRejectedAlert: Bool = false
    @State private var showingOnSelfPairOutgoingRequestAlert: Bool = false
    @State private var showingOnSelectSavedDeviceAlert: Bool = false
    @State private var showingPingAlert: Bool = false
    @State private var showingFindMyPhoneAlert: Bool = false
    @State private var showingFileReceivedAlert: Bool = false
    
    @State private var showingConfigureDevicesByIPView: Bool = false
    
    @ObservedObject var localNotificationService = LocalNotificationService()
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Connected Devices")) {
                    if (connectedDevicesIds.isEmpty) {
                        Text("No devices currently connected.\nConnected devices will appear here.")
                    } else {
                        ForEach(connectedDevicesIds, id: \.self) { key in
                            NavigationLink(
                                // TODO: How do we know what to pass to the details view?
                                // Use the "key" from ForEach aka device ID to get it from
                                // backgroundService's _devices dictionary for the value (Device class objects)
                                destination: DevicesDetailView(detailsDeviceId: key),
                                label: {
                                    HStack {
                                        Image(systemName: "wifi")
                                            .foregroundColor(.green)
                                            .font(.system(size: 21))
                                        VStack(alignment: .leading) {
                                            Text(connectedDevicesViewModel.connectedDevices[key] ?? "???")
                                                .font(.system(size: 18, weight: .bold))
                                            // TODO: Might want to add the device description as
                                            // id:desc dictionary?
                                            //Text(key)
                                        }
                                    }
                                })
                        }
                    }
                }
                
                Section(header: Text("Discoverable Devices")) {
                    if (visibleDevicesIds.isEmpty) {
                        Text("No devices discoverable on this network.\nMake sure to Refresh Discovery and check that the other devices are also running KDE Connect & are connected to the same network as this device.")
                    } else {
                        ForEach(visibleDevicesIds, id: \.self) { key in
                            Button(action: {
                                currPairingDeviceId = key
                                showingOnSelfPairOutgoingRequestAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "badge.plus.radiowaves.right")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 21))
                                    VStack(alignment: .leading) {
                                        Text(connectedDevicesViewModel.visibleDevices[key] ?? "???")
                                            .font(.system(size: 18, weight: .bold))
                                        Text("Tap to start pairing")
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
                Section(header: Text("Remembered Devices")) {
                    if (savedDevicesIds.isEmpty) {
                        Text("No remembered devices.\nDevices that were previously connected will appear here.")
                    } else {
                        ForEach(savedDevicesIds, id: \.self) { key in
                            Button(action: {
                                currPairingDeviceId = key
                                showingOnSelectSavedDeviceAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(.red)
                                        .font(.system(size: 21))
                                    VStack(alignment: .leading) {
                                        Text(connectedDevicesViewModel.savedDevices[key] ?? "???")
                                            .font(.system(size: 18, weight: .bold))
                                        // TODO: Might want to add the device description as
                                        // id:desc dictionary?
                                        //Text(key)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteDevice)
                    }
                }
            }
            .alert(isPresented: $showingOnPairRequestAlert) { // TODO: Might want to add a "pairing in progress" UI element?
                Alert(title: Text("Incoming Pairing Request"),
                      message: Text("\(connectedDevicesViewModel.visibleDevices[currPairingDeviceId!] ?? "ERROR") wants to pair with this device"),
                      primaryButton: .cancel(Text("Do Not Pair")),
                      secondaryButton: .default(
                        Text("Pair")
                            .foregroundColor(.green)
                      ) {
                        backgroundService.pairDevice(currPairingDeviceId)
                        //currPairingDeviceId = nil
                      }
                )
            }
            
            NavigationLink(destination: ConfigureDeviceByIPView(), isActive: $showingConfigureDevicesByIPView) {
                EmptyView()
            }
            
            Text("")
                .alert(isPresented: $showingOnPairTimeoutAlert) {
                    Alert(title: Text("Pairing Timed Out"),
                          message: Text("Pairing with \((backgroundService._devices[currPairingDeviceId!] as! Device)._name) failed"),
                          dismissButton: .default(Text("OK"), action: {
                            currPairingDeviceId = nil
                          })
                    )
                }
            
            Text("")
                .alert(isPresented: $showingOnPairSuccessAlert) {
                    Alert(title: Text("Pairing Complete"),
                          message: Text("Pairing with \((backgroundService._devices[currPairingDeviceId!] as! Device)._name) succeeded"),
                          dismissButton: .default(Text("Nice"), action: {
                            currPairingDeviceId = nil
                          })
                    )
                }
            
            Text("")
                .alert(isPresented: $showingOnPairRejectedAlert) {
                    Alert(title: Text("Pairing Rejected"),
                          message: Text("Pairing with \((backgroundService._devices[currPairingDeviceId!] as! Device)._name) failed"),
                          dismissButton: .default(Text("OK"), action: {
                            currPairingDeviceId = nil
                          })
                    )
                }
            
            Text("")
                .alert(isPresented: $showingOnSelfPairOutgoingRequestAlert) {
                    Alert(title: Text("Initiate Pairing?"),
                          message: Text("Request to pair with \(connectedDevicesViewModel.visibleDevices[currPairingDeviceId!] ?? "ERROR")?"),
                          primaryButton: .cancel(Text("Do Not Pair")),
                          secondaryButton: .default(
                            Text("Pair")
                                .foregroundColor(.green)
                          ) {
                            backgroundService.pairDevice(currPairingDeviceId)
                            //currPairingDeviceId = nil
                          }
                    )
                }
            
            Text("")
                .alert(isPresented: $showingOnSelectSavedDeviceAlert) {
                    Alert(title: Text("Device Offline"),
                          message: Text("The paired device \(currPairingDeviceId!) is not reachable. Make sure it is connected to the same network as this device."),
                          dismissButton: .default(Text("OK"), action: {
                            currPairingDeviceId = nil
                          })
                    )
                }
            
            Text("")
                .alert(isPresented: $showingPingAlert) {
                    Alert(title: Text("Ping!"),
                          message: Text("Ping received from a connected device."),
                          dismissButton: .default(Text("OK"), action: {
                            
                          })
                    )
                }
            
            Text("")
                .alert(isPresented: $showingFindMyPhoneAlert) {
                    Alert(title: Text("Find My Phone Mode"),
                          message: Text("Find My Phone initiated from a remote device"),
                          dismissButton: .default(Text("I FOUND IT!"), action: {
                            
                          })
                    )
                }
            
//            Text("")
//                .alert(isPresented: $showingFileReceivedAlert) {
//                    Alert(title: Text("File Recevied"),
//                          message: Text("Received a file"),
//                          dismissButton: .default(Text("OK"), action: {
//
//                          })
//                    )
//                }
            
        }
        .navigationTitle("Devices")
        .navigationBarItems(trailing: {
            Menu {
                Button(action: {
                    refreshDiscoveryAndList()
                }, label: {
                    HStack {
                        Text("Refresh Discovery")
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                })
                Button(action: {
                    showingConfigureDevicesByIPView = true
                }, label: {
                    HStack {
                        Text("Configure Devices By IP")
                        Image(systemName: "network")
                    }
                })
                //TODO: how exactly does this work again? Possibly need more entitlements for accessing the wifi information
//                Button(action: {
//                    // take to Trusted Networks View
//                }, label: {
//                    HStack {
//                        Text("Configure Trusted Networks")
//                        Image(systemName: "lock.shield")
//                    }
//                })
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }())
        .onAppear() { // MARK: This get called twice on startup?????
            if (connectedDevicesViewModel.devicesView == nil) {
                connectedDevicesViewModel.devicesView = self
            }
            if (backgroundService._backgroundServiceDelegate == nil) {
                backgroundService._backgroundServiceDelegate = connectedDevicesViewModel
            }
            // MARK: If refreshDiscoveryAndList() is here, the device will go into "Remembered" for some reason and then immediately go back, but with an empty _plugins dictionary
            //refreshDiscoveryAndList()
            connectedDevicesViewModel.onDeviceListRefreshed()
            broadcastBatteryStatusAllDevices()
        }
    }
    
    func deleteDevice(at offsets: IndexSet) {
        if (offsets.first != nil) {
            print("Remembered device \(String(describing: ((backgroundService._devices[savedDevicesIds[offsets.first!]]) as! Device)._name)) removed at index \(offsets.first!)")
            backgroundService.unpairDevice(savedDevicesIds[offsets.first!])
            savedDevicesIds.remove(atOffsets: offsets)
        }
    }

    func onPairRequestInsideView(_ deviceId: String!) -> Void {
        currPairingDeviceId = deviceId
//        self.localNotificationService.sendNotification(title: "Incoming Pairing Request", subtitle: nil, body: "\(connectedDevicesViewModel.visibleDevices[currPairingDeviceId!] ?? "ERROR") wants to pair with this device", launchIn: 2)
        if (noCurrentlyActiveAlert()) {
            showingOnPairRequestAlert = true
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display onPairRequest Alert, another alert already active")
        }
    }
    
    func onPairTimeoutInsideView(_ deviceId: String!) -> Void {
        //currPairingDeviceId = nil
        if(noCurrentlyActiveAlert()) {
            showingOnPairTimeoutAlert = true
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display onPairTimeout Alert, another alert already active")
        }
    }
    
    func onPairSuccessInsideView(_ deviceId: String!) -> Void {
        if (noCurrentlyActiveAlert()) {
            showingOnPairSuccessAlert = true
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display onPairSuccess Alert, another alert already active, but device list is still refreshed")
        }
        connectedDevicesViewModel.onDeviceListRefreshed()
    }
    
    func onPairRejectedInsideView(_ deviceId: String!) -> Void {
        if (noCurrentlyActiveAlert()) {
            showingOnPairRejectedAlert = true
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display onPairRejected Alert, another alert already active")
        }
    }
    
    func showPingAlertInsideView() -> Void {
        haptics.impactOccurred(intensity: 0.8)
        AudioServicesPlaySystemSound(soundSMSReceived)
        if (noCurrentlyActiveAlert()) {
            showingPingAlert = true
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display showingPingAlert Alert, another alert already active, but haptics and sounds are still played")
        }
    }
    
    func showFindMyPhoneAlertInsideView() -> Void {
        if (noCurrentlyActiveAlert()) {
            showingFindMyPhoneAlert = true
            while (showingFindMyPhoneAlert) {
                haptics.impactOccurred(intensity: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    AudioServicesPlaySystemSound(soundCalendarAlert)
                }
            }
        } else {
            AudioServicesPlaySystemSound(soundAudioToneBusy)
            print("Unable to display showFindMyPhoneAlert Alert, another alert already active, alert haptics and tone not played")
        }
    }
    
    func showFileReceivedAlertInsideView() -> Void {
//        if (noCurrentlyActiveAlert()) {
//            showingFileReceivedAlert = true
//        } else {
//            AudioServicesPlaySystemSound(soundAudioToneBusy)
//            print("Unable to display File Received Alert, another alert already active")
//        }
        AudioServicesPlaySystemSound(soundMailReceived)
    }
    
    private func noCurrentlyActiveAlert() -> Bool {
        return (!showingOnPairRequestAlert &&
                !showingOnPairTimeoutAlert &&
                !showingOnPairSuccessAlert &&
                !showingOnPairRejectedAlert &&
                !showingOnSelfPairOutgoingRequestAlert &&
                !showingOnSelectSavedDeviceAlert &&
                !showingPingAlert &&
                !showingFindMyPhoneAlert) //&& !showingFileReceivedAlert
    }
    
    func onDeviceListRefreshedInsideView(vm : ConnectedDevicesViewModel) -> Void {
        connectedDevicesIds = Array(vm.connectedDevices.keys)//.sort
        visibleDevicesIds = Array(vm.visibleDevices.keys)//.sort
        savedDevicesIds = Array(vm.savedDevices.keys)//.sort
    }
    
    func refreshDiscoveryAndList() -> Void {
        let group = DispatchGroup()
        group.enter()
        backgroundService.refreshDiscovery()
        group.leave()
        group.notify(queue: DispatchQueue.main) {
            backgroundService.refreshVisibleDeviceList()
            broadcastBatteryStatusAllDevices()
        }
    }
    
}

//struct DevicesView_Previews: PreviewProvider {
//    static var previews: some View {
//        DevicesView()
//    }
//}
