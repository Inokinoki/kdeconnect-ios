//Copyright 2/5/14  YANG Qiao yangqiao0505@me.com
//kdeconnect is distributed under two licenses.
//
//* The Mozilla Public License (MPL) v2.0
//
//or
//
//* The General Public License (GPL) v2.1
//
//----------------------------------------------------------------------
//
//Software distributed under these licenses is distributed on an "AS
//IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
//implied. See the License for the specific language governing rights
//and limitations under the License.
//kdeconnect is distributed under both the GPL and the MPL. The MPL
//notice, reproduced below, covers the use of either of the licenses.
//
//---------------------------------------------------------------------

#import "DeviceViewController.h"
#import "ViewController.h"
#import "MRProgress.h"
#import "NavigationController.h"
#import "MyStyleKit.h"

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
    NavigationController* navc=self.navigationController;
    [navc set_enableRotateMask:YES];
    UIBarButtonItem *buttonItemr = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                target:self
                                                                                action:@selector(onRefresh:)];
    self.navigationItem.rightBarButtonItem = buttonItemr;
    [self onDeviceListRefreshed];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:@"KDEConnect"];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) onPairRequest:(NSString*)deviceID
{
    _pairingDevice=deviceID;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Incoming Pair Request",nil)
          message:FORMAT(NSLocalizedString(@"Incoming pair request from device: %@ ",nil),[_visibleDevices valueForKey:deviceID])
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
          otherButtonTitles:NSLocalizedString(@"Pair",nil),nil] show];
    });
}

- (void) onPairTimeout:(NSString*)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRProgressOverlayView* progview=[MRProgressOverlayView overlayForView:self.view];
        [progview setTitleLabelText:NSLocalizedString(@"Time out",nil)];
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
        [progview setTitleLabelText:NSLocalizedString(@"Success",nil)];
        [progview setMode:MRProgressOverlayViewModeCheckmark];
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [progview dismiss:YES];
        });
        _pairingDevice=nil;
        [self onDeviceListRefreshed];
    });
    //NSLog(@"viewcontroller onPairSuccess");

}

- (void) onPairRejected:(NSString*)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MRProgressOverlayView* progview=[MRProgressOverlayView overlayForView:self.view];
        [progview setTitleLabelText:NSLocalizedString(@"Rejected",nil)];
        [progview setMode:MRProgressOverlayViewModeCross];
        dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
            [progview dismiss:YES];
        });
        _pairingDevice=nil;
    });
    //NSLog(@"viewcontroller onPairRejected");
}

- (void) onDeviceListRefreshed
{
    BackgroundService* bg=[BackgroundService sharedInstance] ;
    NSDictionary* list=[bg getDevicesLists];
    _rememberedDevices  =[list valueForKey:@"remembered"];
    _connectedDevices   =[list valueForKey:@"connected"];
    _visibleDevices     =[list valueForKey:@"visible"];
    DeviceViewController* dvc=self.splitViewController.viewControllers.lastObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (dvc._deviceId && ![[_connectedDevices allKeys] containsObject:dvc._deviceId]) {
            dvc._deviceId=nil;
            [dvc updateView];
        }
        [_tableView reloadData];
        [_tableView reloadSectionIndexTitles];
    });
}

- (void) onRefresh:(id)sender
{
    [[BackgroundService sharedInstance] refreshDiscovery];
    dispatch_time_t dismissTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(dismissTime, dispatch_get_main_queue(), ^(void){
        [self onDeviceListRefreshed];
        if ([sender isKindOfClass:[UIRefreshControl class]]) {
            [sender endRefreshing];
        }
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"More Actions",nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Unpair",nil),nil];
    actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
#pragma mark -
#pragma mark Table View Data Source Methods

//return number of sections
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger count=[_rememberedDevices count];
    if (!count) {
        return 2;
    }
    return 3;
}

//return row count
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    switch (section) {
        case 0:
            return NSLocalizedString(@"connected devices",nil);
        case 1:
            return NSLocalizedString(@"visible devices",nil)  ;
        case 2:
            return NSLocalizedString(@"remembered devices",nil);
        default:
            return @"";
    }
}

//redraw a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[MyStyleKit imageOfMore] forState:UIControlStateNormal];
        [button setImage:[MyStyleKit imageOfMoreHighlighted] forState:UIControlStateHighlighted];
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
    UIAlertView* alertDialog;
    DeviceViewController* vc;
    NSString* deviceId;
    switch (indexPath.section) {
        case 0:
            deviceId=[[_connectedDevices allKeys]objectAtIndex:indexPath.row];
            if (isPhone) {
                vc=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]]
                    instantiateViewControllerWithIdentifier:@"DeviceViewController"];
                [vc set_deviceId:deviceId];
                [vc setTitle:[_connectedDevices valueForKey:deviceId]];
                [self.navigationController pushViewController:vc animated:YES];
            }
            if (isPad) {
                
                vc=self.splitViewController.viewControllers.lastObject;
                [vc set_deviceId:deviceId];
                [vc updateView];
            }
            
            break;
        case 1:
            _pairingDevice=[[_visibleDevices allKeys]objectAtIndex:indexPath.row];
            alertDialog=[[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"Pair Request",nil)
                         message:FORMAT(NSLocalizedString(@"pair device: %@ ?",nil),[_visibleDevices valueForKey:_pairingDevice])
                         delegate:self
                         cancelButtonTitle:NSLocalizedString(@"No",nil)
                         otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
            [alertDialog show];
            break;
        case 2:
        default:;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//alertedialog
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView title] isEqualToString:NSLocalizedString(@"Pair Request",nil)]) {
        switch (buttonIndex) {
            case 0:
                _pairingDevice=nil;
                break;
            case 1:
                [[BackgroundService sharedInstance] pairDevice:_pairingDevice];
                [[MRProgressOverlayView showOverlayAddedTo:self.view animated:YES]
                 setTitleLabelText:NSLocalizedString(@"Pairing",nil)];
                break;
            default:
                break;
        }
    }
    else if ([[alertView title] isEqualToString:NSLocalizedString(@"Success",nil)]){
    }
    else if([[alertView title] isEqualToString:NSLocalizedString(@"Incoming Pair Request",nil)]){
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
    if ([[actionSheet title] isEqualToString:NSLocalizedString(@"More Actions",nil)]) {
        switch (buttonIndex) {
            case 0:
                [[BackgroundService sharedInstance] unpairDevice:_moreActionDevice];
                [self onRefresh:nil];
                break;
            case 1:
            default:
                break;
        }
    }
    _moreActionDevice=nil;
}
@end
