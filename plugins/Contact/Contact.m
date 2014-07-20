//
//  Contact.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/17/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

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
        NSLog(@"Contact plugin receive a package");
        if ([np bodyHasKey:@"request"]) {
            [self updateAddressBook];
            [self sendAddressBook];
        }
        else {
            if ([[np objectForKey:@"op"] isEqualToString:@"delete"]){
            }
            else if ([[np objectForKey:@"op"] isEqualToString:@"merge"]){
//                [self mergeContacts:[np objectForKey:@"vcard"]];
            }
        }
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"ping plugin get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"Contact"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Send contacts to Device" forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(contactSourceSelect:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
        _deviceViewController=vc;
    }
    else{
        _view=nil;
    }
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Contact" displayName:@"Contact" description:@"Contact" enabledByDefault:true];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for addressbook"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Send Contact"
                                                            delegate:self
                                                   cancelButtonTitle:@"cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"All local contacts",@"Select local contact",nil];
    
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
    if([[actionSheet title] isEqualToString:@"Send Contact"]){
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
