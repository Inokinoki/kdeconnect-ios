//
//  DeviceViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/18/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MRProgress.h"
#import "DeviceViewController.h"
#import "PluginFactory.h"
@interface DeviceViewController ()

@end

@implementation DeviceViewController

@synthesize _deviceId;

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
    NSArray* pluginList=[[PluginFactory sharedInstance] getAvailablePlugins];
    for (NSString* plugin in pluginList) {
        UIView* pluginView=[[[PluginFactory sharedInstance] getPlugin:plugin] getView];
        [self.view addSubview:pluginView];
    }
}

//TO-DO
- (void) loadPluginsViews:(NSArray*)plugins
{
    for (NSString* plugin in plugins) {
        UIView* pluginView=[[[PluginFactory sharedInstance] getPlugin:plugin] getView];
        [self.view addSubview:pluginView];
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
