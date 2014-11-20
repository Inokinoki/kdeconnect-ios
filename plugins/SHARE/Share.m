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
        //NSLog(@"share plugin receive a package");
        UIImage* image=[UIImage imageWithData:[np _Payload]];
        UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = FORMAT(NSLocalizedString(@"received a photo from:%@",nil),[_device _name]);
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
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:NSLocalizedString(@"Share",nil)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"Share photo",nil) forState:UIControlStateNormal];
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(photoSourceSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
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
        label.translatesAutoresizingMaskIntoConstraints=NO;
        button.translatesAutoresizingMaskIntoConstraints=NO;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Photo Source",nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Photo From Camera",nil),
                                  NSLocalizedString(@"Photo From Library",nil),nil];
    
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
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"Save",nil)
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:NSLocalizedString(@"Discard",nil)
                                      otherButtonTitles:NSLocalizedString(@"Save",nil),nil];
        
        actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
        
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    NSData* imageData=UIImageJPEGRepresentation(_image, 1);
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_SHARE];
    [np setInteger:[imageData length] forKey:@"size"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *theDate = [dateFormat stringFromDate:now];
    [np setObject:FORMAT(@"%@_%@.jpg",[UIDevice currentDevice].name,theDate) forKey:@"filename"];
    [np set_Payload:imageData];
    [_device sendPackage:np tag:PACKAGE_TAG_SHARE];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet title] isEqualToString:NSLocalizedString(@"Save",nil)]) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                UIImageWriteToSavedPhotosAlbum(_image,nil,nil,nil);
                break;
                
            default:
                break;
        }
    }else if([[actionSheet title] isEqualToString:NSLocalizedString(@"Photo Source",nil)]){
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
