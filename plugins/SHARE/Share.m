//
//  Share.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/4/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Share.h"
#import "device.h"
#import <AudioToolbox/AudioServices.h>

@interface Share()
@property(nonatomic) UIView* _view;
@property(nonatomic) UIViewController* _deviceViewController;
@property(nonatomic) UIImage* _image;
@end

@implementation Share

@synthesize _device;
@synthesize _pluginDelegate;
@synthesize _view;
@synthesize _deviceViewController;
@synthesize _image;

- (id) init
{
    if ((self=[super init])) {
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
        UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = FORMAT(@"Share:received a photo from:%@",[_device _name]);
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName= UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"share plugin get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"Share"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Share photo" forState:UIControlStateNormal];
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(photoSourceSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    else{
        _view=nil;
    }
    _deviceViewController=vc;
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Share" displayName:@"Share" description:@"Share" enabledByDefault:true];

}
- (void)photoSourceSelect:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Photo Source"
                                                            delegate:self
                                                   cancelButtonTitle:@"cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Photo From Camera",@"Photo From Library",nil];
    
    actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)sharePhotoFromCamera
{
        UIImagePickerController* _imagePicker=[[UIImagePickerController alloc] init];
        _imagePicker.delegate=self;
        _imagePicker.allowsEditing=NO;
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [_deviceViewController presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)sharePhotoFromLibrary
{
    UIImagePickerController* _imagePicker=[[UIImagePickerController alloc] init];
    _imagePicker.delegate=self;
    _imagePicker.allowsEditing=NO;
    _imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [_deviceViewController presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    _image= info[UIImagePickerControllerOriginalImage];
    NSURL* url=info[UIImagePickerControllerReferenceURL];
    if (url) {
        //photo from library
    }
    else{
        //photo taken
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Save"
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:@"Discard"
                                                       otherButtonTitles:@"Save",nil];
        
        actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
        
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Image Quality"
                                                            delegate:self
                                                   cancelButtonTitle:@"cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"High",@"Medium",@"Low",nil];
    
    actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet title] isEqualToString:@"Save"]) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                UIImageWriteToSavedPhotosAlbum(_image,nil,nil,nil);
                break;
                
            default:
                break;
        }
    }else if([[actionSheet title] isEqualToString:@"Image Quality"]){
        float quality;
        switch (buttonIndex) {
            case 0:
                quality=1;
                break;
            case 1:
                quality=0.5;
                break;
            case 2:
                quality=0;
                break;
            case 3:
            default:
                return;
                break;
        }
        
        NSData* imageData=UIImageJPEGRepresentation(_image, quality);
        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_SHARE];
        [np setInteger:[imageData length] forKey:@"size"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [NSDate date];
        NSString *theDate = [dateFormat stringFromDate:now];
        [np setObject:FORMAT(@"%@_%@",[UIDevice currentDevice].name,theDate) forKey:@"filename"];
        [np set_Payload:imageData];
        [_device sendPackage:np tag:PACKAGE_TAG_SHARE];
    }else if([[actionSheet title] isEqualToString:@"Photo Source"]){
        switch (buttonIndex) {
            case 0:
                [self sharePhotoFromCamera];
                break;
            case 1:
                [self sharePhotoFromLibrary];
                break;
            case 2:
                break;
            case 3:
            default:
                return;
                break;
        }
    }
}

@end
