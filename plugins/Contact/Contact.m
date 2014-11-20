//Copyright 17/7/14  YANG Qiao yangqiao0505@me.com
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

#import "Contact.h"
#import "Device.h"
#import <AddressBook/AddressBook.h>

typedef NS_ENUM(NSInteger, DataClass)  {
    Location,
    Calendars,
    Contacts,
    Photos,
    Reminders,
    Microphone,
    Motion,
    Bluetooth,
    Facebook,
    Twitter,
    SinaWeibo,
    TencentWeibo,
    Advertising
};

@interface Contact ()
@property(nonatomic)ABAddressBookRef _addressbook;
@property(nonatomic)NSArray* _allContacts;
@property(nonatomic)UIView* _view;
@property(nonatomic)UIViewController* _deviceViewController;
@end

@implementation Contact

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _addressbook;
@synthesize _allContacts;
@synthesize _view;
@synthesize _deviceViewController;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _allContacts=Nil;
        _view=nil;
        _deviceViewController=nil;
        _addressbook=ABAddressBookCreateWithOptions(NULL, NULL);
        [self checkAddressBookAccess];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_CONTACT]) {
        //NSLog(@"Contact plugin receive a package");
        if ([np bodyHasKey:@"request"]) {
            [self updateAddressBook];
            [self sendAddressBook];
        }
        else {
            if ([[np objectForKey:@"op"] isEqualToString:@"delete"]){
            }
            else if ([[np objectForKey:@"op"] isEqualToString:@"merge"]){
                ABRecordRef record=ABAddressBookGetPersonWithRecordID(_addressbook, [np integerForKey:@"rid"]);
                if (record) {
                    //merge
                }else{
                    //add
                    
                }
            }
        }
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    if ([_device isReachable]) {

        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:NSLocalizedString(@"Contact",nil)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"Send contacts to Device",nil) forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(contactSourceSelect:) forControlEvents:UIControlEventTouchUpInside];
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
    return [[PluginInfo alloc] initWithInfos:@"Contact" displayName:NSLocalizedString(@"Contact",nil) description:NSLocalizedString(@"Contact",nil) enabledByDefault:true];
}

- (void) updateAddressBook
{
    ABAddressBookRevert(_addressbook);
    _allContacts=(__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(_addressbook));
}

- (void) sendAddressBook
{
    for (id record in _allContacts) {
        NSData* data=(__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)([NSArray arrayWithObject:record])));
        NSString* str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CONTACT];
        [np setObject:str forKey:@"vcard"];
        [np setObject:@"merge" forKey:@"op"];
        [np setInteger:ABRecordGetRecordID((__bridge ABRecordRef)(record)) forKey:@"rid"];
        [_device sendPackage:np tag:PACKAGE_TAG_CONTACT];
    }
}

- (void) sendContact:(ABRecordRef) record
{
    NSData* data=(__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)([NSArray arrayWithObject:(__bridge id)(record)])));
    NSString* str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CONTACT];
    [np setObject:str forKey:@"vcard"];
    [np setObject:@"merge" forKey:@"op"];
    [_device sendPackage:np tag:PACKAGE_TAG_CONTACT];
}

- (void)checkAddressBookAccess {
    /*
     We can ask the address book ahead of time what the authorization status is for our bundle and take the appropriate action.
     */
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusNotDetermined:[self requestAddressBookAccess];
            break;
        case kABAuthorizationStatusAuthorized:[self accessGrantedForAddressbook];
            break;

        case kABAuthorizationStatusRestricted:
        case kABAuthorizationStatusDenied:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning",nil) message:NSLocalizedString(@"Permission was not granted for addressbook",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

void handleAddressBookChange(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    /*
     Do something with changed addres book data...
     */
}

- (void)requestAddressBookAccess {

    if(_addressbook) {
        /*
         Register for a callback if the addressbook data changes this is important to be notified of new data when the user grants access to the contacts. the application should also be able to handle a nil object being returned as well if the user denies access to the address book.
         */
        ABAddressBookRegisterExternalChangeCallback(_addressbook, handleAddressBookChange, (__bridge void *)(self));
        
        /*
         When the application requests to receive address book data that is when the user is presented with a consent dialog.
         */
        ABAddressBookRequestAccessWithCompletion(_addressbook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self accessGrantedForAddressbook];
            }
        });
    }
}

-(void)accessGrantedForAddressbook
{
    [self updateAddressBook];
}

- (void) mergeContacts:(NSString*) vCardStr
{
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(_addressbook);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, (__bridge CFDataRef)([vCardStr dataUsingEncoding:NSUTF8StringEncoding]));
    for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
        ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
        ABAddressBookAddRecord(_addressbook, person, NULL);
    }
    CFRelease(vCardPeople);
    CFRelease(defaultSource);
    ABAddressBookSave(_addressbook, NULL);
}

- (void)contactSourceSelect:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Send Contact",nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"All local contacts",nil),
                                  NSLocalizedString(@"Select local contact",nil),nil];
    
    actionSheet.actionSheetStyle =UIActionSheetStyleAutomatic;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void) dealloc
{
    if(_addressbook) {
        ABAddressBookUnregisterExternalChangeCallback(_addressbook, handleAddressBookChange, (__bridge void *)(self));
        CFRelease(_addressbook);
    }
}


#pragma mark UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
    if([[actionSheet title] isEqualToString:NSLocalizedString(@"Send Contact",nil)]){
        switch (buttonIndex) {
            case 0:
                [self updateAddressBook];
                [self sendAddressBook];
                break;
            case 1:
                picker.peoplePickerDelegate = self;
                [_deviceViewController presentViewController:picker animated:YES completion:nil];
                break;
            default:
                return;
                break;
        }
    }
}

#pragma mark ABPeoplePickerNavigationController delegate

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [peoplePicker dismissViewControllerAnimated:YES completion:^(void){
        [self sendContact:person];
    }];
    return NO;
}


// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


@end
