//
//  inAppSettingViewController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/10/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "inAppSettingViewController.h"

@interface inAppSettingViewController ()

@end

@implementation inAppSettingViewController

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
}


//#pragma mark - UITableView header customization
//- (CGFloat) settingsViewController:(id<IASKViewController>)settingsViewController
//                         tableView:(UITableView *)tableView
//         heightForHeaderForSection:(NSInteger)section
//{
//    
//}
//- (UIView *) settingsViewController:(id<IASKViewController>)settingsViewController
//                          tableView:(UITableView *)tableView
//            viewForHeaderForSection:(NSInteger)section
//{
//    
//}
//
//#pragma mark - UITableView cell customization
//- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier
//{
//    
//}
//
//- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier
//{
//    
//}
//
//#pragma mark - mail composing customization
//- (NSString*) settingsViewController:(id<IASKViewController>)settingsViewController
//         mailComposeBodyForSpecifier:(IASKSpecifier*) specifier
//{
//    
//}
//
//- (UIViewController<MFMailComposeViewControllerDelegate>*) settingsViewController:(id<IASKViewController>)settingsViewController
//                                     viewControllerForMailComposeViewForSpecifier:(IASKSpecifier*) specifier
//{
//    
//}
//
//- (void) settingsViewController:(id<IASKViewController>) settingsViewController
//          mailComposeController:(MFMailComposeViewController*)controller
//            didFinishWithResult:(MFMailComposeResult)result
//                          error:(NSError*)error
//{
//    
//}
//
//#pragma mark - respond to button taps
//
//- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier
//{
//    
//}
//- (void)settingsViewController:(IASKAppSettingsViewController*)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier*)specifier
//{
//    
//}

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
