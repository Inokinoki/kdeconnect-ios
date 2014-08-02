//
//  DeviceViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MRProgress.h"
#import "DeviceViewController.h"
#import "BackgroundService.h"
#import "IASKSettingsReader.h"
#import "SettingsStore.h"

@interface DeviceViewController ()
@property (nonatomic, retain) AppSettingViewController *_appSettingsViewController;
@property (nonatomic) UIPopoverController* _currentPopoverController;
@end

@implementation DeviceViewController

@synthesize _deviceId;
@synthesize _appSettingsViewController;

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
    UIBarButtonItem* buttonItem=[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsModal:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [self loadPluginsViews];
}

- (void) loadPluginsViews
{
    NSArray* viewlist=[[BackgroundService sharedInstance] getDevicePluginViews:_deviceId viewController:self];
    CGRect preFrame=CGRectMake(0, 64, 0, 0);
    for (UIView* view in viewlist) {
        CGRect viewFrame=view.frame;
        viewFrame.origin.y+=(preFrame.origin.y+preFrame.size.height);
        preFrame=viewFrame;
        [view setFrame:viewFrame];
        [self.view addSubview:view];
    }
}

- (void) onDeviceLost
{
    NSLog(@"device vc on device lost");
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self viewDidLoad];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showSettingsModal:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self._appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self._appSettingsViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

- (void)showSettingsPopover:(id)sender {
	if(self._currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}
    
	self._appSettingsViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self._appSettingsViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
	self._currentPopoverController = popover;
}

- (void)awakeFromNib {
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}
}

- (IASKAppSettingsViewController*)_appSettingsViewController {
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		_appSettingsViewController.delegate = self;
        [_appSettingsViewController setSettingsReader:[[IASKSettingsReader alloc]init]];
        [_appSettingsViewController setSettingsStore:[[SettingsStore alloc] initWithPath:_deviceId]];
	}
	return _appSettingsViewController;
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

#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
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
