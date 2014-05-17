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
    __strong NSDictionary* _rememberedDevices;
    __strong NSDictionary* _notPairedDevices;
}

@end


@implementation ViewController

@synthesize _tableView;

- (void)viewDidLoad
{
	[super viewDidLoad];
    _notPairedDevices=nil;
    _rememberedDevices=nil;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    _notPairedDevices=nil;
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

- (IBAction)pair:(id)sender {
    NSDictionary* list=[_bg getVisibleDevices];
    for (NSString* deviceId in [list allKeys]) {
        [_bg pairDevice:deviceId];
    }
}

- (IBAction)ping:(id)sender {
    
}

-(void) onPairRequest:(NSString*)deviceID
{
}

- (void) onPairTimeout:(NSString*)deviceID
{
}

- (void) onPairSuccess:(NSString*)deviceID
{
}

- (void) onPairRejected:(NSString*)deviceID
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NextViewController *nextController = [[NextViewController alloc] initWithNibName:@"NextView" bundle:nil];
//    [self.navigationController pushViewController:nextController <span id="IL_AD9" class="IL_AD">animated</span>:YES];
//    if(indexPath.section == 0)
//        [nextController changeProductText:[arryAppleProducts objectAtIndex:indexPath.row]];
//    else
//        [nextController changeProductText:[arryAdobeSoftwares objectAtIndex:indexPath.row]];
    NSArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            deviceIds=[_notPairedDevices allKeys];
            [_bg pairDevice:[deviceIds objectAtIndex:indexPath.row]];
        case 2:
            break;
        default:;
    }
}

@end
