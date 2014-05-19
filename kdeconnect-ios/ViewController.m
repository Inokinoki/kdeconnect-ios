//
//  ViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "DeviceViewController.h"
#import "ViewController.h"
#import "MRProgress.h"

@interface ViewController ()
{
    NSString* _connectedDevice;
    NSString* _pairingDevice;
    NSString* _connectingDevice;
    __strong NSDictionary* _rememberedDevices;
    __strong NSDictionary* _notPairedDevices;
}

@end


@implementation ViewController

@synthesize _tableView;

- (void)viewDidLoad
{
	[super viewDidLoad];
    _connectedDevice=nil;
    _pairingDevice=nil;
    _notPairedDevices=nil;
    _rememberedDevices=nil;
    _connectingDevice=nil;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    [[BackgroundService sharedInstance] set_backgroundServiceDelegate:self];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    _notPairedDevices=nil;
    _rememberedDevices=nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

//FIX-ME these dialogs show very very slowly, with about 4-8 seconds' delay
-(void) onPairRequest:(NSString*)deviceID
{
    //TO-DO should we deal with incoming pair request?
    _pairingDevice=deviceID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]
          initWithTitle:@"Incoming Pair Request"
          message:FORMAT(@"Incoming pair request from device: %@ ",[_notPairedDevices valueForKey:deviceID])
          delegate:self
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@"Pair",nil] show];
    });
}

- (void) onPairTimeout:(NSString*)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRProgressOverlayView* progview=[MRProgressOverlayView overlayForView:self.view];
        [progview setTitleLabelText:@"Time out"];
        [progview setMode:MRProgressOverlayViewModeCross];
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [progview dismiss:YES];
        });
        _pairingDevice=nil;
    });
}

- (void) onPairSuccess:(NSString*)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRProgressOverlayView* progview=[MRProgressOverlayView overlayForView:self.view];
        [progview setTitleLabelText:@"Success"];
        [progview setMode:MRProgressOverlayViewModeCheckmark];
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [progview dismiss:YES];
        });
        _connectedDevice=deviceID;
        _pairingDevice=nil;
        [self onDeviceListRefreshed];
    });
    NSLog(@"viewcontroller onPairSuccess");

}

- (void) onPairRejected:(NSString*)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRProgressOverlayView* progview=[MRProgressOverlayView overlayForView:self.view];
        [progview setTitleLabelText:@"Rejected"];
        [progview setMode:MRProgressOverlayViewModeCross];
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [progview dismiss:YES];
        });
        _pairingDevice=nil;
    });
    NSLog(@"viewcontroller onPairRejected");
}

- (void) onDeviceListRefreshed
{
    NSLog(@"viewcontroller onDeviceListRefreshed");
    BackgroundService* bg=[BackgroundService sharedInstance] ;
    _notPairedDevices=[bg getNotPairedDevices];
    _rememberedDevices=[bg getPairedDevices];
    if (_connectedDevice==nil) {
        for (NSString* device in [_rememberedDevices allKeys]) {
            if ([bg isDeviceReachable:device]) {
                _connectedDevice=device;
            }
            else{
                _connectedDevice=nil;
            }
        }
    }
    else if (![bg isDeviceReachable:_connectedDevice]) {
        _connectedDevice=nil;
        DeviceViewController* vc=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]]
                                  instantiateViewControllerWithIdentifier:@"DeviceViewController"];
        [vc onDeviceLost];
    }
    if (_connectedDevice) {
        [bg loadPluginForDevice:_connectedDevice];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [_tableView reloadSectionIndexTitles];
    });
}

- (void) onRefresh:(id)sender
{
    NSLog(@"viewcontroller onRefresh");
    [[BackgroundService sharedInstance] refreshDiscovery];
    [self onDeviceListRefreshed];
    [sender endRefreshing];
}

#pragma mark -
#pragma mark Table View Data Source Methods

//return number of sections
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"viewcontroller nb of section");
    int count=[_rememberedDevices count];
    if (!count||(count==1 && _connectedDevice)) {
        return 2;
    }
    return 3;
}

//return row count
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"viewcontroller nb of rows");
    switch (section) {
        case 0:
            if (_connectedDevice) {
                return 1;
            }
            else return 0;
        
        case 1:
            return [_notPairedDevices count];
            
        case 2:
            if (_connectedDevice) {
                return [_rememberedDevices count]-1;
            }
            else return [_rememberedDevices count];
            
        default:
            return 0;
    }
}

//return section name
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"viewcontroller section name");
    switch (section) {
        case 0:
            return @"connected device";
        case 1:
            return @"not paired devices";
        case 2:
            return @"remembered devices";
        default:
            return @"";
    }
}

//redraw a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"viewcontroller load a cell");
    static NSString *mainListTableId = @"mainListTableId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             mainListTableId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:mainListTableId];
    }
    
    // Set up the cell...
    NSMutableArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text =[_rememberedDevices valueForKey:_connectedDevice];break;
        case 1:
            deviceIds=[NSMutableArray arrayWithArray:[_notPairedDevices allKeys]];
            cell.textLabel.text = [_notPairedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
        case 2:
            deviceIds=[NSMutableArray arrayWithArray:[_rememberedDevices allKeys]];
            [deviceIds removeObject:_connectedDevice];
            cell.textLabel.text = [_rememberedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
            
        default:;
    }
    return cell;
}

//selete a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"viewcontroller row selected");
    UIAlertView* alertDialog;
    DeviceViewController* vc;
    NSMutableArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            vc=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]]
                instantiateViewControllerWithIdentifier:@"DeviceViewController"];
            [vc set_deviceId:_connectedDevice];
            [vc setTitle:[_rememberedDevices valueForKey:_connectedDevice]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case 2:
            deviceIds=[NSMutableArray arrayWithArray:[_rememberedDevices allKeys]];
            [deviceIds removeObject:_connectedDevice];
            _connectingDevice=[deviceIds objectAtIndex:indexPath.row];
            alertDialog=[[UIAlertView alloc]
                         initWithTitle:@"Connect"
                         message:FORMAT(@"Connect to %@ ?",[_rememberedDevices valueForKey:_connectingDevice])
                         delegate:self
                         cancelButtonTitle:@"No"
                         otherButtonTitles:@"Yes", nil];
            [alertDialog show];
            break;
        case 1:
            if(!_pairingDevice){
                deviceIds=[NSMutableArray arrayWithArray:[_notPairedDevices allKeys]];
                _pairingDevice=[deviceIds objectAtIndex:indexPath.row];
                alertDialog=[[UIAlertView alloc]
                             initWithTitle:@"Pair Request"
                             message:FORMAT(@"pair device: %@ ?",[_notPairedDevices valueForKey:_pairingDevice])
                             delegate:self
                             cancelButtonTitle:@"No"
                             otherButtonTitles:@"Yes", nil];
            }
            else{
                //using a HUD, normally we will never be here
                alertDialog=[[UIAlertView alloc]
                             initWithTitle:@"Is Pairing"
                             message:FORMAT(@"Requesting to pair device: %@ ",[_notPairedDevices valueForKey:_pairingDevice])
                             delegate:nil
                             cancelButtonTitle:@"ok"
                             otherButtonTitles: nil];
            }
            [alertDialog show];
            break;
        default:;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//alertedialog
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView title] isEqualToString:@"Pair Request"]) {
        switch (buttonIndex) {
            case 0:
                _pairingDevice=nil;
                break;
            case 1:
                [[BackgroundService sharedInstance] pairDevice:_pairingDevice];
                [[MRProgressOverlayView showOverlayAddedTo:self.view animated:YES]
                 setTitleLabelText:@"Pairing"];
                break;
            default:
                break;
        }
    }
    else if ([[alertView title] isEqualToString:@"Success"]){
        //TO-DO redirect to device plugins interface
    }
    else if ([[alertView title] isEqualToString:@"Connect"]){
        switch (buttonIndex) {
            case 1:
                if (_connectingDevice) {
                    if ([[BackgroundService sharedInstance] isDeviceReachable:_connectingDevice]) {
                        _connectedDevice=_connectingDevice;
                        MRProgressOverlayView* progview=[MRProgressOverlayView showOverlayAddedTo:self.view animated:NO];
                        [progview setTitleLabelText:@"Success"];
                        [progview setMode:MRProgressOverlayViewModeCheckmark];
                        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
                        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
                            [progview dismiss:YES];
                        });
                        [self onDeviceListRefreshed];
                    }
                    else{
                        MRProgressOverlayView* progview=[MRProgressOverlayView showOverlayAddedTo:self.view animated:NO];
                        [progview setTitleLabelText:@"Not Reachable"];
                        [progview setMode:MRProgressOverlayViewModeCross];
                        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
                        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
                            [progview dismiss:YES];
                        });
                    }
                }
                break;
            default:
                break;
        }
        _connectingDevice=nil;
    }
    else if([[alertView title] isEqualToString:@"Incoming Pair Request"]){
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [[BackgroundService sharedInstance] pairDevice:_pairingDevice];
                [MRProgressOverlayView showOverlayAddedTo:self.view animated:NO];
                break;
        }
        _pairingDevice=nil;
    }
}
@end
