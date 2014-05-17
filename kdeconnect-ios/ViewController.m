//
//  ViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
{
    BackgroundService* _bg;
    NSString* _connectedDevice;
    NSString* _pairingDevice;
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
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    _notPairedDevices=nil;
    _rememberedDevices=nil;
}

- (void) viewDidAppear:(BOOL)animated
{
}

- (IBAction)start_discovery:(id)sender
{
    if(_bg==nil) _bg=[BackgroundService sharedInstance];
    [_bg set_backgroundServiceDelegate:self];
    [_bg startDiscovery];
}

- (IBAction)stop_discovery:(id)sender
{
    if (_bg) {
        [_bg stopDiscovery];
    }
}

-(void) onPairRequest:(NSString*)deviceID
{
    //TODO should we deal with incoming pair request?
    UIAlertView* alertDialog;
    alertDialog=[[UIAlertView alloc]
                 initWithTitle:@"Request"
                 message:FORMAT(@"Pair request from device: %@",[_notPairedDevices valueForKey:deviceID])
                 delegate:nil
                 cancelButtonTitle:@"ok"
                 otherButtonTitles: nil];
    [alertDialog setAlertViewStyle:UIAlertViewStyleDefault];
    [alertDialog show];

}

- (void) onPairTimeout:(NSString*)deviceID
{
    UIAlertView* alertDialog;
    alertDialog=[[UIAlertView alloc]
                 initWithTitle:@"Timeout"
                 message:FORMAT(@"pair device: %@ timeout",[_notPairedDevices valueForKey:deviceID])
                 delegate:nil
                 cancelButtonTitle:@"ok"
                 otherButtonTitles: nil];
    [alertDialog setAlertViewStyle:UIAlertViewStyleDefault];
    [alertDialog show];
    _pairingDevice=nil;

}

- (void) onPairSuccess:(NSString*)deviceID
{
    UIAlertView* alertDialog;
    alertDialog=[[UIAlertView alloc]
                 initWithTitle:@"Success"
                 message:FORMAT(@"pair device: %@ success",[_notPairedDevices valueForKey:deviceID])
                 delegate:self
                 cancelButtonTitle:@"ok"
                 otherButtonTitles: nil];
    [alertDialog setAlertViewStyle:UIAlertViewStyleDefault];
    [alertDialog show];
    _connectedDevice=deviceID;
    _pairingDevice=nil;
}

- (void) onPairRejected:(NSString*)deviceID
{
    UIAlertView* alertDialog;
    alertDialog=[[UIAlertView alloc]
                 initWithTitle:@"Rejected"
                 message:FORMAT(@"pair device: %@ rejected",[_notPairedDevices valueForKey:deviceID])
                 delegate:nil
                 cancelButtonTitle:@"ok"
                 otherButtonTitles: nil];
    [alertDialog setAlertViewStyle:UIAlertViewStyleDefault];
    [alertDialog show];
    _pairingDevice=nil;
}

- (void) onDeviceListRefreshed
{
    _notPairedDevices=[_bg getVisibleDevices];
    [_tableView reloadData];
    [_tableView reloadSectionIndexTitles];
}

#pragma mark -
#pragma mark Table View Data Source Methods

//return number of sections
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_rememberedDevices count]==0) {
        return 2;
    }
    return 3;
}

//return row count
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (_connectedDevice) {
                return 1;
            }
            else return 0;
        
        case 1:
            return [_notPairedDevices count];
            
        case 2:
            return [_rememberedDevices count];
            
        default:
            return 0;
    }
}

//return section name
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
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
    
    static NSString *mainListTableId = @"mainListTableId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             mainListTableId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:mainListTableId];
    }
    
    // Set up the cell...
    NSArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text =[_rememberedDevices valueForKey:_connectedDevice];break;
        case 1:
            deviceIds=[_notPairedDevices allKeys];
            cell.textLabel.text = [_notPairedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
        case 2:
            deviceIds=[_rememberedDevices allKeys];
            cell.textLabel.text = [_rememberedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
            
        default:;
    }
    return cell;
}

//selete a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NextViewController *nextController = [[NextViewController alloc] initWithNibName:@"NextView" bundle:nil];
//    [self.navigationController pushViewController:nextController animated:YES];
//    if(indexPath.section == 0)
//        [nextController changeProductText:[arryAppleProducts objectAtIndex:indexPath.row]];
//    else
//        [nextController changeProductText:[arryAdobeSoftwares objectAtIndex:indexPath.row]];
    UIAlertView* alertDialog;
    NSArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            if(!_pairingDevice){
                deviceIds=[_notPairedDevices allKeys];
                _pairingDevice=[deviceIds objectAtIndex:indexPath.row];
                alertDialog=[[UIAlertView alloc]
                             initWithTitle:@"Pairing"
                             message:FORMAT(@"pair device: %@ ?",[_notPairedDevices valueForKey:_pairingDevice])
                             delegate:self
                             cancelButtonTitle:@"No"
                             otherButtonTitles:@"Yes", nil];
            }
            else{
                alertDialog=[[UIAlertView alloc]
                             initWithTitle:@"Pairing"
                             message:FORMAT(@"Requesting to pair device: %@ ",[_notPairedDevices valueForKey:_pairingDevice])
                             delegate:nil
                             cancelButtonTitle:@"ok"
                             otherButtonTitles: nil];
            }
            break;

        case 2:
            break;
        default:;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [alertDialog setAlertViewStyle:UIAlertViewStyleDefault];
    [alertDialog show];
}

//alertedialog
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView title] isEqualToString:@"Pairing"]) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [_bg pairDevice:_pairingDevice];
                break;
            default:
                break;
        }
    }
    else if ([[alertView title] isEqualToString:@"Success"]){
        //TODO redirect to device plugins interface
    }
        
}
@end
