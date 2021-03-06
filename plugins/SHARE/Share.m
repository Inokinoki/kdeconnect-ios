//Copyright 4/6/14  YANG Qiao yangqiao0505@me.com
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
//----------------------------------------------------------------------

#import "Share.h"
#import "device.h"
#import <AudioToolbox/AudioServices.h>

#define PAYLOAD_PORT 1739

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
        /*
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = FORMAT(NSLocalizedString(@"received a photo from:%@",nil),[_device _name]);
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.soundName= UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        */
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Received file",nil)
                                       message:@""
                                       preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action) {}];
        [alert addAction:okAction];
        
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alert animated:YES completion:nil];
        
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    if ([_device isReachable]) {
        _view=[[UIStackView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 90)];
        UIStackView *stackView = (UIStackView *)_view;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.alignment = UIStackViewAlignmentFill;

        UILabel* label=[[UILabel alloc] init];
        [label setText:NSLocalizedString(@"Share",nil)];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"Share photo",nil) forState:UIControlStateNormal];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 10.0;
        button.layer.borderColor = [[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(photoSourceSelect:) forControlEvents:UIControlEventTouchUpInside];

#ifdef DEBUG
        UIButton *testUrlButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [testUrlButton setTitle:NSLocalizedString(@"Share URL",nil) forState:UIControlStateNormal];
        testUrlButton.layer.borderWidth = 1;
        testUrlButton.layer.cornerRadius = 10.0;
        testUrlButton.layer.borderColor = [[UIColor grayColor] CGColor];
        [testUrlButton addTarget:self action:@selector(shareUrl:) forControlEvents:UIControlEventTouchUpInside];
#endif
        
        stackView.distribution = UIStackViewDistributionFillProportionally;
        [stackView addArrangedSubview:label];
        [stackView addArrangedSubview:button];
#ifdef DEBUG
        [stackView addArrangedSubview:testUrlButton];
#endif
        if (isPad) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-100-[button]-100-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        if (isPhone) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[button]-10-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        label.translatesAutoresizingMaskIntoConstraints     = NO;
        button.translatesAutoresizingMaskIntoConstraints    = NO;
    }
    else{
        _view=nil;
    }
    _deviceViewController=vc;
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Share" displayName:NSLocalizedString(@"Share",nil) description:NSLocalizedString(@"Share",nil) enabledByDefault:true];

}
- (void)photoSourceSelect:(id)sender
{
    NSLog(@"Create photoSourceSelect view");
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Photo Source",nil)
                                   message:@""
                                   preferredStyle: isPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    
    UIAlertAction* fromCameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo From Camera",nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) { [self sharePhotoFromCamera]; }];
    [alert addAction:fromCameraAction];
    
    UIAlertAction* fromLibraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo From Library",nil)
                                    style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { [self sharePhotoFromLibrary]; }];
    [alert addAction:fromLibraryAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];

    [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)shareUrl:(id)sender
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_SHARE];
    [np setObject:@"https://kdeconnect.kde.org" forKey:@"url"];
    [_device sendPackage:np tag:PACKAGE_TAG_SHARE];
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
        UIAlertController* alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Save",nil)
                                                                       message: @""
                                                                preferredStyle: UIAlertControllerStyleActionSheet];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Discard",nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        UIAlertAction* saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save",nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
            UIImageWriteToSavedPhotosAlbum(_image,nil,nil,nil);
        }];
        [alert addAction:saveAction];
        [alert addAction:cancelAction];
        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alert animated:YES completion:nil];
    }
    NSData* imageData=UIImageJPEGRepresentation(_image, 1);
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_SHARE];
    [np setInteger:[imageData length] forKey:@"size"];
    [np set_PayloadTransferInfo:@{ @"port": [NSNumber numberWithInt: PAYLOAD_PORT] }];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *theDate = [dateFormat stringFromDate:now];
    [np setObject:FORMAT(@"%@_%@.jpg",[UIDevice currentDevice].name,theDate) forKey:@"filename"];
    [np set_Payload:imageData];
    [np set_PayloadSize: [imageData length]];
    [_device sendPackage:np tag:PACKAGE_TAG_SHARE];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void) sentPercentage:(short)percentage tag:(long)tag
{
    // do nothing
}

@end
