//Copyright 9/7/14  YANG Qiao yangqiao0505@me.com
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

#import "Reminder.h"
#import "Device.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "XBICalendar.h"
#import "XbICComponent+VTodo.h"

@interface Reminder ()
@property(nonatomic)EKEventStore *_eventStore;
@property(nonatomic)NSArray *_reminderList;
@property(nonatomic)NSMutableArray *_invalideUids;
@property(nonatomic)BOOL _shouldSend;
@property(nonatomic)BOOL _isProcessing;
@end

@implementation Reminder
@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _reminderList;
@synthesize _eventStore;
@synthesize _invalideUids;
@synthesize _shouldSend;
@synthesize _isProcessing;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _eventStore = [[EKEventStore alloc] init];
        _reminderList = [NSArray array];
        _invalideUids = [NSMutableArray array];
        _shouldSend=false;
        _isProcessing=false;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(storeChanged:)
                                                    name:EKEventStoreChangedNotification  object:_eventStore];
        [self checkEventStoreAccessForCalendar];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_REMINDER]) {
        //NSLog(@"Reminder plugin receive a package");
        if ([np bodyHasKey:@"request"]) {
            _shouldSend=true;
            [self fetchReminders];
        }
        else {
            if ([ [np objectForKey:@"status"] isEqualToString:@"begin"]) {
                _isProcessing=true;
                return true;
            }
            else if ([ [np objectForKey:@"status"] isEqualToString:@"end"] ) {
                _isProcessing=false;
                [self fetchReminders]; 
                return true;
            }
            else{
                _isProcessing=true;
            }

            NSError* err;
            EKReminder* reminder=[Reminder retrieveEvent:np withStore:_eventStore error:&err];
            
            if ([err.domain isEqualToString:@"iCal parse failed"]) {
                return true;
            }

            if ([[np objectForKey:@"op"] isEqualToString:@"delete"]){
                [_eventStore removeReminder:reminder commit:YES error:&err];
            }
            else if ([[np objectForKey:@"op"] isEqualToString:@"merge"]){
                if ([err.domain isEqualToString:@"iCal fix uid"]) {
                    NSString* uid=[[err userInfo] objectForKey:@"uid"];
                    if (![_invalideUids containsObject:uid]) {
                        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_REMINDER];
                        [np setObject:@"delete" forKey:@"op"];
                        [np setObject:uid forKey:@"uid"];
                        [_device sendPackage:np tag:PACKAGE_TAG_REMINDER];
                        [_invalideUids addObject:uid];
                    }
                }
                
                EKReminder* oldreminder=[_eventStore calendarItemWithIdentifier:reminder.calendarItemIdentifier];
                if (!oldreminder ||
                    ![Reminder reminder:reminder isIdenToReminder2:oldreminder] ){
                    [_eventStore saveReminder:reminder commit:YES error:&err];
                    _shouldSend=true;
                }
            }
        }
        return true;
    }
    return false;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Reminder" displayName:NSLocalizedString(@"Reminder",nil) description:NSLocalizedString(@"Reminder",nil) enabledByDefault:true];
}

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Reminder
        case EKAuthorizationStatusAuthorized: [self accessGrantedForReminder];
            break;
            // Prompt the user for access to Reminder if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestReminderAccess];
            break;
            // Display a message if the user has denied or restricted access to Reminder
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning",nil) message:NSLocalizedString(@"Permission was not granted for Calendar",nil)
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

// Prompt the user for access to their Reminder
-(void)requestReminderAccess
{
    [_eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             [self accessGrantedForReminder];
         }
     }];
}

// This method is called when the user has granted permission to Reminder
-(void)accessGrantedForReminder
{
    [self fetchReminders];
}

// Fetch all reminders
- (void) fetchReminders
{
    // Create the predicate
	NSPredicate *predicate = [_eventStore predicateForRemindersInCalendars:nil];
    
    // Fetch all events that match the predicate
    [_eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
        _reminderList=reminders;
        [self fetchCompleted];
    }];
}

- (void) fetchCompleted
{
    if ([_reminderList count]==0) {
        NetworkPackage* np2=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
        [np2 setBool:YES forKey:@"request"];
        [_device sendPackage:np2 tag:PACKAGE_TAG_CALENDAR];
    }
    if (_shouldSend) {
        [self sendReminder];
    }
}

- (void) storeChanged:(id) sender
{
    _shouldSend=true;
    [self fetchReminders];
}

- (void) sendReminder
{
    if ( _isProcessing || !_shouldSend)
        return;
    
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_REMINDER];
    [np setObject:@"merge" forKey:@"op"];
    [np setObject:@"begin" forKey:@"status"];
    [_device sendPackage:np tag:PACKAGE_TAG_REMINDER];
    for (EKReminder* r in _reminderList) {
        NetworkPackage* np=[Reminder createNetworkPackage:r];
        [np setObject:@"merge" forKey:@"op"];
        [np setObject:@"proccess" forKey:@"status"];
        [_device sendPackage:np tag:PACKAGE_TAG_REMINDER];
    }
    NetworkPackage* np2=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_REMINDER];
    [np setObject:@"merge" forKey:@"op"];
    [np setObject:@"end" forKey:@"status"];
    [_device sendPackage:np tag:PACKAGE_TAG_REMINDER];
    _shouldSend=false;
}

+ (BOOL) reminder:(EKReminder*) reminder1 isIdenToReminder2:(EKReminder*) reminder2
{
    return [reminder1.title isEqualToString:reminder2.title] &&
            [reminder1.dueDateComponents.date isEqualToDate:reminder2.dueDateComponents.date]&&
            [reminder1 isCompleted]==[reminder2 isCompleted];
}

+ (EKReminder*) retrieveEvent:(NetworkPackage*)np withStore:(EKEventStore*) eventstore error:( NSError*__autoreleasing*)err
{
    return [Reminder iCalToReminder:[np objectForKey:@"iCal"] withStore:eventstore error:err];
}

+ (NetworkPackage*) createNetworkPackage: (EKReminder*)reminder
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_REMINDER];
    NSString* ical=[Reminder reminderToiCal:reminder];
    if (!ical) {
        return nil;
    }
    [np setObject:ical forKey:@"iCal"];
    [np setObject:reminder.calendarItemIdentifier forKey:@"uid"];
    return np;
}

+ (EKReminder*) iCalToReminder: (NSString*) iCal withStore:(EKEventStore*) eventstore error:( NSError*__autoreleasing*)err
{
    XbICVCalendar * vCalendar =  [XbICVCalendar vCalendarFromString:iCal];
    XbICComponent* xbicvtodo=[vCalendar firstComponentOfKind:ICAL_VTODO_COMPONENT];
    
    
    NSString* uid=[xbicvtodo UID];
    NSString* summary=xbicvtodo.summary;
    NSDate* dt_s=xbicvtodo.dateStart;
    NSDate* dt_due=xbicvtodo.dateDue;
    NSDate* dt_created=xbicvtodo.dateCreated;
    NSDate* dt_modified=xbicvtodo.dateLastModified;
    NSDate* dt_completed=xbicvtodo.completed;
    NSNumber* percent=xbicvtodo.percentCompleted;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* start_dtc=[gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:dt_s];
    [start_dtc setTimeZone:[NSTimeZone localTimeZone]];
    [start_dtc setCalendar:gregorian];
    NSDateComponents* due_dtc=[gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:dt_due];
    [due_dtc setTimeZone:[NSTimeZone localTimeZone]];
    [due_dtc setCalendar:gregorian];
    
    if (!uid||!summary) {
        *err=[[NSError alloc] initWithDomain:@"iCal parse failed" code:0 userInfo:nil];
        return nil;
    }
    EKReminder* reminder=[eventstore calendarItemWithIdentifier:uid];
    if (!reminder) {
        reminder=[EKReminder reminderWithEventStore:eventstore];
        [reminder setCalendar:[eventstore defaultCalendarForNewReminders]];
        [reminder setTitle:summary];
        [reminder setStartDateComponents:start_dtc];
        [reminder setDueDateComponents:due_dtc];
        if (dt_completed) {
            [reminder setCompleted:YES];
            [reminder setCompletionDate:dt_completed];
        }
        else{
            [reminder setCompleted:NO];
        }
        *err=[[NSError alloc] initWithDomain:@"iCal fix uid" code:1 userInfo:@{@"uid": uid}];
        return reminder;
    }
    if ( ![reminder.title isEqualToString:summary]||
        ![reminder.dueDateComponents.date isEqualToDate:due_dtc.date] ||
        reminder.completed == !dt_completed) {
        if ([reminder.lastModifiedDate compare:dt_modified]==NSOrderedAscending) {
            [reminder setCalendar:[eventstore defaultCalendarForNewReminders]];
            [reminder setTitle:summary];
            [reminder setStartDateComponents:start_dtc];
            [reminder setDueDateComponents:due_dtc];
            if (dt_completed) {
                [reminder setCompleted:YES];
                [reminder setCompletionDate:dt_completed];
            }
            else{
                [reminder setCompleted:NO];
            }
        }
    }
    return reminder;
}

+ (NSString*) reminderToiCal: (EKReminder*)reminder
{
    if (!reminder || [reminder.title isEqualToString:@""]) {
        return nil;
    }
    NSDateFormatter* df=[[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    NSString* dt_stamp=[df stringFromDate:[NSDate date]];
    NSString* dt_create=[df stringFromDate:reminder.creationDate];
    NSString* dt_modified=[df stringFromDate:reminder.lastModifiedDate];
    NSString* dt_start=[df stringFromDate:reminder.startDateComponents.date];
    NSString* dt_due=[df stringFromDate:reminder.dueDateComponents.date];
    NSString* dt_completed=[df stringFromDate:reminder.completionDate];
    NSString* t=reminder.title;
    NSMutableString* iCal=[NSMutableString string];
    [iCal appendString:@"BEGIN:VCALENDAR\n"];
    [iCal appendString:@"VERSION:2.0\n"];
    [iCal appendString:@"PRODID:-//kde//kdeconnect-ios v0.1/EN\n"];
    [iCal appendString:@"BEGIN:VTODO\n"];
    [iCal appendFormat:@"DTSTAMP:%@\n",dt_stamp];
    [iCal appendFormat:@"CREATED:%@\n",dt_create];
    [iCal appendFormat:@"LAST-MODIFIED:%@\n",dt_modified];
    [iCal appendFormat:@"DUE:%@\n",dt_due];
    [iCal appendFormat:@"DTSTART:%@\n",dt_start];
    [iCal appendFormat:@"UID:%@\n",reminder.calendarItemIdentifier];
    [iCal appendFormat:@"SUMMARY:%@\n",t];
    if (reminder.completed) {
        [iCal appendFormat:@"COMPLETED:%@\n",dt_completed];
    }
    [iCal appendString:@"END:VTODO\n"];
    [iCal appendString:@"END:VCALENDAR\n"];
    return iCal;
}

@end

