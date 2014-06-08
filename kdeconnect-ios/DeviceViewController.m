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

@interface DeviceViewController ()
@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic) UIPopoverController* currentPopoverController;
@end

@implementation DeviceViewController

@synthesize _deviceId;
@synthesize appSettingsViewController;

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
    [self loadPluginsViews];
}

//TO-DO
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


- (void)showSettingsPopover:(id)sender {
	if(self.currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}
    
	self.appSettingsViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
	self.currentPopoverController = popover;
}

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}
}

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}

- (IBAction)showSettingsModal:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

#pragma mark - View Lifecycle
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(self.currentPopoverController) {
		[self dismissCurrentPopover];
	}
}

- (void) dismissCurrentPopover {
	[self.currentPopoverController dismissPopoverAnimated:YES];
	self.currentPopoverController = nil;
}

#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
	
	// your code here to reconfigure the app for changed settings
}

- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView
        heightForHeaderForSection:(NSInteger)section {
		return 55.f;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
           viewForHeaderForSection:(NSInteger)section {

        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor redColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:16.f];
        
        //figure out the title from settingsbundle
        label.text = [settingsViewController.settingsReader titleForSection:section];
        return label;
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
	return 0;
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {

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
