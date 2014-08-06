//
//  NavigationController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 8/1/14.
//  
//

#import "NavigationController.h"
#import "common.h"
#import "MyStyleKit.h"

@interface NavigationController ()

@end

@implementation NavigationController

@synthesize _enableRotateMask;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _enableRotateMask=true;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [MyStyleKit navbar]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    UIViewController* currentViewController = self.topViewController;
    if (_enableRotateMask) {

        if (isPhone) {
            NSString* t=currentViewController.title;
            if ([currentViewController.title isEqualToString:NSLocalizedString(@"Mouse Pad",nil)])
                return YES;
            else
                return NO;
        }
        if (isPad) {
            
        }
        return YES;
    }
    else
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
