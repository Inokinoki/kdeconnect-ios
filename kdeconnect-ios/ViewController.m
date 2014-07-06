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
@property(nonatomic)NSString* _pairingDevice;
@property(nonatomic)NSDictionary* _connectedDevices;
@property(nonatomic)NSDictionary* _rememberedDevices;
@property(nonatomic)NSDictionary* _visibleDevices;
@property(nonatomic,weak)NSString* _moreActionDevice;
@end

@implementation ViewController

@synthesize _tableView;
@synthesize _visibleDevices;
@synthesize _connectedDevices;
@synthesize _pairingDevice;
@synthesize _rememberedDevices;
@synthesize _moreActionDevice;

- (void)viewDidLoad
{
	[super viewDidLoad];
    _connectedDevices=nil;
    _pairingDevice=nil;
    _rememberedDevices=nil;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    [[BackgroundService sharedInstance] set_backgroundServiceDelegate:self];
    [self onDeviceListRefreshed];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void) onPairRequest:(NSString*)deviceID
{
    _pairingDevice=deviceID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]
          initWithTitle:@"Incoming Pair Request"
          message:FORMAT(@"Incoming pair request from device: %@ ",[_visibleDevices valueForKey:deviceID])
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
    NSDictionary* list=[bg getDevicesLists];
    _rememberedDevices  =[list valueForKey:@"remembered"];
    _connectedDevices   =[list valueForKey:@"connected"];
    _visibleDevices     =[list valueForKey:@"visible"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [_tableView reloadSectionIndexTitles];
    });
}

- (void) onRefresh:(id)sender
{
    NSLog(@"viewcontroller onRefresh");
    [[BackgroundService sharedInstance] refreshDiscovery];
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
        [self onDeviceListRefreshed];
        [sender endRefreshing];
    });
}

- (void) actionOnDevice:(id)sender
{
    UIView* view=sender;
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view=[view superview];
    }
    UITableViewCell* cell=(id)view;
    NSIndexPath* indexpath=[_tableView indexPathForCell:cell];
    switch (indexpath.section) {
        case 0:
            _moreActionDevice=[[_connectedDevices allKeys] objectAtIndex:indexpath.row];break;
        case 1:
            return;
        case 2:
            _moreActionDevice=[[_rememberedDevices allKeys] objectAtIndex:indexpath.row];break;
        default:
            break;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"More Actions"
                                                            delegate:self
                                                   cancelButtonTitle:@"back"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Unpair",nil];
    actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
#pragma mark -
#pragma mark Table View Data Source Methods

//return number of sections
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"viewcontroller nb of section");
    NSUInteger count=[_rememberedDevices count];
    if (!count) {
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
            return [_connectedDevices count];
        case 1:
            return [_visibleDevices count];
        case 2:
            return [_rememberedDevices count];
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
            return @"visible devices";
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainListTableId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:mainListTableId];
    }

    // Set up the cell...
    NSArray* deviceIds;
    switch (indexPath.section) {
        case 0:
            deviceIds=[_connectedDevices allKeys];
            cell.textLabel.text =[_connectedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
        case 1:
            deviceIds=[_visibleDevices allKeys];
            cell.textLabel.text =[_visibleDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
        case 2:
            deviceIds=[_rememberedDevices allKeys];
            cell.textLabel.text =[_rememberedDevices valueForKey:[deviceIds objectAtIndex:indexPath.row]];break;
        default:;
    }
    if (indexPath.section==1){
        cell.accessoryView=nil;
    }
    else{
        //accessory button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
        //set the position of the button
        int height=cell.frame.size.height;
        button.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y , height, height);
        [button addTarget:self action:@selector(actionOnDevice:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor= [UIColor clearColor];
        cell.accessoryView=button;
    }
    return cell;
}

//selete a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"viewcontroller row selected");
    UIAlertView* alertDialog;
    DeviceViewController* vc;
    NSString* deviceId;
    switch (indexPath.section) {
        case 0:
            //TO-DO use compile macro to load storyboard for iphone or ipad
            vc=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]]
                instantiateViewControllerWithIdentifier:@"DeviceViewController"];
            deviceId=[[_connectedDevices allKeys]objectAtIndex:indexPath.row];
            [vc set_deviceId:deviceId];
            [vc setTitle:[_connectedDevices valueForKey:deviceId]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case 1:
            _pairingDevice=[[_visibleDevices allKeys]objectAtIndex:indexPath.row];
            alertDialog=[[UIAlertView alloc]
                         initWithTitle:@"Pair Request"
                         message:FORMAT(@"pair device: %@ ?",[_visibleDevices valueForKey:_pairingDevice])
                         delegate:self
                         cancelButtonTitle:@"No"
                         otherButtonTitles:@"Yes", nil];
            [alertDialog show];
            break;
        case 2:
            //TO-DO use compile macro to load storyboard for iphone or ipad
            /*
            vc=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]]
                instantiateViewControllerWithIdentifier:@"DeviceViewController"];
            deviceId=[[_connectedDevices allKeys]objectAtIndex:indexPath.row];
            [vc set_deviceId:deviceId];
            [vc setTitle:[_connectedDevices valueForKey:deviceId]];
            [self.navigationController pushViewController:vc animated:YES];
            break;
             */
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

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[BackgroundService sharedInstance] reloadAllPlugins];
}

#pragma mark -UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet title] isEqualToString:@"More Actions"]) {
        switch (buttonIndex) {
            case 0:
                [[BackgroundService sharedInstance] unpairDevice:_moreActionDevice];
                break;
            case 1:
            default:
                break;
        }
    }
    _moreActionDevice=nil;
    [self onRefresh:nil];
}
@end
