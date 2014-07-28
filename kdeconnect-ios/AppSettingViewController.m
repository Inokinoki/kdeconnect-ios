//
//  inAppSettingViewController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/10/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "BackgroundService.h"
#import "AppSettingViewController.h"
#import "SettingsStore.h"
#import "IASKSettingsReader.h"
#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKPSTextFieldSpecifierViewCell.h"
#import "IASKPSTitleValueSpecifierViewCell.h"
#import "IASKSwitch.h"
#import "IASKSlider.h"
#import "IASKSpecifier.h"
#import "IASKSpecifierValuesViewController.h"
#import "IASKTextField.h"
#import "VTAcknowledgementsViewController.h"
@interface AppSettingViewController ()

@end

@implementation AppSettingViewController

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
    [self.tabBarController setDelegate:self];
    [self setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dismiss:(id)sender {
	[self.settingsStore synchronize];
	
	if (self.delegate && [self.delegate conformsToProtocol:@protocol(IASKSettingsDelegate)]) {
		[self.delegate settingsViewControllerDidEnd:self];
	}
    [[BackgroundService sharedInstance] reloadAllPlugins];
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[super settingsStore] synchronize];
    //FIX-ME shouldn't put it here, move to somewhere else
    [[BackgroundService sharedInstance] reloadAllPlugins];
}

#pragma mark - IASKAppSetting Delegate
- (void)settingsViewController:(id)sender buttonTappedForKey:(NSString*)key
{
    if ([key isEqualToString:@"acknowledgements"]) {
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        viewController.headerText = NSLocalizedString(@"We love open source software.", nil); // optional
        [self.navigationController pushViewController:viewController animated:YES];
    }
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
