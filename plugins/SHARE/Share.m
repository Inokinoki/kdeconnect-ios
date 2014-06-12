//
//  Share.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/4/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Share.h"

@interface Share()
@property(nonatomic) UIView* _view;
@property(nonatomic) UIViewController* _deviceViewController;
@end

@implementation Share

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _view;
@synthesize _deviceViewController;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"Share" displayName:@"Share" description:@"Share" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_SHARE]) {
        NSLog(@"share plugin receive a package");
        UIImage* image=[UIImage imageWithData:[np _Payload]];
        //TODO save picture
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"share plugin get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 90)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"Share"];
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button1 setTitle:@"Share photo from camera" forState:UIControlStateNormal];
        button1.frame= CGRectMake(0, 30, 300, 30);
        [button1 addTarget:self action:@selector(sharePhotoFromCamera:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button2 setTitle:@"Share photo from library" forState:UIControlStateNormal];
        button2.frame= CGRectMake(0, 60, 300, 30);
        [button2 addTarget:self action:@selector(sharePhotoFromLibrary:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button1];
        [_view addSubview:button2];
    }
    _deviceViewController=vc;
    return _view;
}

- (IBAction)sharePhotoFromCamera:(id)sender
{
        UIImagePickerController* _imagePicker=[[UIImagePickerController alloc] init];
        _imagePicker.delegate=self;
        _imagePicker.allowsEditing=NO;
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [_deviceViewController presentViewController:_imagePicker animated:YES completion:nil];
}

- (IBAction)sharePhotoFromLibrary:(id)sender
{
    UIImagePickerController* _imagePicker=[[UIImagePickerController alloc] init];
    _imagePicker.delegate=self;
    _imagePicker.allowsEditing=NO;
    _imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [_deviceViewController presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //TODO the quality of image?
    NSData* imageData=UIImageJPEGRepresentation(chosenImage, 0);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_SHARE];
    [[np _Body] setValue:[NSNumber numberWithLong:[imageData length]] forKey:@"size"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *theDate = [dateFormat stringFromDate:now];
    [[np _Body] setValue:FORMAT(@"%@_%@",[UIDevice currentDevice].name,theDate) forKey:@"filename"];
    [np set_Payload:imageData];
    [_device sendPackage:np tag:PACKAGE_TAG_SHARE];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
