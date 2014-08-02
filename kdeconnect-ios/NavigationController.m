//
//  NavigationController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 8/1/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "NavigationController.h"
#import "common.h"
@interface NavigationController ()

@end

@implementation NavigationController

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

- (BOOL)shouldAutorotate
{
    UIViewController* currentViewController = self.topViewController;
    if (isPhone) {
        NSString* t=currentViewController.title;
        if ([currentViewController.title isEqualToString:@"Mouse Pad"])
            return YES;
        else
            return NO;
    }
    if (isPad) {
        
    }
    return YES;
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
