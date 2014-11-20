//Copyright 18/5/14  YANG Qiao yangqiao0505@me.com
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

#import "MRProgress.h"
#import "DeviceViewController.h"
#import "BackgroundService.h"
#import "AppSettingViewController.h"
#import "IASKSettingsReader.h"
#import "SettingsStore.h"
#import "VTAcknowledgementsViewController.h"
#import "MyStyleKit.h"
#import "SplitViewController.h"
#import "NavigationController.h"

@interface DeviceViewController ()
@property (nonatomic, retain) AppSettingViewController *_AppSettingViewController;
@property (nonatomic) UIPopoverController* _currentPopoverController;
@end

@implementation DeviceViewController

@synthesize _deviceId;
@synthesize _AppSettingViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.splitViewController.delegate = self;
    UIBarButtonItem* buttonItem=[[UIBarButtonItem alloc] initWithImage:[MyStyleKit imageOfGear] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsModal:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [self reloadPluginsViews];
}

- (void) updateView
{
    [self reloadPluginsViews];
    [self.view setNeedsDisplay];
}

- (void) reloadPluginsViews
{
    NSArray* viewlist=[[BackgroundService sharedInstance] getDevicePluginViews:_deviceId viewController:self];
    CGRect preFrame=CGRectMake(0, 64, 0, 0);
    NSArray *subviews = [self.view subviews];
    for (int i=0; i<[subviews count]; i++)
    {
        [[subviews objectAtIndex:i] removeFromSuperview];
    }
    for (UIView* view in viewlist) {
        CGRect viewFrame=view.frame;
        viewFrame.origin.y+=(preFrame.origin.y+preFrame.size.height);
        preFrame=viewFrame;
        [view setFrame:viewFrame];
        [self.view addSubview:view];
        if (isPad) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[view]-10-|" options:0 metrics:nil views:@{@"view": view}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"V:[view(%f)]",view.frame.size.height) options:0 metrics:nil views:@{@"view": view}]];
            view.translatesAutoresizingMaskIntoConstraints=NO;
            [self.view addConstraints:constraints];
        }
        if (isPhone) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[view]-10-|" options:0 metrics:nil views:@{@"view": view}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"V:[view(%f)]",view.frame.size.height) options:0 metrics:nil views:@{@"view": view}]];
            view.translatesAutoresizingMaskIntoConstraints=NO;
            [self.view addConstraints:constraints];
        }
    }
}

- (void) onDeviceLost
{
    //NSLog(@"device vc on device lost");
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.view setNeedsDisplay];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showSettingsModal:(id)sender {
    NavigationController *aNavController = [[NavigationController alloc] initWithRootViewController:self._AppSettingViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self._AppSettingViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

- (void)showSettingsPopover:(id)sender {
	if(self._currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}
    
	self._AppSettingViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self._AppSettingViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
	self._currentPopoverController = popover;
}

- (void)awakeFromNib {
	if (isPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}
}

- (AppSettingViewController*)_AppSettingViewController {
	if (!_AppSettingViewController) {
		_AppSettingViewController = [[AppSettingViewController alloc] init];
		_AppSettingViewController.delegate = self;
        [_AppSettingViewController setSettingsReader:[[IASKSettingsReader alloc]init]];
        [_AppSettingViewController setSettingsStore:[[SettingsStore alloc] initWithPath:_deviceId]];
	}
	return _AppSettingViewController;
}

#pragma mark - View Lifecycle
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(self._currentPopoverController) {
		[self dismissCurrentPopover];
	}
}

- (void) dismissCurrentPopover {
	[self._currentPopoverController dismissPopoverAnimated:YES];
	self._currentPopoverController = nil;
}

#pragma mark AppSettingViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
	// your code here to reconfigure the app for changed settings
    [[BackgroundService sharedInstance] reloadAllPlugins];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.view subviews]
                        makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self viewDidLoad];
        [self viewWillAppear:YES];
        [self.view setNeedsDisplay];
    });
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier;
{
    if ([specifier.key isEqualToString:@"acknowledgements"]) {
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        viewController.headerText = NSLocalizedString(@"Thanks for these open source softwares", nil); // optional
        [_AppSettingViewController.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark -UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation NS_AVAILABLE_IOS(5_0)
{
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
